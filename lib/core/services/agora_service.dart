import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart'; // for debugPrint
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_token_service/agora_token_service.dart';

import '../config/agora_config.dart';

enum CallState {
  idle,
  outgoingRinging,
  incomingRinging,
  connected,
  rejected,
  ended,
  failed,
}

class AgoraService extends GetxController {
  RtcEngine? _engine;
  int? _localUid;
  final Set<int> _remoteUids = {};
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeakerOn = true;
  ConnectionStateType _connectionState = ConnectionStateType.connectionStateDisconnected;
  CallState _callState = CallState.idle;
  String? _currentCallerId; // Store caller info

  bool get isJoined => _isJoined;
  bool get isMuted => _isMuted;
  bool get isVideoOff => _isVideoOff;
  bool get isSpeakerOn => _isSpeakerOn;
  ConnectionStateType get connectionState => _connectionState;
  CallState get callState => _callState;
  String? get currentCallerId => _currentCallerId;
  Set<int> get remoteUids => _remoteUids;
  int? get localUid => _localUid;
  RtcEngine get engine {
    if (_engine == null) {
      throw Exception('Agora Engine not initialized');
    }
    return _engine!;
  }

  bool _isAudioCall = false;
  bool get isAudioCall => _isAudioCall;

  Future<void> initialize({bool isAudioCall = false}) async {
    _isAudioCall = isAudioCall;

    // Request permissions based on call type
    List<Permission> permissions = [Permission.microphone];
    if (!isAudioCall) {
      permissions.add(Permission.camera);
    }
    await permissions.request();

    if (AgoraConfig.appId.isEmpty) {
      throw Exception('Agora App ID is missing from configuration.');
    }

    if (_engine == null) {
      // Create RtcEngine instance
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(
        RtcEngineContext(
          appId: AgoraConfig.appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      // Register event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            _isJoined = true;
            _localUid = connection.localUid;
            try {
              _engine?.setEnableSpeakerphone(true);
            } catch (_) {}
            update();
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            _remoteUids.add(remoteUid);
            update();
          },
          onUserOffline:
              (
                RtcConnection connection,
                int remoteUid,
                UserOfflineReasonType reason,
              ) {
                _remoteUids.remove(remoteUid);
                if (_remoteUids.isEmpty) {
                  // Return to Join screen if the only remote user leaves
                  leaveChannel();
                }
                update();
              },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            _isJoined = false;
            _localUid = null;
            _remoteUids.clear();
            _isMuted = false;
            // Retain _isAudioCall state just in case, but usually reset in _resetCallState
            _isVideoOff = _isAudioCall;
            _isSpeakerOn = true;
            _connectionState = ConnectionStateType.connectionStateDisconnected;
            _callState = CallState.idle;
            _currentCallerId = null;
            update();
          },
          onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
            _connectionState = state;
            update();
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint('[Agora Error] $err: $msg');
          },
        ),
      );
    }

    // Enable audio and set volumes
    await _engine!.enableAudio();
    await _engine!.adjustPlaybackSignalVolume(100);
    await _engine!.adjustRecordingSignalVolume(100);

    // Setup video based on call type
    if (isAudioCall) {
      await _engine!.disableVideo();
      _isVideoOff = true;
    } else {
      await _engine!.enableVideo();
      await _engine!.startPreview();
      _isVideoOff = false;
    }
  }

  Future<void> joinChannel(String channelName, {String token = ''}) async {
    // Always call initialize to ensure correct permissions and engine state (audio vs video)
    await initialize(isAudioCall: _isAudioCall);

    String actualToken = token;
    if (actualToken.isEmpty && AgoraConfig.appCertificate.isNotEmpty) {
      final expireTime = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
      actualToken = RtcTokenBuilder.build(
        appId: AgoraConfig.appId,
        appCertificate: AgoraConfig.appCertificate,
        channelName: channelName,
        uid: '0',
        role: RtcRole.publisher,
        expireTimestamp: expireTime,
      );
    }

    await _engine!.joinChannel(
      token: actualToken,
      channelId: channelName,
      uid: 0, // 0 lets Agora assign a UID automatically
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        autoSubscribeAudio: true,
        autoSubscribeVideo: !_isAudioCall,
        publishCameraTrack: !_isAudioCall,
        publishMicrophoneTrack: true,
      ),
    );
  }

  // --- SIGNALING FOUNDATION ---

  Future<void> startOutgoingCall(String targetUserId, {bool isAudioCall = false}) async {
    if (_callState != CallState.idle) return;
    _isAudioCall = isAudioCall;
    _callState = CallState.outgoingRinging;
    _currentCallerId = targetUserId;
    update();

    // TODO: [Backend Requirement] POST /api/call/initiate with targetUserId.
    // Simulate auto-accept for testing if no backend is present.
    Future.delayed(const Duration(seconds: 3), () {
      if (_callState == CallState.outgoingRinging) {
        // Simulate remote accepted
        _callState = CallState.connected;
        update();
        joinChannel('test_channel');
      }
    });
  }

  void triggerIncomingCall(String callerId, {bool isAudioCall = false}) {
    if (_callState != CallState.idle) return;
    _isAudioCall = isAudioCall;
    _callState = CallState.incomingRinging;
    _currentCallerId = callerId;
    update();
  }

  Future<void> acceptCall() async {
    if (_callState != CallState.incomingRinging) return;
    
    // TODO: [Backend Requirement] POST /api/call/accept
    _callState = CallState.connected;
    update();
    await joinChannel('test_channel');
  }

  Future<void> rejectCall() async {
    if (_callState != CallState.incomingRinging) return;

    // TODO: [Backend Requirement] POST /api/call/reject
    _callState = CallState.rejected;
    update();
    
    await Future.delayed(const Duration(seconds: 2));
    _resetCallState();
  }

  Future<void> endCall() async {
    // TODO: [Backend Requirement] POST /api/call/end
    if (_isJoined) {
      await leaveChannel();
    } else {
      _resetCallState();
    }
  }

  void _resetCallState() {
    _callState = CallState.idle;
    _currentCallerId = null;
    update();
  }

  Future<void> leaveChannel() async {
    if (_engine != null) {
      await _engine!.leaveChannel();
    }
  }

  Future<void> toggleMute() async {
    if (_engine != null) {
      _isMuted = !_isMuted;
      await _engine!.muteLocalAudioStream(_isMuted);
      update();
    }
  }

  Future<void> toggleVideo() async {
    if (_engine != null) {
      _isVideoOff = !_isVideoOff;
      await _engine!.muteLocalVideoStream(_isVideoOff);
      update();
    }
  }

  Future<void> switchCamera() async {
    if (_engine != null) {
      await _engine!.switchCamera();
    }
  }

  Future<void> toggleSpeaker() async {
    if (_engine != null) {
      _isSpeakerOn = !_isSpeakerOn;
      await _engine!.setEnableSpeakerphone(_isSpeakerOn);
      update();
    }
  }

  @override
  void onClose() {
    leaveChannel();
    _engine?.release();
    super.onClose();
  }
}

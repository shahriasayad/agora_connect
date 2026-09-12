import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart'; // for debugPrint
import 'package:flutter/services.dart';
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

  // Signaling & Call Timer
  final String myUserId = (Random().nextInt(9000) + 1000).toString(); // 4-digit random ID
  int? _streamId;
  bool _isSignalingJoined = false;
  String? _callChannel;
  
  Timer? _vibrateTimer;
  Timer? _durationTimer;
  int callDuration = 0;
  Timer? _outgoingTimeoutTimer;

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

  @override
  void onInit() {
    super.onInit();
    initSignaling();
  }

  // Initializing Engine without permissions (just for signaling)
  Future<void> initSignaling() async {
    if (AgoraConfig.appId.isEmpty) return;

    if (_engine == null) {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(
        RtcEngineContext(
          appId: AgoraConfig.appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
            if (connection.channelId == 'global_signaling') {
              _isSignalingJoined = true;
              try {
                _streamId = await _engine!.createDataStream(const DataStreamConfig(syncWithAudio: false, ordered: true));
              } catch(e) {
                debugPrint("Data stream error: $e");
              }
              update();
            } else {
              _isJoined = true;
              _localUid = connection.localUid;
              try {
                _engine?.setEnableSpeakerphone(true);
              } catch (_) {}
              
              // Start call duration timer when we actually join the call channel
              _startDurationTimer();
              update();
            }
          },
          onStreamMessage: (RtcConnection connection, int remoteUid, int streamId, Uint8List data, int length, int sentTs) {
            final msg = utf8.decode(data);
            _handleSignalingMessage(msg);
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            if (connection.channelId != 'global_signaling') {
              _remoteUids.add(remoteUid);
              update();
            }
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            if (connection.channelId != 'global_signaling') {
              _remoteUids.remove(remoteUid);
              if (_remoteUids.isEmpty && _callState == CallState.connected) {
                // Other user left the call
                _endCallCleanly();
              }
              update();
            }
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            // handled manually in _endCallCleanly
          },
          onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
            if (connection.channelId != 'global_signaling') {
              _connectionState = state;
              update();
            }
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint('[Agora Error] $err: $msg');
          },
        ),
      );
    }

    if (!_isSignalingJoined && _callState == CallState.idle) {
      await _engine!.joinChannel(
        token: _generateToken('global_signaling', '0'),
        channelId: 'global_signaling',
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: false,
          publishCameraTrack: false,
          autoSubscribeAudio: false,
          autoSubscribeVideo: false,
        ),
      );
    }
  }

  String _generateToken(String channelName, String uidStr) {
    if (AgoraConfig.appCertificate.isEmpty) return '';
    final expireTime = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
    return RtcTokenBuilder.build(
      appId: AgoraConfig.appId,
      appCertificate: AgoraConfig.appCertificate,
      channelName: channelName,
      uid: uidStr,
      role: RtcRole.publisher,
      expireTimestamp: expireTime,
    );
  }

  void _sendSignalingMessage(Map<String, dynamic> data) {
    if (_streamId != null && _engine != null && _isSignalingJoined) {
      try {
        _engine!.sendStreamMessage(
          streamId: _streamId!,
          data: Uint8List.fromList(utf8.encode(jsonEncode(data))),
          length: jsonEncode(data).length,
        );
      } catch (e) {
        debugPrint("Error sending message: $e");
      }
    }
  }

  void _handleSignalingMessage(String payload) {
    try {
      final data = jsonDecode(payload);
      if (data['to'] != myUserId) return; // not for me

      final type = data['type'];
      final from = data['from'];

      if (type == 'CALL') {
        if (_callState != CallState.idle) {
          // busy
          _sendSignalingMessage({"type": "DECLINE", "from": myUserId, "to": from, "reason": "busy"});
          return;
        }
        _isAudioCall = data['isAudio'] ?? false;
        _currentCallerId = from;
        _callChannel = data['channel'];
        _callState = CallState.incomingRinging;
        _startRinging();
        
        // Timeout if not answered
        _outgoingTimeoutTimer?.cancel();
        _outgoingTimeoutTimer = Timer(const Duration(seconds: 45), () {
          if (_callState == CallState.incomingRinging) {
             _resetCallState();
          }
        });
        
        update();
      } else if (type == 'ACCEPT') {
        if (_callState == CallState.outgoingRinging && _currentCallerId == from) {
          _outgoingTimeoutTimer?.cancel();
          _stopRinging();
          _callState = CallState.connected;
          update();
          _joinCallChannel(_callChannel!);
        }
      } else if (type == 'DECLINE') {
        if (_callState == CallState.outgoingRinging && _currentCallerId == from) {
          _outgoingTimeoutTimer?.cancel();
          _stopRinging();
          _callState = CallState.rejected;
          update();
          Future.delayed(const Duration(seconds: 2), () {
            if (_callState == CallState.rejected) _resetCallState();
          });
        }
      } else if (type == 'CANCEL') {
        if (_callState == CallState.incomingRinging && _currentCallerId == from) {
          _stopRinging();
          _outgoingTimeoutTimer?.cancel();
          _resetCallState();
        }
      }
    } catch (e) {
      debugPrint("Signaling parse error: $e");
    }
  }

  Future<void> _prepareMediaForCall() async {
    // Request permissions based on call type
    List<Permission> permissions = [Permission.microphone];
    if (!_isAudioCall) {
      permissions.add(Permission.camera);
    }
    await permissions.request();

    await _engine!.enableAudio();
    await _engine!.adjustPlaybackSignalVolume(100);
    await _engine!.adjustRecordingSignalVolume(100);

    // Setup video based on call type
    if (_isAudioCall) {
      await _engine!.disableVideo();
      _isVideoOff = true;
    } else {
      await _engine!.enableVideo();
      await _engine!.startPreview();
      _isVideoOff = false;
    }
  }

  Future<void> _joinCallChannel(String channelName) async {
    // Leave signaling first
    if (_isSignalingJoined) {
      await _engine!.leaveChannel();
      _isSignalingJoined = false;
      _streamId = null;
    }
    
    await _prepareMediaForCall();

    await _engine!.joinChannel(
      token: _generateToken(channelName, '0'),
      channelId: channelName,
      uid: 0,
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        autoSubscribeAudio: true,
        autoSubscribeVideo: !_isAudioCall,
        publishCameraTrack: !_isAudioCall,
        publishMicrophoneTrack: true,
      ),
    );
  }

  // --- SIGNALING ACTIONS ---

  Future<void> startOutgoingCall(String targetUserId, {bool isAudioCall = false}) async {
    if (_callState != CallState.idle || !_isSignalingJoined) return;
    if (targetUserId.isEmpty) return;
    
    // Check permissions early before ringing
    List<Permission> permissions = [Permission.microphone];
    if (!isAudioCall) permissions.add(Permission.camera);
    final status = await permissions.request();
    if (status.values.any((s) => s.isDenied || s.isPermanentlyDenied)) {
      // Permission denied
      return;
    }

    _isAudioCall = isAudioCall;
    _callState = CallState.outgoingRinging;
    _currentCallerId = targetUserId;
    _callChannel = 'call_${myUserId}_$targetUserId';
    
    _sendSignalingMessage({
      "type": "CALL",
      "from": myUserId,
      "to": targetUserId,
      "isAudio": isAudioCall,
      "channel": _callChannel
    });
    
    _startRinging(); // simulate ringing for outgoing too?
    
    _outgoingTimeoutTimer?.cancel();
    _outgoingTimeoutTimer = Timer(const Duration(seconds: 45), () {
      if (_callState == CallState.outgoingRinging) {
        endCall();
      }
    });
    
    update();
  }

  Future<void> acceptCall() async {
    if (_callState != CallState.incomingRinging) return;
    
    _outgoingTimeoutTimer?.cancel();
    _stopRinging();
    
    _sendSignalingMessage({
      "type": "ACCEPT",
      "from": myUserId,
      "to": _currentCallerId
    });
    
    _callState = CallState.connected;
    update();
    await _joinCallChannel(_callChannel!);
  }

  Future<void> rejectCall() async {
    if (_callState != CallState.incomingRinging) return;

    _outgoingTimeoutTimer?.cancel();
    _stopRinging();
    
    _sendSignalingMessage({
      "type": "DECLINE",
      "from": myUserId,
      "to": _currentCallerId
    });
    
    _callState = CallState.rejected;
    update();
    
    await Future.delayed(const Duration(seconds: 2));
    _resetCallState();
  }

  Future<void> endCall() async {
    _outgoingTimeoutTimer?.cancel();
    _stopRinging();
    
    if (_callState == CallState.outgoingRinging) {
      _sendSignalingMessage({
        "type": "CANCEL",
        "from": myUserId,
        "to": _currentCallerId
      });
      _resetCallState();
    } else if (_isJoined || _callState == CallState.connected) {
      await _endCallCleanly();
    } else {
      _resetCallState();
    }
  }

  Future<void> _endCallCleanly() async {
    _stopDurationTimer();
    
    if (_engine != null && _isJoined) {
      await _engine!.leaveChannel();
    }
    
    _isJoined = false;
    _localUid = null;
    _remoteUids.clear();
    _isMuted = false;
    _isVideoOff = _isAudioCall;
    _isSpeakerOn = true;
    _connectionState = ConnectionStateType.connectionStateDisconnected;
    _callState = CallState.idle;
    _currentCallerId = null;
    _callChannel = null;
    update();
    
    // Rejoin signaling network to receive next calls
    initSignaling();
  }

  void _resetCallState() {
    _stopRinging();
    _stopDurationTimer();
    _callState = CallState.idle;
    _currentCallerId = null;
    _callChannel = null;
    update();
  }

  void _startRinging() {
    _stopRinging(); // Ensure no duplicates
    _vibrateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.heavyImpact());
    });
  }

  void _stopRinging() {
    _vibrateTimer?.cancel();
    _vibrateTimer = null;
  }
  
  void _startDurationTimer() {
    _stopDurationTimer();
    callDuration = 0;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callDuration++;
      update();
    });
  }
  
  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
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
    _stopRinging();
    _stopDurationTimer();
    _outgoingTimeoutTimer?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    super.onClose();
  }
}

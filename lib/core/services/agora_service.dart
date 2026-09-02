import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/agora_config.dart';

class AgoraService extends ChangeNotifier {
  RtcEngine? _engine;
  int? _localUid;
  final Set<int> _remoteUids = {};
  bool _isJoined = false;

  bool get isJoined => _isJoined;
  Set<int> get remoteUids => _remoteUids;
  int? get localUid => _localUid;
  RtcEngine get engine {
    if (_engine == null) {
      throw Exception('Agora Engine not initialized');
    }
    return _engine!;
  }

  Future<void> initialize() async {
    // Request permissions first
    await [Permission.camera, Permission.microphone].request();

    if (AgoraConfig.appId.isEmpty) {
      throw Exception('Agora App ID is missing from configuration.');
    }

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
          notifyListeners();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          _remoteUids.add(remoteUid);
          notifyListeners();
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              _remoteUids.remove(remoteUid);
              notifyListeners();
            },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          _isJoined = false;
          _localUid = null;
          _remoteUids.clear();
          notifyListeners();
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('[Agora Error] $err: $msg');
        },
      ),
    );

    // Enable video by default for Phase 3 readiness
    await _engine!.enableVideo();
  }

  Future<void> joinChannel(String channelName, {String token = ''}) async {
    if (_engine == null) await initialize();

    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: 0, // 0 lets Agora assign a UID automatically
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
      ),
    );
  }

  Future<void> leaveChannel() async {
    if (_engine != null) {
      await _engine!.leaveChannel();
    }
  }

  @override
  void dispose() {
    leaveChannel();
    _engine?.release();
    super.dispose();
  }
}

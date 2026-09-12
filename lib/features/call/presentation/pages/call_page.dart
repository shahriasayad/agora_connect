import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:agora_connect/core/services/agora_service.dart';
import 'package:agora_connect/util/screen_util.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  @override
  void initState() {
    super.initState();
    // Initialize Agora when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AgoraService>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Call')),
      body: GetBuilder<AgoraService>(
        builder: (agoraService) {
          return Stack(
            children: [
              // Remote video or placeholder
              Center(
                child: _remoteVideo(agoraService),
              ),
              // Connection Status
              Positioned(
                top: 20.h,
                left: 20.w,
                child: SafeArea(child: _buildConnectionStatus(agoraService)),
              ),
              // Local video preview
              if (agoraService.isJoined)
                Positioned(
                  top: 20.h,
                  right: 20.w,
                  width: 120.w,
                  height: 160.h,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.black54,
                    ),
                    child: _localVideo(agoraService),
                  ),
                ),
              // Bottom control buttons
              Positioned(
                bottom: 30.h,
                left: 0,
                right: 0,
                child: _buildBottomControls(agoraService),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomControls(AgoraService agoraService) {
    switch (agoraService.callState) {
      case CallState.idle:
      case CallState.rejected:
      case CallState.ended:
      case CallState.failed:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => agoraService.startOutgoingCall('user_123'),
              child: const Text('Call user_123'),
            ),
            15.hSpace,
            ElevatedButton(
              onPressed: () => agoraService.triggerIncomingCall('user_456'),
              child: const Text('Simulate Incoming Call'),
            ),
          ],
        );
      case CallState.outgoingRinging:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => agoraService.endCall(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Cancel Call', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      case CallState.incomingRinging:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => agoraService.acceptCall(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Accept', style: TextStyle(color: Colors.white)),
            ),
            20.hSpace,
            ElevatedButton(
              onPressed: () => agoraService.rejectCall(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reject', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      case CallState.connected:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => agoraService.toggleMute(),
              icon: Icon(
                agoraService.isMuted ? Icons.mic_off : Icons.mic,
                color: agoraService.isMuted ? Colors.red : Colors.blue,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.all(12.w),
              ),
            ),
            15.hSpace,
            IconButton(
              onPressed: () => agoraService.toggleVideo(),
              icon: Icon(
                agoraService.isVideoOff ? Icons.videocam_off : Icons.videocam,
                color: agoraService.isVideoOff ? Colors.red : Colors.blue,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.all(12.w),
              ),
            ),
            15.hSpace,
            IconButton(
              onPressed: () => agoraService.switchCamera(),
              icon: const Icon(Icons.flip_camera_ios, color: Colors.blue),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.all(12.w),
              ),
            ),
            15.hSpace,
            IconButton(
              onPressed: () => agoraService.toggleSpeaker(),
              icon: Icon(
                agoraService.isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                color: agoraService.isSpeakerOn ? Colors.blue : Colors.red,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.all(12.w),
              ),
            ),
            20.hSpace,
            ElevatedButton(
              onPressed: () => agoraService.endCall(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('End Call', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
    }
  }

  Widget _localVideo(AgoraService agoraService) {
    if (!agoraService.isJoined) {
      return Center(child: Icon(Icons.person, color: Colors.white, size: 40.sp));
    }
    if (agoraService.isVideoOff) {
      return Center(child: Icon(Icons.videocam_off, color: Colors.white, size: 40.sp));
    }
    try {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraService.engine,
          canvas: const VideoCanvas(
            uid: 0,
            renderMode: RenderModeType.renderModeHidden,
          ),
        ),
      );
    } catch (e) {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildConnectionStatus(AgoraService agoraService) {
    if (!agoraService.isJoined) return const SizedBox.shrink();

    String statusText = '';
    Color statusColor = Colors.grey;

    switch (agoraService.connectionState) {
      case ConnectionStateType.connectionStateDisconnected:
      case ConnectionStateType.connectionStateFailed:
        statusText = 'Disconnected';
        statusColor = Colors.red;
        break;
      case ConnectionStateType.connectionStateConnecting:
        statusText = 'Connecting...';
        statusColor = Colors.orange;
        break;
      case ConnectionStateType.connectionStateConnected:
        statusText = 'Connected';
        statusColor = Colors.green;
        break;
      case ConnectionStateType.connectionStateReconnecting:
        statusText = 'Reconnecting...';
        statusColor = Colors.orange;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          8.hSpace,
          Text(
            statusText,
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _remoteVideo(AgoraService agoraService) {
    if (agoraService.callState == CallState.outgoingRinging) {
      return Text('Calling ${agoraService.currentCallerId ?? ''}...', textAlign: TextAlign.center);
    }
    if (agoraService.callState == CallState.incomingRinging) {
      return Text('Incoming call from ${agoraService.currentCallerId ?? ''}', textAlign: TextAlign.center);
    }
    if (agoraService.callState == CallState.rejected) {
      return const Text('Call Rejected', textAlign: TextAlign.center);
    }
    
    if (!agoraService.isJoined) {
      return const Text(
        'Ready to call',
        textAlign: TextAlign.center,
      );
    }
    if (agoraService.remoteUids.isNotEmpty) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: agoraService.engine,
          canvas: VideoCanvas(
            uid: agoraService.remoteUids.first,
            renderMode: RenderModeType.renderModeFit,
          ),
          connection: const RtcConnection(channelId: 'test_channel'),
        ),
      );
    } else {
      return const Text(
        'Waiting for other user to join...',
        textAlign: TextAlign.center,
      );
    }
  }
}


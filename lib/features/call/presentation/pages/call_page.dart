import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:agora_connect/core/services/agora_service.dart';

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
              // Local video preview
              Positioned(
                top: 20,
                right: 20,
                width: 120,
                height: 160,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black54,
                  ),
                  child: _localVideo(agoraService),
                ),
              ),
              // Bottom control buttons
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!agoraService.isJoined)
                      ElevatedButton(
                        onPressed: () => agoraService.joinChannel('test_channel'),
                        child: const Text('Join Channel'),
                      )
                    else
                      ElevatedButton(
                        onPressed: () => agoraService.leaveChannel(),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Leave Call', style: TextStyle(color: Colors.white)),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _localVideo(AgoraService agoraService) {
    // If not joined, we can still show the preview if engine is initialized.
    // However, engine might not be initialized immediately on first frame.
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

  Widget _remoteVideo(AgoraService agoraService) {
    if (agoraService.isJoined && agoraService.remoteUids.isNotEmpty) {
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


import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      appBar: AppBar(title: const Text('Call Page')),
      body: GetBuilder<AgoraService>(
        builder: (agoraService) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Joined: ${agoraService.isJoined}'),
                Text('Local UID: ${agoraService.localUid ?? "None"}'),
                Text('Remote UIDs: ${agoraService.remoteUids.join(", ")}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: agoraService.isJoined
                      ? null
                      : () => agoraService.joinChannel('test_channel'),
                  child: const Text('Join Channel'),
                ),
                ElevatedButton(
                  onPressed: agoraService.isJoined
                      ? () => agoraService.leaveChannel()
                      : null,
                  child: const Text('Leave Channel'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


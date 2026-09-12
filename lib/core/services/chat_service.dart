import 'package:get/get.dart';
import 'package:agora_connect/core/services/agora_service.dart';

class ChatMessage {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String content;
  final DateTime timestamp;
  
  ChatMessage({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    required this.timestamp,
  });
}

class ChatService extends GetxController {
  // Map of remoteUserId -> List of ChatMessage
  final Map<String, List<ChatMessage>> conversations = {};

  void sendMessage(String toUserId, String text) {
    if (text.trim().isEmpty) return;
    
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromUserId: Get.find<AgoraService>().myUserId,
      toUserId: toUserId,
      content: text.trim(),
      timestamp: DateTime.now(),
    );

    if (!conversations.containsKey(toUserId)) {
      conversations[toUserId] = [];
    }
    conversations[toUserId]!.add(msg);
    
    Get.find<AgoraService>().sendSignalingMessage({
      "type": "CHAT",
      "from": msg.fromUserId,
      "to": toUserId,
      "content": msg.content,
      "msgId": msg.id
    });
    
    update(); // Notify UI
  }

  void receiveMessage(String fromUserId, String content, String msgId) {
    final msg = ChatMessage(
      id: msgId,
      fromUserId: fromUserId,
      toUserId: Get.find<AgoraService>().myUserId,
      content: content,
      timestamp: DateTime.now(),
    );

    if (!conversations.containsKey(fromUserId)) {
      conversations[fromUserId] = [];
    }
    conversations[fromUserId]!.add(msg);
    
    update(); // Notify UI
  }
}

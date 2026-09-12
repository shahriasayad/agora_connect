import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_connect/core/services/chat_service.dart';
import 'package:agora_connect/core/services/agora_service.dart';
import 'package:agora_connect/util/screen_util.dart';

class ChatPage extends StatefulWidget {
  final String remoteUserId;

  const ChatPage({super.key, required this.remoteUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final agoraService = Get.find<AgoraService>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: GetBuilder<AgoraService>(
          builder: (agoraService) => Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: colorScheme.secondaryContainer,
                child: Text(
                  widget.remoteUserId.isNotEmpty ? widget.remoteUserId.substring(0, 1).toUpperCase() : '?',
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              12.hSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User ${widget.remoteUserId}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  if (!agoraService.isSignalingJoined)
                    Text('Connecting...', style: TextStyle(fontSize: 12.sp, color: colorScheme.error)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              agoraService.startOutgoingCall(widget.remoteUserId, isAudioCall: true);
              Get.back();
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              agoraService.startOutgoingCall(widget.remoteUserId, isAudioCall: false);
              Get.back();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GetBuilder<ChatService>(
              builder: (chatService) {
                final messages = chatService.conversations[widget.remoteUserId] ?? [];
                
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];
                    final isMe = msg.fromUserId == agoraService.myUserId;
                    return _buildMessageBubble(msg, isMe, colorScheme);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(colorScheme),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe, ColorScheme colorScheme) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isMe ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
            bottomLeft: Radius.circular(isMe ? 20.r : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : 20.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.content,
              style: TextStyle(
                color: isMe ? colorScheme.onPrimary : colorScheme.onSurface,
                fontSize: 16.sp,
              ),
            ),
            4.vSpace,
            Text(
              _formatSimpleTime(msg.timestamp),
              style: TextStyle(
                color: isMe ? colorScheme.onPrimary.withValues(alpha: 0.7) : colorScheme.onSurfaceVariant,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSimpleTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute;
    final period = h >= 12 ? 'PM' : 'AM';
    final hr12 = h % 12 == 0 ? 12 : h % 12;
    final mm = m.toString().padLeft(2, '0');
    return '$hr12:$mm $period';
  }

  Widget _buildMessageInput(ColorScheme colorScheme) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  filled: true,
                  fillColor: colorScheme.surfaceContainer,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            12.hSpace,
            Container(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send),
                color: colorScheme.onPrimary,
                onPressed: () {
                  if (_messageController.text.trim().isNotEmpty) {
                    Get.find<ChatService>().sendMessage(widget.remoteUserId, _messageController.text);
                    _messageController.clear();
                    _scrollToBottom();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

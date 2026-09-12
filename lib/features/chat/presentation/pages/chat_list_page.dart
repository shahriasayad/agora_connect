import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_connect/core/services/chat_service.dart';
import 'package:agora_connect/features/chat/presentation/pages/chat_page.dart';
import 'package:agora_connect/util/screen_util.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Chats', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: GetBuilder<ChatService>(
        builder: (chatService) {
          final conversations = chatService.conversations;
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64.sp, color: colorScheme.surfaceContainerHighest),
                  16.vSpace,
                  Text(
                    'No active chats',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          final keys = conversations.keys.toList();
          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            itemCount: keys.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final remoteUserId = keys[index];
              final messages = conversations[remoteUserId]!;
              final lastMsg = messages.last;

              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                leading: CircleAvatar(
                  radius: 24.r,
                  backgroundColor: colorScheme.secondaryContainer,
                  child: Text(
                    remoteUserId.isNotEmpty ? remoteUserId.substring(0, 1).toUpperCase() : '?',
                    style: TextStyle(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
                title: Text(
                  'User $remoteUserId',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    fontSize: 16.sp,
                  ),
                ),
                subtitle: Text(
                  lastMsg.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14.sp),
                ),
                trailing: Text(
                  _formatSimpleTime(lastMsg.timestamp),
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12.sp),
                ),
                onTap: () {
                  Get.to(() => ChatPage(remoteUserId: remoteUserId));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewChatDialog(context);
        },
        child: const Icon(Icons.message),
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

  void _showNewChatDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Chat'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Target User ID',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final target = controller.text.trim();
                if (target.isNotEmpty) {
                  Navigator.pop(context);
                  Get.to(() => ChatPage(remoteUserId: target));
                }
              },
              child: const Text('Start'),
            ),
          ],
        );
      }
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_connect/core/services/agora_service.dart';
import 'package:agora_connect/util/screen_util.dart';

class CallHistoryPage extends StatelessWidget {
  const CallHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Call History'),
        actions: [
          GetBuilder<AgoraService>(
            builder: (agoraService) {
              if (agoraService.callHistory.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _showClearHistoryDialog(context, agoraService),
                child: Text(
                  'Clear All',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            },
          ),
        ],
      ),
      body: GetBuilder<AgoraService>(
        builder: (agoraService) {
          if (agoraService.callHistory.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: agoraService.callHistory.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final call = agoraService.callHistory[index];
              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  agoraService.deleteCallHistory(index);
                },
                background: Container(
                  color: Theme.of(context).colorScheme.error,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: _buildHistoryTile(context, call, agoraService),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64.sp, color: colorScheme.surfaceContainerHighest),
          16.vSpace,
          Text(
            'No recent calls',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(BuildContext context, CallHistoryItem call, AgoraService agoraService) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final bool isMissed = call.status == 'Missed' || call.status == 'Declined' || call.status == 'Failed';
    final Color iconColor = isMissed ? colorScheme.error : (call.isOutgoing ? colorScheme.primary : Colors.green);
    
    IconData typeIcon = call.isAudio ? Icons.call : Icons.videocam;
    IconData directionIcon = call.isOutgoing ? Icons.call_made : Icons.call_received;
    
    if (isMissed && !call.isOutgoing) {
      directionIcon = Icons.call_missed;
    } else if (isMissed && call.isOutgoing) {
      directionIcon = Icons.call_missed_outgoing;
    }

    String timeString = _formatDate(call.timestamp);
    String durationString = '';
    if (call.durationSeconds > 0) {
      final m = call.durationSeconds ~/ 60;
      final s = call.durationSeconds % 60;
      durationString = ' • ${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: CircleAvatar(
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: Icon(typeIcon, color: colorScheme.onSurfaceVariant),
      ),
      title: Text(
        'User ${call.remoteUserId}',
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: isMissed ? colorScheme.error : colorScheme.onSurface,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(directionIcon, size: 14.sp, color: iconColor),
          4.hSpace,
          Text(
            '$timeString$durationString',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.call, color: colorScheme.primary),
            onPressed: () => agoraService.startOutgoingCall(call.remoteUserId, isAudioCall: true),
          ),
          IconButton(
            icon: Icon(Icons.videocam, color: colorScheme.primary),
            onPressed: () => agoraService.startOutgoingCall(call.remoteUserId, isAudioCall: false),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, AgoraService agoraService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Call History'),
        content: const Text('Are you sure you want to delete all recent calls?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              agoraService.clearCallHistory();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0 && now.day == date.day) {
      return 'Today, ${_formatTime(date)}';
    } else if (difference.inDays == 1 || (difference.inDays == 0 && now.day != date.day)) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${date.month}/${date.day}/${date.year}, ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    String period = date.hour >= 12 ? 'PM' : 'AM';
    int hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    String minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}

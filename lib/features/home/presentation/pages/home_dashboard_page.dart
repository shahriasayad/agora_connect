import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_connect/core/services/agora_service.dart';
import 'package:agora_connect/util/screen_util.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  final TextEditingController _targetIdController = TextEditingController();
  final FocusNode _targetIdFocus = FocusNode();

  @override
  void dispose() {
    _targetIdController.dispose();
    _targetIdFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GetBuilder<AgoraService>(
        builder: (agoraService) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Agora Connect',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.account_circle, size: 16.sp, color: colorScheme.primary),
                              6.hSpace,
                              Text(
                                'ID: ${agoraService.myUserId}',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  32.vSpace,

                  // Action Area
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start a new call',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          16.vSpace,
                          TextField(
                            controller: _targetIdController,
                            focusNode: _targetIdFocus,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter Target User ID',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                            ),
                          ),
                          16.vSpace,
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () {
                                    if (_targetIdController.text.isNotEmpty) {
                                      _targetIdFocus.unfocus();
                                      agoraService.startOutgoingCall(_targetIdController.text.trim(), isAudioCall: true);
                                    }
                                  },
                                  icon: const Icon(Icons.call),
                                  label: const Text('Audio'),
                                  style: FilledButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                  ),
                                ),
                              ),
                              12.hSpace,
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: () {
                                    if (_targetIdController.text.isNotEmpty) {
                                      _targetIdFocus.unfocus();
                                      agoraService.startOutgoingCall(_targetIdController.text.trim(), isAudioCall: false);
                                    }
                                  },
                                  icon: const Icon(Icons.videocam),
                                  label: const Text('Video'),
                                  style: FilledButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  32.vSpace,
                  
                  // Call History
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      'Recent Calls',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  16.vSpace,
                  if (agoraService.callHistory.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Center(
                        child: Text(
                          'No recent calls',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: agoraService.callHistory.length > 5 ? 5 : agoraService.callHistory.length,
                      itemBuilder: (context, index) {
                        final call = agoraService.callHistory[index];
                        final isOutgoing = call.isOutgoing;
                        final isVideo = !call.isAudio;
                        
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
                          child: Material(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12.r),
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.primaryContainer,
                                child: Icon(
                                  isVideo ? Icons.videocam : Icons.call,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                              title: Text(
                                call.remoteUserId,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('${isOutgoing ? "Outgoing" : "Incoming"} • ${call.status}'),
                              trailing: IconButton(
                                icon: Icon(Icons.call, color: colorScheme.primary),
                                onPressed: () {
                                  agoraService.startOutgoingCall(
                                    call.remoteUserId,
                                    isAudioCall: call.isAudio,
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  
                  32.vSpace,
                ],
              ),
            ),
          );
        },
      ),
    );
  }


}

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
                            color: colorScheme.shadow.withOpacity(0.05),
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
                  
                  // Recent Calls summary
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      'Quick Actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  16.vSpace,
                  
                  // Cards for navigation or info could go here, for now keeping it clean.
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            context,
                            icon: Icons.history,
                            title: 'Call History',
                            subtitle: '${agoraService.callHistory.length} recent',
                            onTap: () {
                              // We can switch tab here but Get.find to change tab is complex.
                              // Actually Home is for dashboard.
                            },
                          ),
                        ),
                        16.hSpace,
                        Expanded(
                          child: _buildActionCard(
                            context,
                            icon: Icons.person_outline,
                            title: 'Your Profile',
                            subtitle: 'ID: ${agoraService.myUserId}',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 28.sp),
          12.vSpace,
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          4.vSpace,
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

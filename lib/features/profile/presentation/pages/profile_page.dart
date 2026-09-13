import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_connect/core/services/agora_service.dart';
import 'package:agora_connect/util/screen_util.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: GetBuilder<AgoraService>(
        builder: (agoraService) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return ListView(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48.r,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(Icons.person, size: 48.sp, color: colorScheme.onPrimaryContainer),
                    ),
                    16.vSpace,
                    Text(
                      'Your User ID',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    4.vSpace,
                    Text(
                      agoraService.myUserId,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              32.vSpace,

              // Settings Sections
              Text(
                'Settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              16.vSpace,
              
              _buildSettingsCard(
                context,
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('Theme'),
                    subtitle: const Text('System Default'),
                    onTap: () {
                      // Currently just using system default theme in main.dart
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.security_outlined),
                    title: const Text('Permissions'),
                    subtitle: const Text('Manage app permissions'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      openAppSettings();
                    },
                  ),
                ],
              ),
              
              24.vSpace,
              
              Text(
                'About',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              16.vSpace,
              
              _buildSettingsCard(
                context,
                children: [
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Version'),
                    subtitle: Text('1.0.0'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

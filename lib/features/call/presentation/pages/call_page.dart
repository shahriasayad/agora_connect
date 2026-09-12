import 'dart:ui';
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
          switch (agoraService.callState) {
            case CallState.idle:
              return _buildHomeScreen(agoraService);
            case CallState.outgoingRinging:
              return _buildOutgoingCallScreen(agoraService);
            case CallState.incomingRinging:
              return _buildIncomingCallScreen(agoraService);
            case CallState.connected:
              return _buildActiveCallScreen(agoraService);
            case CallState.rejected:
            case CallState.ended:
            case CallState.failed:
              // Fallback for transitional states before returning to idle
              return _buildHomeScreen(agoraService);
          }
        },
      ),
    );
  }

  // ==========================================
  // HOME SCREEN (IDLE)
  // ==========================================
  Widget _buildHomeScreen(AgoraService agoraService) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
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
                  'Calls',
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
                          label: const Text('Audio Call'),
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
                          label: const Text('Video Call'),
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
          
          // History Title
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

          // History List
          Expanded(
            child: agoraService.callHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64.sp, color: colorScheme.surfaceContainerHighest),
                        16.vSpace,
                        Text(
                          'No recent calls',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    itemCount: agoraService.callHistory.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
                    itemBuilder: (context, index) {
                      final call = agoraService.callHistory[index];
                      return _buildHistoryItem(call, colorScheme);
                    },
                  ),
          ),
        ],
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

  String _formatSimpleDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  Widget _buildHistoryItem(CallHistoryItem call, ColorScheme colorScheme) {
    // Determine icon and colors
    IconData callIcon;
    Color callIconColor;
    
    if (call.status == 'Missed' || call.status == 'Declined' || call.status == 'Rejected' || call.status == 'No Answer' || call.status == 'Cancelled') {
      callIconColor = colorScheme.error;
      callIcon = call.isOutgoing ? Icons.call_missed_outgoing : Icons.call_missed;
    } else {
      callIconColor = colorScheme.primary;
      callIcon = call.isOutgoing ? Icons.call_made : Icons.call_received;
    }

    final timeString = _formatSimpleTime(call.timestamp);
    final dateString = _formatSimpleDate(call.timestamp);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      leading: CircleAvatar(
        radius: 24.r,
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          call.remoteUserId.isNotEmpty ? call.remoteUserId.substring(0, 1).toUpperCase() : '?',
          style: TextStyle(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      title: Text(
        'User ${call.remoteUserId}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          fontSize: 16.sp,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(callIcon, size: 14.sp, color: callIconColor),
          6.hSpace,
          Text(
            '${call.isAudio ? 'Audio' : 'Video'} • ${call.status}',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13.sp),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeString,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12.sp),
          ),
          4.vSpace,
          Text(
            dateString,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12.sp),
          ),
        ],
      ),
      onTap: () {
        _targetIdController.text = call.remoteUserId;
        _targetIdFocus.requestFocus();
      },
    );
  }

  // ==========================================
  // INCOMING CALL SCREEN
  // ==========================================
  Widget _buildIncomingCallScreen(AgoraService agoraService) {
    return _buildFullScreenCallUI(
      agoraService: agoraService,
      title: 'Incoming ${agoraService.isAudioCall ? 'Audio' : 'Video'} Call',
      subtitle: 'User ${agoraService.currentCallerId ?? 'Unknown'}',
      isIncoming: true,
      bottomControls: Padding(
        padding: EdgeInsets.only(bottom: 60.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCircularAction(
              icon: Icons.close,
              label: 'Decline',
              color: Colors.redAccent,
              onPressed: () => agoraService.rejectCall(),
            ),
            _buildCircularAction(
              icon: Icons.call,
              label: 'Accept',
              color: Colors.green,
              onPressed: () => agoraService.acceptCall(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // OUTGOING CALL SCREEN
  // ==========================================
  Widget _buildOutgoingCallScreen(AgoraService agoraService) {
    return _buildFullScreenCallUI(
      agoraService: agoraService,
      title: 'Calling...',
      subtitle: 'User ${agoraService.currentCallerId ?? 'Unknown'}',
      isIncoming: false,
      bottomControls: Padding(
        padding: EdgeInsets.only(bottom: 60.h),
        child: _buildCircularAction(
          icon: Icons.call_end,
          label: 'Cancel',
          color: Colors.redAccent,
          onPressed: () => agoraService.endCall(),
        ),
      ),
    );
  }

  // ==========================================
  // ACTIVE CALL SCREEN
  // ==========================================
  Widget _buildActiveCallScreen(AgoraService agoraService) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background (Video or Avatar)
          if (!agoraService.isAudioCall)
            _buildRemoteVideo(agoraService)
          else
            _buildAudioCallBackground(agoraService),
            
          // Top Info Area
          Positioned(
            top: 50.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'User ${agoraService.currentCallerId}',
                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold, shadows: const [Shadow(blurRadius: 4, color: Colors.black54)]),
                ),
                8.vSpace,
                _buildConnectionStatusPill(agoraService),
              ],
            ),
          ),
          
          // Floating Self Preview (Video Only)
          if (!agoraService.isAudioCall && agoraService.isJoined)
            Positioned(
              top: 50.h,
              right: 20.w,
              child: _buildSelfPreview(agoraService),
            ),
            
          // Bottom Controls Dock
          Positioned(
            bottom: 40.h,
            left: 20.w,
            right: 20.w,
            child: _buildActiveControls(agoraService, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioCallBackground(AgoraService agoraService) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(40.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: Icon(Icons.person, size: 100.w, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteVideo(AgoraService agoraService) {
    if (!agoraService.isJoined || agoraService.remoteUids.isEmpty) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Text(
            'Waiting for video...',
            style: TextStyle(color: Colors.white54, fontSize: 16.sp),
          ),
        ),
      );
    }
    
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
  }

  Widget _buildSelfPreview(AgoraService agoraService) {
    return Container(
      width: 100.w,
      height: 150.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.black87,
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: agoraService.isVideoOff
          ? Center(child: Icon(Icons.videocam_off, color: Colors.white, size: 30.sp))
          : AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: agoraService.engine,
                canvas: const VideoCanvas(
                  uid: 0,
                  renderMode: RenderModeType.renderModeHidden,
                ),
              ),
            ),
    );
  }

  Widget _buildActiveControls(AgoraService agoraService, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: agoraService.isMuted ? Icons.mic_off : Icons.mic,
                isActive: agoraService.isMuted,
                activeColor: Colors.white,
                inactiveColor: Colors.white54,
                activeBg: Colors.white.withOpacity(0.3),
                onPressed: () => agoraService.toggleMute(),
              ),
              if (!agoraService.isAudioCall) ...[
                _buildControlButton(
                  icon: agoraService.isVideoOff ? Icons.videocam_off : Icons.videocam,
                  isActive: agoraService.isVideoOff,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white54,
                  activeBg: Colors.white.withOpacity(0.3),
                  onPressed: () => agoraService.toggleVideo(),
                ),
                _buildControlButton(
                  icon: Icons.flip_camera_ios,
                  isActive: false,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white,
                  activeBg: Colors.transparent,
                  onPressed: () => agoraService.switchCamera(),
                ),
              ],
              _buildControlButton(
                icon: agoraService.isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                isActive: !agoraService.isSpeakerOn, // Highlight if off
                activeColor: Colors.white,
                inactiveColor: Colors.white,
                activeBg: Colors.white.withOpacity(0.3),
                onPressed: () => agoraService.toggleSpeaker(),
              ),
              _buildControlButton(
                icon: Icons.call_end,
                isActive: true,
                activeColor: Colors.white,
                inactiveColor: Colors.white,
                activeBg: Colors.redAccent,
                onPressed: () => agoraService.endCall(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon, 
    required bool isActive, 
    required Color activeColor, 
    required Color inactiveColor, 
    required Color activeBg, 
    required VoidCallback onPressed
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? activeBg : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isActive ? activeColor : inactiveColor,
          size: 26.sp,
        ),
      ),
    );
  }

  // ==========================================
  // REUSABLE COMPONENTS
  // ==========================================
  
  Widget _buildFullScreenCallUI({
    required AgoraService agoraService,
    required String title,
    required String subtitle,
    required bool isIncoming,
    required Widget bottomControls,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            60.vSpace,
            // Caller Avatar
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  )
                ],
              ),
              child: Center(
                child: Text(
                  agoraService.currentCallerId != null && agoraService.currentCallerId!.isNotEmpty 
                      ? agoraService.currentCallerId!.substring(0, 1).toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            40.vSpace,
            // Info text
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            12.vSpace,
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            // Bottom Controls
            bottomControls,
          ],
        ),
      ),
    );
  }

  Widget _buildCircularAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: EdgeInsets.all(20.w),
            elevation: 8,
            shadowColor: color.withOpacity(0.5),
          ),
          child: Icon(icon, size: 32.sp),
        ),
        12.vSpace,
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildConnectionStatusPill(AgoraService agoraService) {
    String statusText = '';
    Color statusColor = Colors.grey;

    if (agoraService.callState == CallState.connected && agoraService.isJoined) {
      statusText = _formatDuration(agoraService.callDuration);
      statusColor = Colors.greenAccent;
    } else {
      switch (agoraService.connectionState) {
        case ConnectionStateType.connectionStateDisconnected:
        case ConnectionStateType.connectionStateFailed:
          statusText = 'Disconnected';
          statusColor = Colors.redAccent;
          break;
        case ConnectionStateType.connectionStateConnecting:
          statusText = 'Connecting...';
          statusColor = Colors.orangeAccent;
          break;
        case ConnectionStateType.connectionStateConnected:
          statusText = 'Connected';
          statusColor = Colors.greenAccent;
          break;
        case ConnectionStateType.connectionStateReconnecting:
          statusText = 'Reconnecting...';
          statusColor = Colors.orangeAccent;
          break;
      }
    }

    if (statusText.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white24, width: 1),
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
              boxShadow: [BoxShadow(color: statusColor, blurRadius: 4)],
            ),
          ),
          8.hSpace,
          Text(
            statusText,
            style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

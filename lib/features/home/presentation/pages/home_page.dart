import 'package:flutter/material.dart';
import 'package:agora_connect/features/call/presentation/pages/call_page.dart';
import 'package:agora_connect/features/home/presentation/pages/home_dashboard_page.dart';
import 'package:agora_connect/features/chat/presentation/pages/chat_list_page.dart';
import 'package:agora_connect/features/call/presentation/pages/call_history_page.dart';
import 'package:agora_connect/features/profile/presentation/pages/profile_page.dart';

import 'package:agora_connect/core/services/agora_service.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeDashboardPage(),
    const ChatListPage(),
    const CallHistoryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AgoraService>(
      builder: (agoraService) {
        final isIdle =
            agoraService.callState == CallState.idle ||
            agoraService.callState == CallState.rejected ||
            agoraService.callState == CallState.ended ||
            agoraService.callState == CallState.failed;

        // If not idle, show the active call UI over everything
        if (!isIdle) {
          return const CallPage();
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: 'Chats',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

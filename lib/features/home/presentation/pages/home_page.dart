import 'package:flutter/material.dart';
import 'package:agora_connect/features/call/presentation/pages/call_page.dart';
import 'package:agora_connect/features/chat/presentation/pages/chat_list_page.dart';

import 'package:agora_connect/core/services/agora_service.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [const CallPage(), const ChatListPage()];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AgoraService>(
      builder: (agoraService) {
        final isIdle =
            agoraService.callState == CallState.idle ||
            agoraService.callState == CallState.rejected ||
            agoraService.callState == CallState.ended ||
            agoraService.callState == CallState.failed;

        return Scaffold(
          body: _pages[_currentIndex],
          bottomNavigationBar: isIdle
              ? NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.call_outlined),
                      selectedIcon: Icon(Icons.call),
                      label: 'Calls',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.chat_bubble_outline),
                      selectedIcon: Icon(Icons.chat_bubble),
                      label: 'Chats',
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}

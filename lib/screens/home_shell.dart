import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'talk_screen.dart';
import 'feelings_screen.dart';
import 'schedule_screen.dart';
import 'parent/parent_gate.dart';
import 'parent/parent_area.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _childScreens = [
    TalkScreen(),
    FeelingsScreen(),
    ScheduleScreen(),
  ];

  void _openParent() {
    final route = MaterialPageRoute(
      builder: (_) =>
          appState.childLockEnabled ? const ParentGate() : const ParentArea(),
    );
    Navigator.push(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        // Child-paired device: never show the Parent tab. Parent area would
        // also fail to do anything useful since the device has no parent
        // auth session.
        final showParent = !appState.isChildDevice;

        return Scaffold(
          backgroundColor: AppColors.tealBg,
          body: IndexedStack(index: _index, children: _childScreens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) {
              if (showParent && i == 3) {
                _openParent();
              } else {
                setState(() => _index = i);
              }
            },
            backgroundColor: Colors.white,
            indicatorColor: AppColors.tealLight,
            destinations: [
              const NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  selectedIcon:
                      Icon(Icons.chat_bubble, color: AppColors.tealDark),
                  label: 'Talk'),
              const NavigationDestination(
                  icon: Icon(Icons.emoji_emotions_outlined),
                  selectedIcon:
                      Icon(Icons.emoji_emotions, color: AppColors.tealDark),
                  label: 'Feelings'),
              const NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon:
                      Icon(Icons.calendar_today, color: AppColors.tealDark),
                  label: 'My day'),
              if (showParent)
                const NavigationDestination(
                    icon: Icon(Icons.lock_outline), label: 'Parent'),
            ],
          ),
        );
      },
    );
  }
}

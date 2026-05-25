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
        final showParent = !appState.isChildDevice;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFA),
          body: IndexedStack(index: _index, children: _childScreens),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.chat,
                    label: 'Talk',
                    isSelected: _index == 0,
                    onTap: () => setState(() => _index = 0),
                  ),
                  _NavItem(
                    icon: Icons.mood,
                    label: 'Feelings',
                    isSelected: _index == 1,
                    onTap: () => setState(() => _index = 1),
                  ),
                  _NavItem(
                    icon: Icons.calendar_today,
                    label: 'My Day',
                    isSelected: _index == 2,
                    onTap: () => setState(() => _index = 2),
                  ),
                  if (showParent)
                    _NavItem(
                      icon: Icons.lock,
                      label: 'Parent',
                      isSelected: false,
                      onTap: _openParent,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 24 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4DB6AC).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00433F) : const Color(0xFF6D7A77),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF00433F) : const Color(0xFF6D7A77),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

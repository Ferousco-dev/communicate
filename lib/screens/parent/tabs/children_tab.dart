import 'dart:io';
import 'package:flutter/material.dart';

import '../../../state/app_state.dart';
import '../../../theme/app_theme.dart';
import '../../child_profile/child_profile_setup_screen.dart';
import '../../child_profile/link_code_share_screen.dart';

class ChildrenTab extends StatelessWidget {
  const ChildrenTab({super.key});

  void _add(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChildProfileSetupScreen(showLinkCodeOnSave: false),
      ),
    );
  }

  void _showCode(BuildContext context, child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LinkCodeShareScreen(child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final children = appState.children;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFA),
          floatingActionButton: FloatingActionButton.large(
            onPressed: () => _add(context),
            backgroundColor: const Color(0xFF006A63),
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 36),
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Children',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DB6AC).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${children.length} PROFILES',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF006A63), letterSpacing: 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Children Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, // Single column for mobile simplicity as per reference card density
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.1,
                ),
                itemCount: children.length + 1,
                itemBuilder: (context, index) {
                  if (index == children.length) {
                    return _NewProfileCard(onTap: () => _add(context));
                  }

                  final child = children[index];
                  final isActive = appState.activeChild?.id == child.id;

                  return _ChildCard(
                    child: child,
                    isActive: isActive,
                    onSelect: () => appState.setActiveChild(child),
                    onPair: () => _showCode(context, child),
                    onEdit: () {
                      // Navigate to edit (reuse setup screen for now)
                    },
                  );
                },
              ),

              const SizedBox(height: 48),

              // Usage Overview Section
              const Text(
                'USAGE OVERVIEW',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF6D7A77)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _OverviewStatCard(
                      icon: Icons.chat,
                      label: 'Total Communication',
                      value: '${appState.totalWordsUsed}',
                      color: const Color(0xFF006A63),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _OverviewStatCard(
                      icon: Icons.bolt,
                      label: 'Active Sessions',
                      value: '14', // Mocked as per reference
                      color: const Color(0xFFBA7517),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 100), // Bottom nav space
            ],
          ),
        );
      },
    );
  }
}

class _ChildCard extends StatelessWidget {
  final dynamic child;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onPair;
  final VoidCallback onEdit;

  const _ChildCard({
    required this.child,
    required this.isActive,
    required this.onSelect,
    required this.onPair,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive ? const Color(0xFF006A63) : const Color(0xFFBDC9C6).withOpacity(0.3),
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Avatar Area
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? const Color(0xFF006A63) : const Color(0xFF84D7FD),
                    width: 4,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFF2F4F4),
                  foregroundImage: child.avatarPath != null && !child.avatarPath!.startsWith('icon:')
                      ? FileImage(File(child.avatarPath!))
                      : null,
                  child: child.avatarPath == null || child.avatarPath!.startsWith('icon:')
                      ? const Icon(Icons.child_care, size: 48, color: Color(0xFF006A63))
                      : null,
                ),
              ),
              if (isActive)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006A63),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.verified, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            child.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
          ),
          const Text(
            '"Talks with pictures"', // Mocked status as per reference
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xFF3D4947)),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          ElevatedButton.icon(
            onPressed: onSelect,
            icon: const Icon(Icons.login),
            label: const Text('Select Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBEE9FF),
              foregroundColor: const Color(0xFF005D79),
              elevation: 0,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3D4947),
                    side: const BorderSide(color: Color(0xFFBDC9C6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPair,
                  icon: const Icon(Icons.qr_code_2, size: 18),
                  label: const Text('Pair'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3D4947),
                    side: const BorderSide(color: Color(0xFFBDC9C6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewProfileCard extends StatelessWidget {
  final VoidCallback onTap;
  const _NewProfileCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFBDC9C6), style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: Color(0xFFBDC9C6), shape: BoxShape.circle),
              child: const Icon(Icons.add, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'New Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
            ),
            const Text(
              'Add another child to your account',
              style: TextStyle(fontSize: 14, color: Color(0xFF3D4947)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _OverviewStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6D7A77), fontWeight: FontWeight.w600)),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191C1D))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

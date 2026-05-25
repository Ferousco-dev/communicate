import 'dart:io';
import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'child_profile_setup_screen.dart';

class ChildProfileSelectScreen extends StatelessWidget {
  const ChildProfileSelectScreen({super.key});

  void _add(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChildProfileSetupScreen(showLinkCodeOnSave: false),
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
          body: Stack(
            children: [
              // Calming Background Shapes
              Positioned(
                top: 80,
                left: 10,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFF84D7FD).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 150,
                right: 10,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB4A835).withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Top App Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 48), // Spacer for symmetry
                          const Text(
                            'CommuniCare',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006A63),
                              letterSpacing: -0.5,
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFFECEEEE),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.settings, color: Color(0xFF3D4947), size: 28),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Welcome Prompt
                              const Text(
                                'Hello!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF191C1D),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Who is using the app today?',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFF3D4947),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 48),

                              // Profiles Grid
                              Wrap(
                                spacing: 40,
                                runSpacing: 40,
                                alignment: WrapAlignment.center,
                                children: [
                                  for (final child in children)
                                    _ProfileButton(
                                      name: child.name,
                                      avatarPath: child.avatarPath,
                                      onTap: () => appState.setActiveChild(child),
                                      isActive: appState.activeChild?.id == child.id,
                                    ),
                                ],
                              ),

                              const SizedBox(height: 64),

                              // Add Profile Button
                              OutlinedButton.icon(
                                onPressed: () => _add(context),
                                icon: const Icon(Icons.add_circle, color: Color(0xFF3D4947)),
                                label: const Text(
                                  'Add New Profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3D4947),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  side: const BorderSide(color: Color(0xFFBDC9C6), width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String name;
  final String? avatarPath;
  final bool isActive;
  final VoidCallback onTap;

  const _ProfileButton({
    required this.name,
    this.avatarPath,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIconAvatar = avatarPath != null && avatarPath!.startsWith('icon:');

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 160,
                height: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF006A63).withOpacity(0.1) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: avatarPath != null && !isIconAvatar
                      ? Image.file(File(avatarPath!), fit: BoxFit.cover)
                      : Center(
                          child: Icon(
                            Icons.child_care,
                            size: 80,
                            color: isActive ? const Color(0xFF006A63) : const Color(0xFFBDC9C6),
                          ),
                        ),
                ),
              ),
              if (isActive)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF006A63),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 32),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF006A63) : const Color(0xFF191C1D),
            ),
          ),
        ],
      ),
    );
  }
}

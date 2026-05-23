import 'dart:io';
import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import 'child_profile_setup_screen.dart';

/// "Which child is using the app today?" — shown after sign-in when the
/// parent has more than one profile and none is currently active.
class ChildProfileSelectScreen extends StatelessWidget {
  const ChildProfileSelectScreen({super.key});

  void _add(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              const ChildProfileSetupScreen(showLinkCodeOnSave: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final children = appState.children;
        return Scaffold(
          backgroundColor: AppColors.tealBg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Who's using the app?",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF04342C))),
                  const SizedBox(height: 6),
                  const Text(
                    "Pick a child profile to continue.",
                    style: TextStyle(color: AppColors.muted, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: children.length + 1,
                      itemBuilder: (_, i) {
                        if (i == children.length) {
                          return _AddTile(onTap: () => _add(context));
                        }
                        final c = children[i];
                        return _ProfileTile(
                          name: c.name,
                          avatarPath: c.avatarPath,
                          age: c.age,
                          onTap: () => appState.setActiveChild(c),
                        );
                      },
                    ),
                  ),
                  if (children.isNotEmpty)
                    PrimaryButton(
                      label: appState.activeChild == null
                          ? 'Tap a profile above'
                          : 'Continue as ${appState.activeChild!.name}',
                      onPressed: appState.activeChild == null
                          ? null
                          : () {
                              // AuthGate is listening and will swap to HomeShell
                              // on the next build now that activeChild != null.
                            },
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

class _ProfileTile extends StatelessWidget {
  final String name;
  final String? avatarPath;
  final int? age;
  final VoidCallback onTap;
  const _ProfileTile({
    required this.name,
    required this.avatarPath,
    required this.age,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = appState.activeChild?.name == name;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? AppColors.teal : AppColors.line,
              width: active ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(50),
                ),
                clipBehavior: Clip.antiAlias,
                child: avatarPath != null
                    ? Image.file(File(avatarPath!), fit: BoxFit.cover)
                    : const Icon(Icons.child_care,
                        size: 40, color: AppColors.tealDark),
              ),
              const SizedBox(height: 10),
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              if (age != null)
                Text('age $age',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.tealLight,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppColors.tealMid, width: 1.4),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 36, color: AppColors.tealDark),
              SizedBox(height: 8),
              Text('Add a child',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.tealDark)),
            ],
          ),
        ),
      ),
    );
  }
}

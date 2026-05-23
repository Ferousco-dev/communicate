import 'dart:io';
import 'package:flutter/material.dart';

import '../../../state/app_state.dart';
import '../../../theme/app_theme.dart';
import '../../child_profile/child_profile_setup_screen.dart';
import '../../child_profile/link_code_share_screen.dart';

/// Parent dashboard "Children" tab — list every profile under this parent,
/// pick which one is active, add another, or open the link-code share screen.
class ChildrenTab extends StatelessWidget {
  const ChildrenTab({super.key});

  void _add(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const ChildProfileSetupScreen(showLinkCodeOnSave: false),
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

  Future<void> _confirmRemove(BuildContext context, child) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Remove ${child.name}?'),
        content: const Text(
          "This deletes the profile and its cards/schedule/mood log "
          "from this device. You can't undo it.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true) appState.removeChildProfile(child);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final children = appState.children;
        return Scaffold(
          backgroundColor: AppColors.tealBg,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.teal,
            onPressed: () => _add(context),
            icon: const Icon(Icons.add),
            label: const Text('Add child'),
          ),
          body: children.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: children.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final c = children[i];
                    final active = appState.activeChild?.id == c.id;
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: active ? AppColors.teal : AppColors.line,
                          width: active ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.tealLight,
                              foregroundImage: c.avatarPath != null
                                  ? FileImage(File(c.avatarPath!))
                                  : null,
                              child: c.avatarPath == null
                                  ? const Icon(Icons.child_care,
                                      color: AppColors.tealDark)
                                  : null,
                            ),
                            title: Text(c.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              [
                                if (c.age != null) 'age ${c.age}',
                                if (active) 'active',
                              ].join(' · '),
                              style: const TextStyle(color: AppColors.muted),
                            ),
                            trailing: active
                                ? const Icon(Icons.check_circle,
                                    color: AppColors.teal)
                                : TextButton(
                                    onPressed: () =>
                                        appState.setActiveChild(c),
                                    child: const Text('Use'),
                                  ),
                          ),
                          const Divider(height: 1),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: () => _showCode(context, c),
                                  icon: const Icon(Icons.qr_code_2,
                                      color: AppColors.tealDark),
                                  label: const Text("Share code",
                                      style: TextStyle(
                                          color: AppColors.tealDark)),
                                ),
                              ),
                              Container(
                                  height: 28, width: 1, color: AppColors.line),
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: () => _confirmRemove(context, c),
                                  icon: const Icon(Icons.delete_outline,
                                      color: AppColors.coral),
                                  label: const Text("Remove",
                                      style:
                                          TextStyle(color: AppColors.coral)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.family_restroom,
                  size: 44, color: AppColors.tealDark),
            ),
            const SizedBox(height: 16),
            const Text('No child profiles yet',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text(
              "Tap 'Add child' to create one. You can share a code "
              "to pair the child's own device.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

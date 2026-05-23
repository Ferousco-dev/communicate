import 'package:flutter/material.dart';

import '../../../config/env.dart';
import '../../../services/auth_service.dart';
import '../../../state/app_state.dart';
import '../../../theme/app_theme.dart';

/// Parent dashboard "Settings" tab — sensory mode, sound, child lock, log out.
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              value: appState.sensoryMode,
              activeColor: AppColors.teal,
              title: const Text('Sensory / quiet mode'),
              subtitle: const Text('Softer colours and calmer feedback'),
              onChanged: appState.setSensory,
            ),
            SwitchListTile(
              value: appState.soundOn,
              activeColor: AppColors.teal,
              title: const Text('Speak aloud'),
              subtitle: const Text('Turn the voice on or off'),
              onChanged: appState.setSound,
            ),
            SwitchListTile(
              value: appState.childLockEnabled,
              activeColor: AppColors.teal,
              title: const Text('Child lock'),
              subtitle: const Text('Ask a grown-up before opening this area'),
              onChanged: appState.setChildLock,
            ),
            const SizedBox(height: 20),
            if (Env.isConfigured && AuthService.instance.isLoggedIn)
              _AccountSection(
                email: AuthService.instance.currentUser?.email ?? '',
              ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'CommuniCare is a communication support tool, not a medical '
                'device or a replacement for therapy.',
                style: TextStyle(color: AppColors.tealDark, fontSize: 13),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AccountSection extends StatelessWidget {
  final String email;
  const _AccountSection({required this.email});

  Future<void> _confirmLogOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          "You'll need to log back in to see your child's cards and progress.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await AuthService.instance.signOut();
      // AuthGate listens to onAuthStateChange and swaps to the auth flow on
      // its own. Pop the parent dashboard out of the way so the gate is on top.
      if (context.mounted) {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text('Account',
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.mail_outline, color: AppColors.muted),
                title: Text(email,
                    style: const TextStyle(fontSize: 14)),
                subtitle: const Text('Signed in as parent'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.coral),
                title: const Text('Log out',
                    style: TextStyle(color: AppColors.coral)),
                onTap: () => _confirmLogOut(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

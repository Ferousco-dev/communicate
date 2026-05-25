import 'package:flutter/material.dart';

import '../../../config/env.dart';
import '../../../services/auth_service.dart';
import '../../../state/app_state.dart';
import '../../../theme/app_theme.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

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
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD85A30)), // coral
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await AuthService.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Header Info Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFBDC9C6).withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PARENT DASHBOARD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF006A63))),
                  SizedBox(height: 8),
                  Text('Manage accessibility', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF191C1D))),
                  SizedBox(height: 8),
                  Text("Customize the experience for your child's specific sensory needs.", style: TextStyle(fontSize: 16, color: Color(0xFF3D4947))),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Sensory & Safety Group
            const Text('SENSORY & SAFETY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF6D7A77))),
            const SizedBox(height: 16),
            _SettingToggle(
              icon: Icons.visibility_off,
              title: 'Sensory mode',
              subtitle: 'Reduce animations and high contrast',
              value: appState.sensoryMode,
              onChanged: appState.setSensory,
            ),
            const SizedBox(height: 12),
            _SettingToggle(
              icon: Icons.lock,
              title: 'Child lock',
              subtitle: 'Prevent accidental app exiting',
              value: appState.childLockEnabled,
              onChanged: appState.setChildLock,
            ),

            const SizedBox(height: 40),

            // Voice & Audio Group
            const Text('VOICE & AUDIO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF6D7A77))),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFBDC9C6).withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: const Color(0xFF4DB6AC).withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.record_voice_over, color: Color(0xFF006A63)),
                    ),
                    title: const Text('Sound/TTS settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 80),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(color: const Color(0xFF4DB6AC).withOpacity(0.1), shape: BoxShape.circle),
                                  child: const Icon(Icons.volume_up, color: Color(0xFF006A63), size: 20),
                                ),
                                const SizedBox(width: 16),
                                const Text('Feedback volume', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                            const Text('80%', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006A63))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.8,
                            minHeight: 8,
                            backgroundColor: Color(0xFFECEEEE),
                            valueColor: AlwaysStoppedAnimation(Color(0xFF006A63)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Danger Zone
            ElevatedButton.icon(
              onPressed: () => _confirmLogOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('Log out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFDAD6), // error-container
                foregroundColor: const Color(0xFF93000A), // on-error-container
                elevation: 0,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'App Version 2.4.0 (Cognitive Calm)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6D7A77), fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: Color(0xFFBEE9FF), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF005D79)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF191C1D))),
                Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF3D4947))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF006A63),
            activeTrackColor: const Color(0xFF4DB6AC).withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}

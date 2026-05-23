import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import 'child_code_entry_screen.dart';
import 'sign_up_screen.dart';
import 'log_in_screen.dart';

/// Landing screen after onboarding: "create a parent account or log in".
/// Parent-facing copy — never shown to the child.
class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  void _goSignUp(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SignUpScreen()),
      );

  void _goLogIn(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LogInScreen()),
      );

  void _goCodeEntry(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChildCodeEntryScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tealBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.family_restroom,
                    size: 52, color: AppColors.tealDark),
              ),
              const SizedBox(height: 24),
              const Text('Welcome, parent',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF04342C))),
              const SizedBox(height: 8),
              const Text(
                "Create an account to keep your child's cards, "
                'feelings and progress safe across devices.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: AppColors.muted, height: 1.5),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Create an account',
                onPressed: () => _goSignUp(context),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'I already have an account',
                onPressed: () => _goLogIn(context),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.line)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("child's device",
                        style: TextStyle(
                            fontSize: 12, color: AppColors.muted)),
                  ),
                  Expanded(child: Divider(color: AppColors.line)),
                ],
              ),
              const SizedBox(height: 16),
              SecondaryButton(
                label: 'I have a code from my parent',
                onPressed: () => _goCodeEntry(context),
                icon: Icons.qr_code_2,
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "CommuniCare is a support tool — not a medical device. "
                  "Your child's data belongs to you.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

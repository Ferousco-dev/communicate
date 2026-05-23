import 'dart:async';
import 'package:flutter/material.dart';

import '../config/env.dart';
import '../theme/app_theme.dart';
import 'auth/auth_gate.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1900), () {
      if (!mounted) return;
      // If Supabase is configured, the AuthGate decides whether to send the
      // user into the app or the auth flow. If not, fall back to the old
      // onboarding-only flow so devs without keys can still run the app.
      final next = Env.isConfigured
          ? const AuthGate()
          : const OnboardingScreen();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => next),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tealDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.tealMid,
                borderRadius: BorderRadius.circular(36),
              ),
              child: const Icon(Icons.chat_bubble_outline,
                  size: 60, color: Color(0xFF04342C)),
            ),
            const SizedBox(height: 24),
            const Text('CommuniCare',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 10),
            const Text('A friendly way to talk and feel',
                style: TextStyle(fontSize: 14, color: AppColors.tealMid)),
          ],
        ),
      ),
    );
  }
}

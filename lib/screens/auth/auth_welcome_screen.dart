import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'child_code_entry_screen.dart';
import 'sign_up_screen.dart';
import 'log_in_screen.dart';

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
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.5,
                  colors: [
                    Color(0xFFF8FAFA), // surface
                    Color(0xFFBEE9FF), // secondary-fixed
                  ],
                ),
              ),
            ),
          ),

          // Atmospheric Ambient Glows
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF8EF4E9).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFBEE9FF).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                children: [
                  // Top Branding Section
                  Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4DB6AC), // primary-container
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF006A63).withOpacity(0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.family_restroom,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'CommuniCare',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006A63),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Building bridges for communication through calm and care.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF3D4947),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Bento Action Cards
                  Column(
                    gap: 16,
                    children: [
                      _BentoActionCard(
                        title: 'Create Account',
                        subtitle: 'For Parents & Educators',
                        icon: Icons.person_add,
                        iconBgColor: const Color(0xFF84D7FD),
                        onTap: () => _goSignUp(context),
                      ),
                      _BentoActionCard(
                        title: 'I have a Child Code',
                        subtitle: 'Quick sync for children',
                        icon: Icons.vpn_key,
                        iconBgColor: const Color(0xFF71D7CD),
                        onTap: () => _goCodeEntry(context),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Footer
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(color: Color(0xFF3D4947), fontSize: 16),
                          ),
                          GestureDetector(
                            onTap: () => _goLogIn(context),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Color(0xFF006A63),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                                decorationThickness: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 48, height: 1, color: const Color(0xFFBDC9C6)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'SAFE & SECURE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: Color(0xFF6D7A77),
                              ),
                            ),
                          ),
                          Container(width: 48, height: 1, color: const Color(0xFFBDC9C6)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final VoidCallback onTap;

  const _BentoActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: -8,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: const Color(0xFF00433F)),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191C1D),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF3D4947),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFFBDC9C6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../config/env.dart';
import '../theme/app_theme.dart';
import 'auth/auth_welcome_screen.dart';
import 'home_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  final int _numPages = 4;

  void _onNext() {
    if (_currentPage < _numPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    final next = Env.isConfigured ? const AuthWelcomeScreen() : const HomeShell();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => next,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: Stack(
        children: [
          // Background Ambient Glows
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFBEE9FF).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: const Color(0xFF8EF4E9).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main PageView
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (int page) => setState(() => _currentPage = page),
                    children: [
                      const _StepWelcome(),
                      const _StepFeatures(),
                      const _StepProgress(),
                      const _StepEcosystem(),
                    ],
                  ),
                ),

                // Stepper & Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Stepper
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_numPages, (index) {
                          bool isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: isActive ? 32 : 8,
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFF006A63) : const Color(0xFFBDC9C6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // Next Button
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006A63),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: const Color(0xFF006A63).withOpacity(0.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == _numPages - 1 ? 'Get Started' : 'Next',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward),
                            ],
                          ),
                        ),
                      ),

                      // Skip Button
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _finish,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                        ),
                        child: const Text(
                          'Skip for now',
                          style: TextStyle(color: Color(0xFF3D4947), fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Slide 1: Welcome / Help your child express themselves
class _StepWelcome extends StatelessWidget {
  const _StepWelcome();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4DB6AC).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.child_care, color: Color(0xFF006A63), size: 32),
            ),
            const SizedBox(height: 24),
            const Text(
              'Help your child express themselves',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191C1D),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Simple communication made easier',
              style: TextStyle(fontSize: 18, color: Color(0xFF3D4947)),
            ),
            const SizedBox(height: 48),

            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  aspectRatio: 1,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: const Color(0xFF71D7CD).withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF006A63).withOpacity(0.08),
                        blurRadius: 40,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAP1b2FLPkVNnwxQKz0oiH07lAlNKDGTHrBPzh5PHqar5f5sdneFr5rQMr21RaIXVBtLsHARCEwmChbjD_k7RNj0wU207ZaxbLS6n4fieHfRDNaawF6wjKpm2j1gl_37TXQUs-b8OZc0q8x4K-6tgl0EzpnTRTzXquUzDSYV0ReR5ERT7r6VVfIWZTBRwp503qJzI3VaZt46aJVuID-UjIe3lltsgAmVXxQDN7hVMZ_T2ucrlIXV4iwKWU4SZJXY8hTgm-DcxDh2d5N',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFF2F4F4),
                        child: const Icon(Icons.image_outlined, size: 64, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 24,
                  right: 24,
                  child: _FloatingCard(
                    icon: Icons.mood,
                    label: 'Happy',
                    color: Color(0xFF84D7FD),
                  ),
                ),
                const Positioned(
                  bottom: 40,
                  left: 24,
                  child: _FloatingCard(
                    icon: Icons.restaurant,
                    label: 'Hungry',
                    color: Color(0xFF4DB6AC),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Slide 2: Features / Explore your world
class _StepFeatures extends StatelessWidget {
  const _StepFeatures();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hello!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006A63),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings, color: Color(0xFF3D4947)),
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Text(
              'Explore your world',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF191C1D)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap to see what we can do together today!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Color(0xFF3D4947)),
            ),
            const SizedBox(height: 48),

            Row(
              children: [
                Expanded(
                  child: _FeatureCard(
                    icon: Icons.chat,
                    label: 'Talk',
                    color: const Color(0xFF4DB6AC),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _FeatureCard(
                    icon: Icons.mood,
                    label: 'Feelings',
                    color: const Color(0xFF84D7FD),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _FeatureCard(
                    icon: Icons.calendar_today,
                    label: 'My Day',
                    color: const Color(0xFFB4A835),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Slide 3: Progress / Together we grow
class _StepProgress extends StatelessWidget {
  const _StepProgress();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF686000).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.insights, color: Color(0xFF686000), size: 32),
            ),
            const SizedBox(height: 24),
            const Text(
              'See progress grow',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191C1D),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gentle insights for parents into words, feelings, and routines.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Color(0xFF3D4947)),
            ),
            const SizedBox(height: 48),

            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFFECEEEE),
                borderRadius: BorderRadius.circular(40),
                image: const DecorationImage(
                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuD_eMvw0PyMVtpvdMOnlJmSYRuWwPpY0NP2tWPnmhScsAcjph-UNHwdSMoAfSKFgoD9Yee5291rOdpLzAsKvvlxyxh62kUmD2NFifLfw-7uyBjtTGGXoI_BG92SBCdOf5MdcWdBBhVi0SoWfxmewX0PrhL8wufvm2ZeHouOVnf4pkW_KbL9LdPSxyIfs5pJOVC4iICKcay35HcGFTFVCeaaX_21JTglWVNlfDJ9cnemgFGG7rhAWtB9pBzwjW7XpQxfn3gzRARBPOwA'),
                  fit: BoxFit.cover,
                  opacity: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slide 4: Ecosystem / Parents manage. Children communicate.
class _StepEcosystem extends StatelessWidget {
  const _StepEcosystem();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'Parents manage. Children communicate easily.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006A63),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A seamless ecosystem built to bridge the gap with simplicity and care.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF3D4947)),
            ),
            const SizedBox(height: 40),

            // Side-by-Side 3D Device Mockups
            Row(
              children: [
                // Parent Device Mockup
                Expanded(
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(-0.2),
                    child: Container(
                      height: 280,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFBDC9C6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(color: Color(0xFFBEE9FF), shape: BoxShape.circle),
                                child: const Icon(Icons.family_restroom, size: 14, color: Color(0xFF005D79)),
                              ),
                              const SizedBox(width: 8),
                              const Text('Dashboard', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF006A63))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Mini Graph Card
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE1E3E3)), borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Weekly Progress', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Container(height: 6, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFFECEEEE), borderRadius: BorderRadius.circular(3)), child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: 0.65, child: Container(decoration: BoxDecoration(color: const Color(0xFF006A63), borderRadius: BorderRadius.circular(3))))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: Container(height: 40, decoration: BoxDecoration(color: const Color(0xFFF2F4F4), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFBDC9C6))), child: const Icon(Icons.dashboard_customize, size: 16, color: Color(0xFF006685)))),
                              const SizedBox(width: 8),
                              Expanded(child: Container(height: 40, decoration: BoxDecoration(color: const Color(0xFFF2F4F4), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFBDC9C6))), child: const Icon(Icons.settings, size: 16, color: Color(0xFF006685)))),
                            ],
                          ),
                          const Spacer(),
                          Container(height: 32, width: double.infinity, decoration: BoxDecoration(border: Border.all(color: const Color(0xFFBDC9C6), style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('+ Add Routine', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Child Device Mockup
                Expanded(
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(0.2),
                    child: Container(
                      height: 280,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF4DB6AC), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4DB6AC).withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Hello!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF006A63))),
                              Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF4DB6AC)), image: const DecorationImage(image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuB6Dp_ZrJ2dEqr9oioctMiBPp5nPhLM6dqsbWEox4iYB0WNWbqiPm5QPDnTv8rQ4hAWBXanjlvFKl7ALlWuRdNarcfuoLWIkCCdzME_qlWt9037Ufhp9GobJabU7ovU6JZ1IoHEedN5R2JcEqRk_-vh-dHt72dPHJxfZKesCZFCpAJJfKSGUFYSZLW9HRu_x5Tc8-ExNu5KUe4Rp7ScA-vTyKLv2-0loVD4Hhqp9cI0V7FTmdBn8k1wLfpQ3c6dCAGsnwLYD4cIGo3r'), fit: BoxFit.cover))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _miniTile(Icons.chat, const Color(0xFF84D7FD)),
                                _miniTile(Icons.mood, const Color(0xFF84D7FD)),
                                _miniTile(Icons.calendar_today, const Color(0xFF84D7FD)),
                                Container(decoration: BoxDecoration(color: const Color(0xFFE6E8E8), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.add, size: 16, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniTile(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: const Color(0xFF005D79)),
      ),
    );
  }
}

class _FloatingCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FloatingCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD3D1C7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF191C1D)),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 36),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3D4947),
          ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class FeelingsScreen extends StatefulWidget {
  const FeelingsScreen({super.key});

  @override
  State<FeelingsScreen> createState() => _FeelingsScreenState();
}

class _FeelingsScreenState extends State<FeelingsScreen> {
  CommCard? _activeFeeling;
  bool _showSuccess = false;

  void _onTap(CommCard feeling) {
    setState(() {
      _activeFeeling = feeling;
      _showSuccess = true;
    });

    appState.logMood(feeling);

    // Haptic feedback
    if (appState.sensoryMode == false) {
      HapticFeedback.mediumImpact();
    }

    // Hide success message after a delay
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _showSuccess = false;
          _activeFeeling = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final sensory = appState.sensoryMode;
        final feelings = appState.feelings;

        return Scaffold(
          body: Stack(
            children: [
              // 1. Background Gradient/Mesh
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.5,
                      colors: [
                        Color(0xFFBEE9FF), // secondary-fixed
                        Color(0xFFF8FAFA), // surface
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Main Content
              SafeArea(
                child: Column(
                  children: [
                    _header(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Column(
                          children: [
                            // Asymmetric Grid for Emotions
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: feelings.length,
                              itemBuilder: (context, index) {
                                final f = feelings[index];
                                final isActive = _activeFeeling?.label == f.label;
                                return _FeelingCard(
                                  feeling: f,
                                  isActive: isActive,
                                  sensory: sensory,
                                  onTap: () => _onTap(f),
                                );
                              },
                            ),

                            const SizedBox(height: 32),

                            // Contextual Insight Card
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFBEE9FF).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF84D7FD),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.lightbulb,
                                      color: Color(0xFF005D79),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      "It's okay to feel however you feel right now. You are doing a great job!",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF001F2A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 100), // Navigation spacer
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Success Feedback Overlay
              if (_showSuccess)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.05),
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF84D7FD), // secondary-container
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite,
                                size: 64,
                                color: Color(0xFF005D79),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "You feel ${_activeFeeling?.label ?? ''}!",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF001F2A),
                                ),
                              ),
                              const Text(
                                "Thank you for sharing",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF005D79),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _header() {
    final activeChild = appState.activeChild;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF84D7FD),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4DB6AC), width: 2),
            ),
            child: const Center(
              child: Icon(Icons.person, color: Color(0xFF005D79), size: 28),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'How do you feel?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006A63),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF006A63), size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _FeelingCard extends StatelessWidget {
  final CommCard feeling;
  final bool isActive;
  final bool sensory;
  final VoidCallback onTap;

  const _FeelingCard({
    required this.feeling,
    required this.isActive,
    required this.sensory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = calmIf(sensory, feeling.color);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? const Color(0xFF006A63) : Colors.transparent,
            width: 4,
          ),
          boxShadow: [
            if (!isActive)
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  feeling.icon,
                  size: 64,
                  color: accent,
                ),
                const SizedBox(height: 12),
                Text(
                  feeling.label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191C1D),
                  ),
                ),
              ],
            ),
            if (isActive)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF006A63),
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

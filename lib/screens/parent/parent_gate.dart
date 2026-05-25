import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'parent_area.dart';

class ParentGate extends StatefulWidget {
  const ParentGate({super.key});

  @override
  State<ParentGate> createState() => _ParentGateState();
}

class _ParentGateState extends State<ParentGate> {
  late int _a;
  late int _b;
  String _userAnswer = "";
  bool _success = false;
  bool _shaking = false;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  void _newQuestion() {
    final r = Random();
    _a = 2 + r.nextInt(8);
    _b = 2 + r.nextInt(8);
  }

  void _append(int num) {
    if (_userAnswer.length < 2) {
      setState(() => _userAnswer += num.toString());
    }
  }

  void _clear() {
    setState(() => _userAnswer = "");
  }

  void _submit() {
    if (_userAnswer.isEmpty) return;

    if (int.tryParse(_userAnswer) == _a + _b) {
      setState(() => _success = true);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ParentArea()),
          );
        }
      });
    } else {
      setState(() => _shaking = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _shaking = false;
            _userAnswer = "";
            _newQuestion();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blurred background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.white.withOpacity(0.6)),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedScale(
                scale: _shaking ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 40,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_success) ...[
                        _buildGateContent(),
                      ] else ...[
                        _buildSuccessContent(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGateContent() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.close, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFFBEE9FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.family_restroom, color: Color(0xFF006685), size: 48),
        ),
        const SizedBox(height: 24),
        const Text(
          'Ask a grown-up to unlock',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'To access settings, please solve this simple math problem.',
          style: TextStyle(fontSize: 16, color: Color(0xFF3D4947)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Math Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFECEEEE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_a + $_b =',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF006A63), letterSpacing: 2),
              ),
              const SizedBox(width: 16),
              Container(
                minWidth: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4DB6AC), width: 2),
                ),
                child: Center(
                  child: Text(
                    _userAnswer.isEmpty ? '?' : _userAnswer,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _userAnswer.isEmpty ? const Color(0xFF4DB6AC) : const Color(0xFF006A63),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Keypad
        _buildKeypad(),
        const SizedBox(height: 24),
        const Text(
          'PARENTAL CONTROLS',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Color(0xFFBDC9C6)),
        ),
      ],
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        for (var row in [[1, 2, 3], [4, 5, 6], [7, 8, 9]])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var num in row) _KeyButton(label: num.toString(), onTap: () => _append(num)),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _KeyButton(icon: Icons.backspace, color: const Color(0xFFFFDAD6), iconColor: const Color(0xFFBA1A1A), onTap: _clear),
            _KeyButton(label: "0", onTap: () => _append(0)),
            _KeyButton(icon: Icons.check, color: const Color(0xFF4DB6AC), iconColor: Colors.white, onTap: _submit),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        const SizedBox(height: 48),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFF4DB6AC),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_open, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 24),
        const Text(
          'Unlocked!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF006A63)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Taking you to Parent Area...',
          style: TextStyle(fontSize: 16, color: Color(0xFF3D4947)),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Color? color;
  final Color? iconColor;
  final VoidCallback onTap;

  const _KeyButton({this.label, this.icon, this.color, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: color ?? const Color(0xFFF2F4F4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: label != null
            ? Text(label!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)))
            : Icon(icon, color: iconColor ?? const Color(0xFF191C1D), size: 28),
        ),
      ),
    );
  }
}

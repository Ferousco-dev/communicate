import 'dart:math';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'parent_area.dart';

/// A simple "ask a grown-up" gate. Not high security, just enough that a child
/// tapping around can't reach settings and data. True kiosk locking is done at
/// the OS level (Guided Access on iOS, Screen Pinning on Android).
class ParentGate extends StatefulWidget {
  const ParentGate({super.key});

  @override
  State<ParentGate> createState() => _ParentGateState();
}

class _ParentGateState extends State<ParentGate> {
  late int _a;
  late int _b;
  final _controller = TextEditingController();
  bool _wrong = false;

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

  void _check() {
    if (int.tryParse(_controller.text.trim()) == _a * _b) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ParentArea()),
      );
    } else {
      setState(() {
        _wrong = true;
        _controller.clear();
        _newQuestion();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.tealDark,
        foregroundColor: Colors.white,
        title: const Text('Parent area'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: AppColors.tealDark),
            const SizedBox(height: 16),
            const Text('Ask a grown-up',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('What is  $_a × $_b ?',
                style: const TextStyle(fontSize: 24, color: AppColors.tealDark)),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Answer',
                errorText: _wrong ? 'Try again' : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onSubmitted: (_) => _check(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _check,
                child: const Text('Unlock'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

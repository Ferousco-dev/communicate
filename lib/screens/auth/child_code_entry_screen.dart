import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../home_shell.dart';

class ChildCodeEntryScreen extends StatefulWidget {
  const ChildCodeEntryScreen({super.key});

  @override
  State<ChildCodeEntryScreen> createState() => _ChildCodeEntryScreenState();
}

class _ChildCodeEntryScreenState extends State<ChildCodeEntryScreen> {
  static const _length = 6;
  final List<TextEditingController> _controllers =
      List.generate(_length, (_) => TextEditingController());
  final List<FocusNode> _focus = List.generate(_length, (_) => FocusNode());
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  String get _typed => _controllers.map((c) => c.text).join();

  void _onChanged(int i, String value) {
    if (value.length == 1 && i < _length - 1) {
      _focus[i + 1].requestFocus();
    } else if (value.isEmpty && i > 0) {
      _focus[i - 1].requestFocus();
    }
    setState(() => _error = null);
    if (_typed.length == _length) _submit();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final child = await appState.consumeLinkCode(_typed);
    if (!mounted) return;

    if (child == null) {
      setState(() {
        _error = "That code didn't work. Ask your grown-up.";
        _busy = false;
      });
      for (final c in _controllers) {
        c.clear();
      }
      _focus.first.requestFocus();
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFA), Color(0xFFBEE9FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF3D4947)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Hello!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF006A63)),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DB6AC),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(child: Icon(Icons.person, color: Colors.white, size: 24)),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Illustration
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 12)),
                              ],
                            ),
                            child: const Icon(Icons.link, size: 64, color: Color(0xFF006A63)),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(color: Color(0xFF84D7FD), shape: BoxShape.circle),
                              child: const Icon(Icons.key, color: Color(0xFF005D79), size: 24),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Ask your parent for the code',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Type the numbers they show you on their phone.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Color(0xFF3D4947)),
                      ),
                      const SizedBox(height: 40),

                      // Code Input Grid
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: List.generate(_length, (i) {
                          return SizedBox(
                            width: 54,
                            height: 72,
                            child: TextField(
                              controller: _controllers[i],
                              focusNode: _focus[i],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF006A63)),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF4DB6AC), width: 2),
                                ),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8)),
                                ],
                              ),
                              onChanged: (v) => _onChanged(i, v),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      if (_error != null)
                        Text(_error!, style: const TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.w600)),

                      const SizedBox(height: 32),
                      // Connect Button
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: _typed.length == _length && !_busy ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006A63),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                            elevation: 8,
                            shadowColor: const Color(0xFF006A63).withOpacity(0.4),
                          ),
                          child: _busy
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle),
                                    SizedBox(width: 12),
                                    Text('Connect', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer Hint
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF84D7FD).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.help, size: 20, color: Color(0xFF005D79)),
                      SizedBox(width: 8),
                      Text('Where is the code?', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF005D79))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

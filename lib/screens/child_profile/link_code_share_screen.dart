import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../home_shell.dart';

class LinkCodeShareScreen extends StatefulWidget {
  final ChildProfile child;
  final bool isFirstSetup;

  const LinkCodeShareScreen({
    super.key,
    required this.child,
    this.isFirstSetup = false,
  });

  @override
  State<LinkCodeShareScreen> createState() => _LinkCodeShareScreenState();
}

class _LinkCodeShareScreenState extends State<LinkCodeShareScreen> {
  LinkCode? _code;
  bool _busy = false;
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final cached = appState.currentCodeFor(widget.child.id);
    if (cached != null) {
      setState(() {
        _code = cached;
        _startTimeLeftCounter();
      });
      return;
    }
    await _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _busy = true);
    try {
      final fresh = await appState.generateLinkCode(widget.child.id);
      if (!mounted) return;
      setState(() {
        _code = fresh;
        _startTimeLeftCounter();
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startTimeLeftCounter() {
    _timer?.cancel();
    if (_code == null) return;

    _updateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _updateTimeLeft();
    });
  }

  void _updateTimeLeft() {
    if (_code == null) return;
    final diff = _code!.expiresAt.difference(DateTime.now());
    setState(() {
      _timeLeft = diff.isNegative ? Duration.zero : diff;
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(d.inHours);
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Future<void> _copy() async {
    final code = _code;
    if (code == null) return;
    await Clipboard.setData(ClipboardData(text: code.code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied'), duration: Duration(seconds: 1)),
    );
  }

  void _continue() {
    if (widget.isFirstSetup) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (_) => false,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _code;
    if (code == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: Stack(
        children: [
          // Background Atmospheric Elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF84D7FD).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF4DB6AC).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Nav
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF006A63)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Icon(Icons.settings, color: Color(0xFF006A63)),
                      const SizedBox(width: 12),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(color: Color(0xFF84D7FD), shape: BoxShape.circle),
                        child: const Center(child: Text('P', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF005D79)))),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        // Header
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4DB6AC).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phonelink_setup, size: 40, color: Color(0xFF006A63)),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Link Device',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Share this code with your child’s device to establish a secure communication bridge.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Color(0xFF3D4947), height: 1.4),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Pairing Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 40,
                                offset: const Offset(0, 12),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFFBDC9C6).withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'YOUR PAIRING CODE',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                  color: Color(0xFF6D7A77),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _codeSegment(code.code.substring(0, 3)),
                                  const SizedBox(width: 16),
                                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFBDC9C6), shape: BoxShape.circle)),
                                  const SizedBox(width: 16),
                                  _codeSegment(code.code.substring(3, 6)),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Countdown
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.schedule, size: 16, color: Color(0xFF3D4947)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Expires in ${_formatDuration(_timeLeft)}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3D4947)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Actions
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: ElevatedButton(
                            onPressed: _busy ? null : _refresh,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006A63),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                              elevation: 4,
                              shadowColor: const Color(0xFF006A63).withOpacity(0.4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_busy)
                                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                else
                                  const Icon(Icons.refresh),
                                const SizedBox(width: 12),
                                const Text('Generate new code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _continue,
                          style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                          child: Text(
                            widget.isFirstSetup ? "Continue into the app" : 'Cancel Pairing',
                            style: const TextStyle(fontSize: 16, color: Color(0xFF3D4947)),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Security Badge
                        Opacity(
                          opacity: 0.4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock, size: 14),
                              const SizedBox(width: 8),
                              const Text(
                                'END-TO-END ENCRYPTED PAIRING',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeSegment(String segment) {
    return Row(
      children: segment.split('').map((char) {
        return Container(
          width: 44,
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBDC9C6).withOpacity(0.5)),
          ),
          child: Center(
            child: Text(
              char,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF006A63)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

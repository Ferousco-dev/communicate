import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../home_shell.dart';

/// Shows the 6-digit pairing code for [child]. The parent reads it out (or
/// hands their phone over) and the child's device types it on
/// `ChildCodeEntryScreen` to pair without entering a password.
class LinkCodeShareScreen extends StatefulWidget {
  final ChildProfile child;

  /// First-time flow (after sign-up + profile creation) shows a "Continue
  /// into the app" CTA. From the Children tab we just pop back.
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

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final cached = appState.currentCodeFor(widget.child.id);
    if (cached != null) {
      setState(() => _code = cached);
      return;
    }
    await _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _busy = true);
    try {
      final fresh = await appState.generateLinkCode(widget.child.id);
      if (!mounted) return;
      setState(() => _code = fresh);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy() async {
    final code = _code;
    if (code == null) return;
    await Clipboard.setData(ClipboardData(text: code.code));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(
        backgroundColor: AppColors.tealDark,
        duration: Duration(milliseconds: 1400),
        content: Text('Code copied'),
      ));
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
      // First-frame state while we mint or fetch a code from Supabase.
      return const Scaffold(
        backgroundColor: AppColors.tealBg,
        body: Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }
    final expiresIn = code.expiresAt.difference(DateTime.now());
    final hours = expiresIn.inHours;

    return Scaffold(
      backgroundColor: AppColors.tealBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.tealDark,
        elevation: 0,
        title: Text("${widget.child.name}'s code"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              const _Hero(),
              const SizedBox(height: 16),
              const Text(
                "Type this code into the CommuniCare app on your child's "
                "device to pair it. The code is single-use.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, height: 1.5),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.tealMid, width: 1.4),
                ),
                child: Column(
                  children: [
                    Text(
                      code.pretty,
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 6,
                        color: AppColors.tealDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hours <= 0
                          ? 'Expires soon'
                          : 'Expires in about $hours hour${hours == 1 ? '' : 's'}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Copy',
                      onPressed: _busy ? null : _copy,
                      icon: Icons.copy,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SecondaryButton(
                      label: _busy ? 'Working…' : 'New code',
                      onPressed: _busy ? null : _refresh,
                      icon: Icons.refresh,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                label: widget.isFirstSetup
                    ? "Continue into the app"
                    : 'Done',
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.tealLight,
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Icon(Icons.qr_code_2, size: 50, color: AppColors.tealDark),
    );
  }
}

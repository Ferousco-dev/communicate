import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../home_shell.dart';

/// Child-device entry point: type the 6-digit code the parent shared. On
/// success the device is paired and lands directly in the child app, with
/// the matching profile pre-selected.
///
/// Cross-device pairing needs Supabase to be configured. With the current
/// in-memory build, this screen is most useful for end-to-end UI testing on
/// the same device (generate a code in the parent area, then come here and
/// type it).
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
    // Tiny delay so the UI feels real even on hot paths.
    await Future<void>.delayed(const Duration(milliseconds: 150));

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
      backgroundColor: AppColors.tealBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.tealDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(Icons.lock_open,
                    size: 50, color: AppColors.tealDark),
              ),
              const SizedBox(height: 18),
              const Text('Enter your code',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF04342C))),
              const SizedBox(height: 6),
              const Text(
                "Your grown-up will read it to you.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_length, (i) {
                  return Padding(
                    padding: EdgeInsets.only(
                        right: i == 2 ? 14 : (i == _length - 1 ? 0 : 6),
                        left: i == 3 ? 8 : 0),
                    child: SizedBox(
                      width: 44,
                      height: 60,
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _focus[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        autofocus: i == 0,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w700),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.line),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.line),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.teal, width: 1.6),
                          ),
                        ),
                        onChanged: (v) => _onChanged(i, v),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.coral)),
              const Spacer(),
              PrimaryButton(
                label: 'Pair this device',
                onPressed: _typed.length == _length && !_busy ? _submit : null,
                loading: _busy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

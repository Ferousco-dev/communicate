import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class FeelingsScreen extends StatelessWidget {
  const FeelingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final sensory = appState.sensoryMode;
        final header = calmIf(sensory, AppColors.purple);
        final topInset = MediaQuery.of(context).padding.top;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, 18),
                decoration: BoxDecoration(
                  color: header,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: const Column(
                  children: [
                    Text('How do you feel?',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: 2),
                    Text('Tap a feeling to tell someone',
                        style:
                            TextStyle(color: Color(0xFFCECBF6), fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(14),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: appState.feelings.length,
                  itemBuilder: (_, i) => _FeelingTile(
                    feeling: appState.feelings[i],
                    sensory: sensory,
                    onTap: () => _onTap(context, appState.feelings[i]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onTap(BuildContext context, CommCard feeling) {
    appState.logMood(feeling);
    if (!appState.sensoryMode) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 1200),
          backgroundColor: AppColors.tealDark,
          content: Text('You told us: ${feeling.label}'),
        ));
    }
  }
}

class _FeelingTile extends StatelessWidget {
  final CommCard feeling;
  final VoidCallback onTap;
  final bool sensory;
  const _FeelingTile(
      {required this.feeling, required this.onTap, required this.sensory});

  @override
  Widget build(BuildContext context) {
    final accent = calmIf(sensory, feeling.color);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withOpacity(0.5), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(feeling.icon, size: 40, color: accent),
              ),
              const SizedBox(height: 10),
              Text(feeling.label,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink)),
            ],
          ),
        ),
      ),
    );
  }
}

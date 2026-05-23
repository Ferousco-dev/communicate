import 'package:flutter/material.dart';

import '../../../state/app_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/stat_card.dart';

/// Parent dashboard "Progress" tab — words used, top cards, mood counts.
class ProgressTab extends StatelessWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final top = appState.topUsed();
        final moods = appState.moodCounts();
        final maxUse = top.isEmpty ? 1 : top.first.value;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                StatCard(label: 'Words used', value: '${appState.totalWordsUsed}'),
                const SizedBox(width: 12),
                StatCard(
                  label: 'Steps done',
                  value:
                      '${appState.scheduleDone}/${appState.schedule.length}',
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Most used this session',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (top.isEmpty)
              const Text('No taps yet. Use the Talk and Feelings screens first.',
                  style: TextStyle(color: AppColors.muted))
            else
              ...top.map((e) => _UsageBar(label: e.key, value: e.value, max: maxUse)),
            const SizedBox(height: 20),
            const Text('Feelings logged',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (moods.isEmpty)
              const Text('No feelings logged yet.',
                  style: TextStyle(color: AppColors.muted))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: moods.entries
                    .map((e) => Chip(
                          backgroundColor: AppColors.tealLight,
                          label: Text('${e.key}: ${e.value}'),
                        ))
                    .toList(),
              ),
          ],
        );
      },
    );
  }
}

class _UsageBar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  const _UsageBar({required this.label, required this.value, required this.max});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
              width: 70,
              child: Text(label, style: const TextStyle(fontSize: 13))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value / max,
                minHeight: 14,
                backgroundColor: AppColors.tealLight,
                valueColor: const AlwaysStoppedAnimation(AppColors.teal),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$value',
              style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        ],
      ),
    );
  }
}

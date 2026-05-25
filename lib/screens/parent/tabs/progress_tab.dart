import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../state/app_state.dart';
import '../../../theme/app_theme.dart';

class ProgressTab extends StatelessWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // 1. Weekly Overview Stats
            const Text(
              'Weekly Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Total Cards',
                    value: '${appState.totalWordsUsed}',
                    trend: '+12%',
                    color: const Color(0xFF006A63),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    label: 'Dominant Mood',
                    value: 'Happy',
                    icon: Icons.mood,
                    color: const Color(0xFF006A63),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _StatCard(
              label: 'Avg. Response Time',
              value: '4.2s',
              progress: 0.75,
              color: const Color(0xFF006A63),
            ),

            const SizedBox(height: 40),

            // 2. Communication Progress Chart
            const Text(
              'Communication Progress',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
            ),
            const SizedBox(height: 16),
            _ProgressChartCard(),

            const SizedBox(height: 40),

            // 3. Mood History Bento
            const Text(
              'Mood History',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
            ),
            const SizedBox(height: 16),
            _MoodHistoryCard(),

            const SizedBox(height: 40),

            // 4. Most Used Cards
            const Text(
              'Most Used Cards',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
            ),
            const SizedBox(height: 16),
            _TopCardsGrid(),

            const SizedBox(height: 100), // Bottom nav padding
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? trend;
  final IconData? icon;
  final double? progress;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    this.trend,
    this.icon,
    this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBDC9C6).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF3D4947), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (icon != null) ...[
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 8),
              ],
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
              if (trend != null) ...[
                const SizedBox(width: 8),
                Text(trend!, style: const TextStyle(fontSize: 14, color: Color(0xFF4DB6AC), fontWeight: FontWeight.bold)),
              ],
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFECEEEE),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressChartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFBDC9C6).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily Usage', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF2F4F4), borderRadius: BorderRadius.circular(8)),
                child: const Text('Last 7 Days', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                final heightFactor = math.Random().nextDouble() * 0.7 + 0.2;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 24,
                      height: 140 * heightFactor,
                      decoration: BoxDecoration(
                        color: const Color(0xFF006A63).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 24,
                        height: 140 * heightFactor * 0.7,
                        decoration: BoxDecoration(
                          color: const Color(0xFF006A63),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6D7A77))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodHistoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFBDC9C6).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent History', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final moods = [Icons.mood, Icons.mood, Icons.sentiment_neutral, Icons.mood, Icons.sentiment_very_dissatisfied, Icons.mood, Icons.mood];
              final colors = [Color(0xFF006A63), Color(0xFF006A63), Color(0xFFB4A835), Color(0xFF006A63), Color(0xFFBA1A1A), Color(0xFF006A63), Color(0xFF006A63)];
              return Column(
                children: [
                  Text('${12 + index}', style: const TextStyle(fontSize: 10, color: Color(0xFF6D7A77))),
                  const SizedBox(height: 4),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F4),
                      borderRadius: BorderRadius.circular(8),
                      border: index == 1 ? Border.all(color: const Color(0xFF006A63), width: 2) : null,
                    ),
                    child: Icon(moods[index], size: 20, color: colors[index]),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF006A63).withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
            child: const Text(
              '"Today was a great day! Many successful requests for \'Water\' and \'Play\'."',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xFF00433F)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopCardsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = appState.topUsed();
    final icons = [Icons.local_drink, Icons.restaurant, Icons.smart_display, Icons.family_restroom];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List.generate(math.min(top.length, 4), (index) {
        final item = top[index];
        return Container(
          width: (MediaQuery.of(context).size.width - 64) / 2,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBDC9C6).withOpacity(0.5)),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(icons[index % icons.length], color: const Color(0xFF006A63)),
              ),
              const SizedBox(height: 12),
              Text(item.key, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${item.value} times', style: const TextStyle(fontSize: 12, color: Color(0xFF6D7A77))),
            ],
          ),
        );
      }),
    );
  }
}

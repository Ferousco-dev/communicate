import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Small rounded "label + big number" tile used on the parent dashboard.
class StatCard extends StatelessWidget {
  final String label;
  final String value;

  const StatCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1EFE8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

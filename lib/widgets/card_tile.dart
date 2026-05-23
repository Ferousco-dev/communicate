import 'dart:io';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

/// A single big, friendly, tappable card. Shows the parent's photo if there is
/// one, otherwise the icon. Used on the Talk board, Feelings screen, etc.
class CardTile extends StatelessWidget {
  final CommCard card;
  final VoidCallback onTap;
  final bool sensory;
  final double iconSize;

  const CardTile({
    super.key,
    required this.card,
    required this.onTap,
    this.sensory = false,
    this.iconSize = 44,
  });

  @override
  Widget build(BuildContext context) {
    final accent = calmIf(sensory, card.color);
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 56,
                width: 56,
                child: card.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(File(card.imagePath!), fit: BoxFit.cover),
                      )
                    : Icon(card.icon, size: iconSize, color: accent),
              ),
              const SizedBox(height: 8),
              Text(
                card.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

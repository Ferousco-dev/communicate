import 'dart:io';
import 'package:flutter/material.dart';

import '../../../state/app_state.dart';
import '../../../theme/app_theme.dart';
import '../card_editor_screen.dart';

/// Parent dashboard "Cards" tab — list every communication card and let the
/// parent add or remove them.
class CardsTab extends StatelessWidget {
  const CardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.tealBg,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.teal,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CardEditorScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add card'),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: appState.talkCards.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final card = appState.talkCards[i];
              return ListTile(
                leading: card.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(card.imagePath!),
                            width: 40, height: 40, fit: BoxFit.cover),
                      )
                    : Icon(card.icon, color: card.color),
                title: Text(card.label),
                subtitle: Text(card.category),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.coral),
                  onPressed: () => appState.deleteCard(card),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

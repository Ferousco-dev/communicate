import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/card_tile.dart';

class TalkScreen extends StatefulWidget {
  const TalkScreen({super.key});

  @override
  State<TalkScreen> createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  String _category = 'Wants';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final sensory = appState.sensoryMode;
        final headerColor = calmIf(sensory, AppColors.tealDark);
        final cards = appState.cardsForCategory(_category);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Column(
            children: [
              _header(headerColor),
              _sentenceStrip(),
              _categoryChips(sensory),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (_, i) => CardTile(
                    card: cards[i],
                    sensory: sensory,
                    onTap: () => appState.addToSentence(cards[i]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(Color headerColor) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topInset + 14, 16, 16),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.tealMid,
              borderRadius: BorderRadius.circular(50),
            ),
            child:
                const Icon(Icons.sentiment_satisfied, color: Color(0xFF04342C)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.activeChild != null
                      ? 'Hi ${appState.activeChild!.name}!'
                      : 'Hi there!',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const Text("Let's talk together",
                    style:
                        TextStyle(color: AppColors.tealMid, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sentenceStrip() {
    final sentence = appState.sentence;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tealMid),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: sentence.isEmpty
                  ? const Center(
                      child: Text('Tap cards to talk',
                          style: TextStyle(color: AppColors.muted)))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: sentence.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, i) {
                        final c = sentence[i];
                        return Container(
                          width: 56,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: calmIf(appState.sensoryMode, c.color)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(c.icon,
                                  size: 22,
                                  color: calmIf(appState.sensoryMode, c.color)),
                              Text(c.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 10, color: AppColors.ink)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Undo',
            onPressed: sentence.isEmpty ? null : appState.backspaceSentence,
            icon: const Icon(Icons.backspace_outlined, color: AppColors.muted),
          ),
          IconButton(
            tooltip: 'Clear',
            onPressed: sentence.isEmpty ? null : appState.clearSentence,
            icon: const Icon(Icons.delete_outline, color: AppColors.muted),
          ),
          GestureDetector(
            onTap: appState.speakSentence,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: calmIf(appState.sensoryMode, AppColors.teal),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.volume_up, color: Colors.white, size: 26),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChips(bool sensory) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: appState.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final cat = appState.categories[i];
          final selected = cat == _category;
          return GestureDetector(
            onTap: () => setState(() => _category = cat),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected
                    ? calmIf(sensory, AppColors.teal)
                    : AppColors.tealLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(cat,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? Colors.white : AppColors.tealDark,
                  )),
            ),
          );
        },
      ),
    );
  }
}

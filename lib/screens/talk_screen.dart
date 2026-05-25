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
        final cards = appState.cardsForCategory(_category);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFA),
          body: Stack(
            children: [
              Column(
                children: [
                  _header(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        children: [
                          _routineBanner(),
                          _sentenceStrip(),
                          _categoryChips(sensory),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: cards.length,
                            itemBuilder: (_, i) => CardTile(
                              card: cards[i],
                              sensory: sensory,
                              onTap: () => _onCardTap(cards[i]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Quiet Mode FAB
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton.large(
                  onPressed: () => appState.toggleSensoryMode(),
                  backgroundColor: const Color(0xFF84D7FD),
                  foregroundColor: const Color(0xFF005D79),
                  shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 4)),
                  child: const Icon(Icons.volume_off, size: 36),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onCardTap(CommCard card) {
    appState.addToSentence(card);
    if (window.navigator.vibrate) {
      window.navigator.vibrate(50);
    }
    _showFeedback(card.label);
  }

  void _showFeedback(String label) {
    // In a real app, this might show an overlay or play a sound
  }

  Widget _header() {
    final activeChild = appState.activeChild;
    return Container(
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 12, 24, 12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF84D7FD),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4DB6AC), width: 2),
            ),
            child: const Center(child: Icon(Icons.person, color: Color(0xFF005D79), size: 32)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Hi, ${activeChild?.name ?? "there"}! 👋',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF006A63)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF3D4947), size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _routineBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF4DB6AC).withOpacity(0.1),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF4DB6AC).withOpacity(0.3), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Right now:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF006A63))),
                SizedBox(height: 4),
                Text('Breakfast Time 🥣', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00433F))),
              ],
            ),
            Container(
              width: 96,
              height: 12,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.75,
                child: Container(decoration: BoxDecoration(color: const Color(0xFF006A63), borderRadius: BorderRadius.circular(6))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sentenceStrip() {
    final sentence = appState.sentence;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF4DB6AC).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 72,
              child: sentence.isEmpty
                  ? const Center(child: Text('Tap cards to talk', style: TextStyle(color: Color(0xFF6D7A77), fontSize: 18)))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: sentence.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final c = sentence[i];
                        return Container(
                          width: 64,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: c.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(c.icon, size: 24, color: c.color),
                              const SizedBox(height: 4),
                              Text(c.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 8),
          _stripAction(Icons.backspace_outlined, appState.backspaceSentence),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: appState.speakSentence,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(color: Color(0xFF006A63), shape: BoxShape.circle),
              child: const Icon(Icons.volume_up, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stripAction(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: const Color(0xFFF2F4F4), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: const Color(0xFF6D7A77), size: 20),
      ),
    );
  }

  Widget _categoryChips(bool sensory) {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: appState.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final cat = appState.categories[i];
          final selected = cat == _category;
          return ChoiceChip(
            label: Text(cat),
            selected: selected,
            onSelected: (s) => setState(() => _category = cat),
            backgroundColor: const Color(0xFFE1F5EE),
            selectedColor: const Color(0xFF006A63),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF006A63),
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          );
        },
      ),
    );
  }
}

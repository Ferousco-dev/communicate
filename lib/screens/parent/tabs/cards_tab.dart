import 'dart:io';
import 'package:flutter/material.dart';

import '../../../state/app_state.dart';
import '../../../theme/app_theme.dart';
import '../card_editor_screen.dart';

class CardsTab extends StatefulWidget {
  const CardsTab({super.key});

  @override
  State<CardsTab> createState() => _CardsTabState();
}

class _CardsTabState extends State<CardsTab> {
  String _search = "";
  String _selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final allCards = appState.talkCards;
        final categories = ["All", ...appState.categories];

        final filteredCards = allCards.where((c) {
          final matchesSearch = c.label.toLowerCase().contains(_search.toLowerCase());
          final matchesCategory = _selectedCategory == "All" || c.category == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFA),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CardEditorScreen()),
            ),
            backgroundColor: const Color(0xFF006A63),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add New Card', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: Column(
            children: [
              // Toolbar
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      onChanged: (v) => setState(() => _search = v),
                      decoration: InputDecoration(
                        hintText: 'Search communication cards...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF6D7A77)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: const Color(0xFFBDC9C6).withOpacity(0.5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: const Color(0xFFBDC9C6).withOpacity(0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter Chips
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = categories[i];
                          final isSelected = _selectedCategory == cat;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedCategory = cat);
                            },
                            selectedColor: const Color(0xFF006A63),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF3D4947),
                              fontWeight: FontWeight.bold,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFBDC9C6)),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Cards Grid
              Expanded(
                child: filteredCards.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: filteredCards.length,
                      itemBuilder: (context, i) {
                        final card = filteredCards[i];
                        // In a real bento grid we'd vary sizes, here we'll use a consistent clean style
                        return _BentoCard(
                          label: card.label,
                          category: card.category,
                          icon: card.icon,
                          color: card.color,
                          imagePath: card.imagePath,
                          onDelete: () => appState.deleteCard(card),
                        );
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: const Color(0xFFBDC9C6)),
          const SizedBox(height: 16),
          Text(
            'No cards found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF3D4947)),
          ),
          const SizedBox(height: 8),
          const Text('Try a different search or category.', style: TextStyle(color: Color(0xFF6D7A77))),
        ],
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final String label;
  final String category;
  final IconData icon;
  final Color color;
  final String? imagePath;
  final VoidCallback onDelete;

  const _BentoCard({
    required this.label,
    required this.category,
    required this.icon,
    required this.color,
    this.imagePath,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFBDC9C6).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.file(File(imagePath!), fit: BoxFit.cover),
                      )
                    : Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
                  textAlign: TextAlign.center,
                ),
                Text(
                  category,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6D7A77), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A), size: 20),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

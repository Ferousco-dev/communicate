import 'package:flutter/material.dart';

/// Named icon catalog.
///
/// We can't safely store an `IconData` by its raw `codePoint` — Flutter's
/// release build tree-shakes glyph fonts and a dynamic codePoint won't be in
/// the font. Storing a stable string key (e.g. "drink") and looking up a
/// const `IconData` here keeps every icon both serialisable and tree-shake
/// friendly.
class IconCatalog {
  IconCatalog._();

  /// Add icons here when the card editor needs to offer them. Keys are
  /// stable strings — never rename one without a migration.
  static const Map<String, IconData> _byKey = <String, IconData>{
    // wants / actions
    'hand': Icons.front_hand,
    'add': Icons.add_circle,
    'help': Icons.pan_tool,
    'stop': Icons.do_not_disturb_on,
    'yes': Icons.check_circle,
    'no': Icons.cancel,
    'star': Icons.star,
    // food
    'drink': Icons.local_drink,
    'food': Icons.restaurant,
    'snack': Icons.cookie,
    'water': Icons.water_drop,
    // play
    'ball': Icons.sports_soccer,
    'music': Icons.music_note,
    'outside': Icons.park,
    'tablet': Icons.tablet_mac,
    'tv': Icons.tv,
    'book': Icons.book,
    'pets': Icons.pets,
    // people
    'mum': Icons.woman,
    'dad': Icons.man,
    'teacher': Icons.school,
    'friend': Icons.people,
    // daily routine
    'brush_teeth': Icons.brush,
    'breakfast': Icons.free_breakfast,
    'school': Icons.school,
    'bed': Icons.bed,
    'bedtime': Icons.bedtime,
    'bath': Icons.bathtub,
    'car': Icons.directions_car,
    'wc': Icons.wc,
    // feelings
    'happy': Icons.sentiment_very_satisfied,
    'sad': Icons.sentiment_very_dissatisfied,
    'angry': Icons.mood_bad,
    'scared': Icons.sentiment_neutral,
    'calm': Icons.self_improvement,
    'tired': Icons.bedtime,
  };

  static const String fallbackKey = 'star';

  static List<String> get allKeys => _byKey.keys.toList(growable: false);

  static IconData lookup(String? key) =>
      _byKey[key] ?? _byKey[fallbackKey]!;
}

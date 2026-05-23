import 'package:flutter/material.dart';

import '../data/icon_catalog.dart';

/// Helpers for round-tripping a [Color] through JSON without depending on the
/// deprecated `Color.value` integer.
String _colorToHex(Color c) {
  final r = (c.r * 255).round() & 0xff;
  final g = (c.g * 255).round() & 0xff;
  final b = (c.b * 255).round() & 0xff;
  final a = (c.a * 255).round() & 0xff;
  return '#${a.toRadixString(16).padLeft(2, '0')}'
      '${r.toRadixString(16).padLeft(2, '0')}'
      '${g.toRadixString(16).padLeft(2, '0')}'
      '${b.toRadixString(16).padLeft(2, '0')}';
}

Color _colorFromHex(String? hex, {Color fallback = const Color(0xFF1D9E75)}) {
  if (hex == null || hex.isEmpty) return fallback;
  final clean = hex.replaceAll('#', '');
  final padded = clean.length == 6 ? 'ff$clean' : clean;
  final parsed = int.tryParse(padded, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}

/// One picture card. The same shape is used for talk cards, feelings and
/// (effectively) schedule items, exactly as planned in the spec.
///
/// Icons are stored as a stable string [iconKey] looked up in [IconCatalog].
/// This makes the model JSON-friendly *and* keeps tree-shaking happy.
class CommCard {
  final String id;

  /// Null for the global feelings palette and seed cards that aren't yet
  /// bound to a specific child. Always set for parent-added cards.
  String? childId;

  String label;
  String iconKey;
  Color color;

  /// Local file path (parent-supplied photo) or a Supabase Storage URL once
  /// step 3b is wired up. Null = render [icon] instead.
  String? imagePath;

  String category;
  String speakText;
  int sortOrder;

  CommCard({
    required this.id,
    required this.label,
    required this.iconKey,
    required this.color,
    required this.category,
    this.childId,
    this.imagePath,
    String? speakText,
    this.sortOrder = 0,
  }) : speakText = speakText ?? label;

  IconData get icon => IconCatalog.lookup(iconKey);

  Map<String, dynamic> toJson() => {
        'id': id,
        'child_id': childId,
        'label': label,
        'icon_key': iconKey,
        'color_hex': _colorToHex(color),
        'image_url': imagePath,
        'category': category,
        'speak_text': speakText,
        'sort_order': sortOrder,
      };

  factory CommCard.fromJson(Map<String, dynamic> j) => CommCard(
        id: j['id'] as String,
        childId: j['child_id'] as String?,
        label: j['label'] as String? ?? '',
        iconKey: j['icon_key'] as String? ?? IconCatalog.fallbackKey,
        color: _colorFromHex(j['color_hex'] as String?),
        imagePath: j['image_url'] as String?,
        category: j['category'] as String? ?? 'Wants',
        speakText: j['speak_text'] as String?,
        sortOrder: (j['sort_order'] as num?)?.toInt() ?? 0,
      );
}

/// A single step in the visual schedule.
class ScheduleItem {
  final String id;
  String? childId;
  String label;
  String iconKey;
  int sortOrder;
  bool done;

  ScheduleItem({
    required this.id,
    required this.label,
    required this.iconKey,
    this.childId,
    this.sortOrder = 0,
    this.done = false,
  });

  IconData get icon => IconCatalog.lookup(iconKey);

  Map<String, dynamic> toJson() => {
        'id': id,
        'child_id': childId,
        'label': label,
        'icon_key': iconKey,
        'sort_order': sortOrder,
        'done': done,
      };

  factory ScheduleItem.fromJson(Map<String, dynamic> j) => ScheduleItem(
        id: j['id'] as String,
        childId: j['child_id'] as String?,
        label: j['label'] as String? ?? '',
        iconKey: j['icon_key'] as String? ?? IconCatalog.fallbackKey,
        sortOrder: (j['sort_order'] as num?)?.toInt() ?? 0,
        done: j['done'] as bool? ?? false,
      );
}

/// A logged feeling, used to build the parent dashboard mood patterns.
class MoodEntry {
  final String id;
  final String? childId;
  final String feelingId;
  final String label;
  final DateTime time;

  MoodEntry({
    required this.id,
    required this.feelingId,
    required this.label,
    required this.time,
    this.childId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'child_id': childId,
        'feeling_id': feelingId,
        'label': label,
        'created_at': time.toIso8601String(),
      };

  factory MoodEntry.fromJson(Map<String, dynamic> j) => MoodEntry(
        id: j['id'] as String,
        childId: j['child_id'] as String?,
        feelingId: j['feeling_id'] as String,
        label: j['label'] as String,
        time: DateTime.parse(j['created_at'] as String),
      );
}

/// One child the parent is supporting.
class ChildProfile {
  final String id;
  String name;
  int? birthYear;
  String? avatarPath;

  ChildProfile({
    required this.id,
    required this.name,
    this.birthYear,
    this.avatarPath,
  });

  int? get age =>
      birthYear == null ? null : DateTime.now().year - birthYear!;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birth_year': birthYear,
        'avatar_url': avatarPath,
      };

  factory ChildProfile.fromJson(Map<String, dynamic> j) => ChildProfile(
        id: j['id'] as String,
        name: j['name'] as String,
        birthYear: (j['birth_year'] as num?)?.toInt(),
        avatarPath: j['avatar_url'] as String?,
      );
}

/// A short, single-use code a parent shares so the child's own device can
/// pair to a specific [ChildProfile] without an email/password.
class LinkCode {
  final String code;
  final String childId;
  final DateTime createdAt;
  final DateTime expiresAt;
  bool consumed;

  LinkCode({
    required this.code,
    required this.childId,
    required this.createdAt,
    required this.expiresAt,
    this.consumed = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isUsable => !consumed && !isExpired;

  String get pretty =>
      code.length == 6 ? '${code.substring(0, 3)} ${code.substring(3)}' : code;
}

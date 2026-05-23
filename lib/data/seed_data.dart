import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import 'ids.dart';

/// Defaults that ship with every new child profile.
///
/// All ids are real UUIDs so they round-trip to Postgres. Re-seeding is
/// gated by `CardsRepository.ensureSeeded` checking for any existing row
/// for the child, so we never duplicate.
class SeedData {
  SeedData._();

  static const List<String> categories = ['Wants', 'Food', 'Play', 'People'];

  static List<CommCard> defaultCardsFor(String childId) {
    CommCard c(String label, String iconKey, Color color, String category,
            int sort, {String? speakText}) =>
        CommCard(
          id: newId(),
          childId: childId,
          label: label,
          iconKey: iconKey,
          color: color,
          category: category,
          sortOrder: sort,
          speakText: speakText,
        );
    return [
      c('I want', 'hand', AppColors.green, 'Wants', 0),
      c('more', 'add', AppColors.teal, 'Wants', 1),
      c('help', 'help', AppColors.pink, 'Wants', 2, speakText: 'help please'),
      c('stop', 'stop', AppColors.coral, 'Wants', 3),
      c('yes', 'yes', AppColors.green, 'Wants', 4),
      c('no', 'no', AppColors.coral, 'Wants', 5),
      c('drink', 'drink', AppColors.blue, 'Food', 0),
      c('food', 'food', AppColors.coral, 'Food', 1),
      c('snack', 'snack', AppColors.amber, 'Food', 2),
      c('water', 'water', AppColors.blue, 'Food', 3),
      c('play', 'ball', AppColors.green, 'Play', 0),
      c('music', 'music', AppColors.purple, 'Play', 1),
      c('outside', 'outside', AppColors.green, 'Play', 2),
      c('tablet', 'tablet', AppColors.blue, 'Play', 3),
      c('mum', 'mum', AppColors.pink, 'People', 0),
      c('dad', 'dad', AppColors.blue, 'People', 1),
      c('teacher', 'teacher', AppColors.amber, 'People', 2),
      c('friend', 'friend', AppColors.purple, 'People', 3),
    ];
  }

  static List<ScheduleItem> defaultScheduleFor(String childId) {
    ScheduleItem s(String label, String iconKey, int sort, {bool done = false}) =>
        ScheduleItem(
          id: newId(),
          childId: childId,
          label: label,
          iconKey: iconKey,
          sortOrder: sort,
          done: done,
        );
    return [
      s('Brush teeth', 'brush_teeth', 0, done: true),
      s('Breakfast', 'breakfast', 1, done: true),
      s('School', 'school', 2),
      s('Play time', 'ball', 3),
      s('Bedtime', 'bedtime', 4),
    ];
  }

  /// Universal feelings palette — not per-child, never persisted, and not
  /// pushed to Postgres. These ids stay non-UUID on purpose; they only live
  /// in memory as a render input for the Feelings screen.
  static List<CommCard> feelings() {
    return [
      CommCard(id: 'feeling-happy',  label: 'happy',  iconKey: 'happy',  color: AppColors.amber,  category: 'feeling'),
      CommCard(id: 'feeling-sad',    label: 'sad',    iconKey: 'sad',    color: AppColors.blue,   category: 'feeling'),
      CommCard(id: 'feeling-angry',  label: 'angry',  iconKey: 'angry',  color: AppColors.coral,  category: 'feeling'),
      CommCard(id: 'feeling-scared', label: 'scared', iconKey: 'scared', color: AppColors.purple, category: 'feeling'),
      CommCard(id: 'feeling-calm',   label: 'calm',   iconKey: 'calm',   color: AppColors.teal,   category: 'feeling'),
      CommCard(id: 'feeling-tired',  label: 'tired',  iconKey: 'tired',  color: AppColors.muted,  category: 'feeling'),
    ];
  }

  /// Icon picker options in the card editor. Tight on purpose — too many
  /// choices overwhelms the parent.
  static const List<String> editorIconChoices = [
    'star', 'drink', 'food', 'ball', 'music', 'bed',
    'wc', 'car', 'pets', 'book', 'tv', 'bath',
  ];

  static const List<Color> editorColorChoices = [
    AppColors.teal,
    AppColors.blue,
    AppColors.purple,
    AppColors.amber,
    AppColors.coral,
    AppColors.green,
    AppColors.pink,
  ];
}

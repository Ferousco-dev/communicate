import '../models/models.dart';
import '../services/sync_service.dart';
import 'local_cache.dart';
import 'seed_data.dart';

/// All cards live in one Hive box keyed by card id. We filter by `child_id`
/// at read time — fast enough for the volumes we expect.
class CardsRepository {
  CardsRepository._();
  static final CardsRepository instance = CardsRepository._();

  List<CommCard> loadForChild(String childId) {
    final box = LocalCache.cards();
    return box.values
        .map((m) => CommCard.fromJson(hiveToJson(m)))
        .where((c) => c.childId == childId)
        .toList()
      ..sort((a, b) {
        final cat = a.category.compareTo(b.category);
        if (cat != 0) return cat;
        return a.sortOrder.compareTo(b.sortOrder);
      });
  }

  /// First time we see a child, install the default deck so the app isn't
  /// empty. No-op if the child already has cards (either seeded earlier on
  /// this device, or pulled from Supabase).
  Future<List<CommCard>> ensureSeeded(String childId) async {
    final existing = loadForChild(childId);
    if (existing.isNotEmpty) return existing;
    final seeds = SeedData.defaultCardsFor(childId);
    final box = LocalCache.cards();
    for (final c in seeds) {
      await box.put(c.id, c.toJson());
      await SyncService.instance.upsertCard(c.toJson());
    }
    return seeds;
  }

  Future<void> save(CommCard card) async {
    await LocalCache.cards().put(card.id, card.toJson());
    await SyncService.instance.upsertCard(card.toJson());
  }

  Future<void> delete(String cardId) async {
    await LocalCache.cards().delete(cardId);
    await SyncService.instance.deleteCard(cardId);
  }

  Future<void> deleteAllForChild(String childId) async {
    final box = LocalCache.cards();
    final ids = box.values
        .map((m) => CommCard.fromJson(hiveToJson(m)))
        .where((c) => c.childId == childId)
        .map((c) => c.id)
        .toList();
    await box.deleteAll(ids);
    for (final id in ids) {
      await SyncService.instance.deleteCard(id);
    }
  }
}

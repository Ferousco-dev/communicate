import '../models/models.dart';
import '../services/sync_service.dart';
import 'local_cache.dart';

class MoodRepository {
  MoodRepository._();
  static final MoodRepository instance = MoodRepository._();

  List<MoodEntry> loadForChild(String childId) {
    final box = LocalCache.mood();
    return box.values
        .map((m) => MoodEntry.fromJson(hiveToJson(m)))
        .where((e) => e.childId == childId)
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  Future<void> save(MoodEntry entry) async {
    await LocalCache.mood().put(entry.id, entry.toJson());
    await SyncService.instance.insertMood(entry.toJson());
  }

  Future<void> deleteAllForChild(String childId) async {
    final box = LocalCache.mood();
    final ids = box.values
        .map((m) => MoodEntry.fromJson(hiveToJson(m)))
        .where((e) => e.childId == childId)
        .map((e) => e.id)
        .toList();
    await box.deleteAll(ids);
    // No remote delete — mood history is parent-only and not removable from
    // the child device in the current schema.
  }
}

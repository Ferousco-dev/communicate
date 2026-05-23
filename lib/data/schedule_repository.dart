import '../models/models.dart';
import '../services/sync_service.dart';
import 'local_cache.dart';
import 'seed_data.dart';

class ScheduleRepository {
  ScheduleRepository._();
  static final ScheduleRepository instance = ScheduleRepository._();

  List<ScheduleItem> loadForChild(String childId) {
    final box = LocalCache.schedule();
    return box.values
        .map((m) => ScheduleItem.fromJson(hiveToJson(m)))
        .where((s) => s.childId == childId)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<List<ScheduleItem>> ensureSeeded(String childId) async {
    final existing = loadForChild(childId);
    if (existing.isNotEmpty) return existing;
    final seeds = SeedData.defaultScheduleFor(childId);
    final box = LocalCache.schedule();
    for (final s in seeds) {
      await box.put(s.id, s.toJson());
      await SyncService.instance.upsertSchedule(s.toJson());
    }
    return seeds;
  }

  Future<void> save(ScheduleItem item) async {
    await LocalCache.schedule().put(item.id, item.toJson());
    await SyncService.instance.upsertSchedule(item.toJson());
  }

  Future<void> delete(String id) async {
    await LocalCache.schedule().delete(id);
    await SyncService.instance.deleteSchedule(id);
  }

  Future<void> deleteAllForChild(String childId) async {
    final box = LocalCache.schedule();
    final ids = box.values
        .map((m) => ScheduleItem.fromJson(hiveToJson(m)))
        .where((s) => s.childId == childId)
        .map((s) => s.id)
        .toList();
    await box.deleteAll(ids);
    for (final id in ids) {
      await SyncService.instance.deleteSchedule(id);
    }
  }
}

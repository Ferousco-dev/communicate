import '../models/models.dart';
import '../services/sync_service.dart';
import 'local_cache.dart';

/// Reads/writes [ChildProfile]s. Hive is the source of truth the UI reads
/// from; every write is mirrored to Supabase via SyncService (which queues
/// when offline).
class ChildrenRepository {
  ChildrenRepository._();
  static final ChildrenRepository instance = ChildrenRepository._();

  List<ChildProfile> loadAll() {
    final box = LocalCache.children();
    return box.values
        .map((m) => ChildProfile.fromJson(hiveToJson(m)))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<void> save(ChildProfile c) async {
    await LocalCache.children().put(c.id, c.toJson());
    await SyncService.instance.upsertChild(c.toJson());
  }

  Future<void> delete(String id) async {
    await LocalCache.children().delete(id);
    await SyncService.instance.deleteChild(id);
  }

  /// Used by SyncService when pulling — bypasses the push path so we don't
  /// echo remote rows straight back. Repositories only call SyncService for
  /// genuine local writes.
  Future<void> putLocalOnly(ChildProfile c) =>
      LocalCache.children().put(c.id, c.toJson());
}

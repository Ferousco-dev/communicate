import 'ids.dart';
import 'local_cache.dart';
import 'sync_op.dart';

/// Hive-backed FIFO of pending Supabase writes.
///
/// Repositories enqueue here whenever a Supabase write fails (or is skipped
/// because the device is offline / not authenticated). SyncService drains
/// the queue from the front; failed ops stay where they are and get retried
/// next flush.
class SyncQueue {
  SyncQueue._();
  static final SyncQueue instance = SyncQueue._();

  Future<void> enqueue(PendingOpKind kind, Map<String, dynamic> payload) async {
    final op = PendingOp(
      id: newId(),
      kind: kind,
      payload: payload,
      createdAt: DateTime.now(),
    );
    await LocalCache.pendingOps().put(op.id, op.toJson());
  }

  /// Returns the queued ops, oldest first. Always read fresh from Hive in
  /// case another in-flight call enqueued something during a flush.
  List<PendingOp> all() {
    final box = LocalCache.pendingOps();
    final ops = box.values
        .map((m) => PendingOp.fromJson(hiveToJson(m)))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return ops;
  }

  Future<void> remove(String opId) =>
      LocalCache.pendingOps().delete(opId);

  Future<void> clear() => LocalCache.pendingOps().clear();

  int get length => LocalCache.pendingOps().length;
}

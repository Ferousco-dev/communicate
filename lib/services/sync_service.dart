import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../data/local_cache.dart';
import '../data/sync_op.dart';
import '../data/sync_queue.dart';

/// Single place that talks to Supabase for the data tables (cards, schedule,
/// mood, children). Repositories never touch the Supabase client directly —
/// they enqueue writes and ask SyncService to push/pull.
///
/// All methods are no-ops when Supabase isn't configured or there's no auth
/// session — the local Hive cache keeps working on its own. That's the whole
/// point of the offline-first design.
class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  /// True only when we have a Supabase URL + key AND a live auth session
  /// (parent OR anonymous-paired child device).
  bool get available {
    if (!Env.isConfigured) return false;
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  /// Current auth user id. Null when unauthenticated or unconfigured.
  String? get uid {
    if (!Env.isConfigured) return null;
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  SupabaseClient get _c => Supabase.instance.client;

  // ---------------- enqueue helpers ----------------
  // Repositories call these on every write. We try the push immediately; if
  // it fails (offline, RLS, transient error) the op stays on disk and gets
  // retried next flush. The local Hive write is always committed first.

  Future<void> upsertCard(Map<String, dynamic> row) =>
      _tryThenQueue(PendingOpKind.upsertCard, row, () => _c.from('cards').upsert(row));

  Future<void> deleteCard(String id) => _tryThenQueue(
      PendingOpKind.deleteCard,
      {'id': id},
      () => _c.from('cards').delete().eq('id', id));

  Future<void> upsertSchedule(Map<String, dynamic> row) => _tryThenQueue(
      PendingOpKind.upsertSchedule,
      row,
      () => _c.from('schedule_items').upsert(row));

  Future<void> deleteSchedule(String id) => _tryThenQueue(
      PendingOpKind.deleteSchedule,
      {'id': id},
      () => _c.from('schedule_items').delete().eq('id', id));

  Future<void> insertMood(Map<String, dynamic> row) => _tryThenQueue(
      PendingOpKind.insertMood,
      row,
      () => _c.from('mood_entries').insert(row));

  Future<void> upsertChild(Map<String, dynamic> row) async {
    // owner_id is whoever's logged in — stamp it here so callers don't have
    // to know about Supabase identifiers.
    final me = uid;
    final stamped = {...row, if (me != null) 'owner_id': me};
    await _tryThenQueue(PendingOpKind.upsertChild, stamped,
        () => _c.from('children').upsert(stamped));
  }

  Future<void> deleteChild(String id) => _tryThenQueue(
      PendingOpKind.deleteChild,
      {'id': id},
      () => _c.from('children').delete().eq('id', id));

  Future<void> _tryThenQueue(PendingOpKind kind, Map<String, dynamic> payload,
      Future<dynamic> Function() push) async {
    if (!available) {
      await SyncQueue.instance.enqueue(kind, payload);
      return;
    }
    try {
      await push();
    } catch (e) {
      if (kDebugMode) debugPrint('sync: queuing $kind (${_oneLine(e)})');
      await SyncQueue.instance.enqueue(kind, payload);
    }
  }

  // ---------------- flush ----------------

  /// Drain the pending queue oldest-first. Stops on the first error so we
  /// preserve order — the same op that just failed will be at the front
  /// next time too.
  Future<int> flushPending() async {
    if (!available) return 0;
    var pushed = 0;
    for (final op in SyncQueue.instance.all()) {
      try {
        await _executeOp(op);
        await SyncQueue.instance.remove(op.id);
        pushed += 1;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('sync: flush stopped at ${op.kind} (${_oneLine(e)})');
        }
        break;
      }
    }
    return pushed;
  }

  Future<void> _executeOp(PendingOp op) async {
    switch (op.kind) {
      case PendingOpKind.upsertCard:
        await _c.from('cards').upsert(op.payload);
        return;
      case PendingOpKind.deleteCard:
        await _c.from('cards').delete().eq('id', op.payload['id']);
        return;
      case PendingOpKind.upsertSchedule:
        await _c.from('schedule_items').upsert(op.payload);
        return;
      case PendingOpKind.deleteSchedule:
        await _c.from('schedule_items').delete().eq('id', op.payload['id']);
        return;
      case PendingOpKind.insertMood:
        await _c.from('mood_entries').insert(op.payload);
        return;
      case PendingOpKind.upsertChild:
        await _c.from('children').upsert(op.payload);
        return;
      case PendingOpKind.deleteChild:
        await _c.from('children').delete().eq('id', op.payload['id']);
        return;
    }
  }

  // ---------------- pulls ----------------
  // Each pull replaces the local Hive box contents for that scope. Callers
  // must flush the queue first (otherwise a remote pull would clobber a
  // pending local edit). AppState.syncActiveChild does both in order.

  /// Pull every child profile this parent owns and overwrite the local
  /// children box.
  Future<void> pullChildren() async {
    if (!available) return;
    try {
      final rows = await _c.from('children').select() as List<dynamic>;
      final box = LocalCache.children();
      await box.clear();
      for (final r in rows.cast<Map<String, dynamic>>()) {
        await box.put(r['id'], _stripOwnerId(r));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('sync: pullChildren failed (${_oneLine(e)})');
    }
  }

  /// Pull cards + schedule + mood for one child and replace the local rows
  /// for that child. Other children's rows in the same boxes are untouched.
  Future<void> pullChildData(String childId) async {
    if (!available) return;
    await _pullScope(
      table: 'cards',
      childId: childId,
      box: LocalCache.cards(),
    );
    await _pullScope(
      table: 'schedule_items',
      childId: childId,
      box: LocalCache.schedule(),
    );
    await _pullScope(
      table: 'mood_entries',
      childId: childId,
      box: LocalCache.mood(),
      orderBy: 'created_at',
      limit: 500,
    );
  }

  Future<void> _pullScope({
    required String table,
    required String childId,
    required dynamic box,
    String? orderBy,
    int? limit,
  }) async {
    try {
      var query = _c.from(table).select().eq('child_id', childId);
      final rows = (orderBy != null
              ? (limit != null
                  ? await query.order(orderBy).limit(limit)
                  : await query.order(orderBy))
              : await query) as List<dynamic>;

      // Delete every local row for this child, then write the pulled set.
      final toRemove = box.keys.where((k) {
        final m = box.get(k) as Map?;
        return m != null && m['child_id'] == childId;
      }).toList();
      await box.deleteAll(toRemove);
      for (final r in rows.cast<Map<String, dynamic>>()) {
        await box.put(r['id'], r);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('sync: pull $table failed (${_oneLine(e)})');
    }
  }

  /// `owner_id` lives in Postgres for RLS but the local model doesn't carry
  /// it — drop it before persisting so Hive rows match the Dart shape.
  Map<String, dynamic> _stripOwnerId(Map<String, dynamic> row) {
    final copy = Map<String, dynamic>.from(row);
    copy.remove('owner_id');
    copy.remove('created_at');
    return copy;
  }

  String _oneLine(Object e) =>
      e.toString().replaceAll('\n', ' ').substring(
          0, e.toString().length > 140 ? 140 : e.toString().length);
}

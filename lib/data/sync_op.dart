/// A write that the app wants to make against Supabase but couldn't (or
/// hasn't yet) — e.g. parent on the train tapping "delete card" with no
/// signal. Queued in the `pending_ops_v1` Hive box and flushed by the
/// SyncService whenever it next gets a chance.
enum PendingOpKind {
  upsertChild,
  deleteChild,
  upsertCard,
  deleteCard,
  upsertSchedule,
  deleteSchedule,
  insertMood,
}

class PendingOp {
  /// Local op id (UUID). Not the same as the id of the row being changed.
  final String id;

  final PendingOpKind kind;

  /// For upserts: the row JSON. For deletes: at minimum `{'id': ...}`.
  /// `owner_id` is *not* stored here — SyncService stamps it at flush
  /// time from the current auth session, so a queued op stays valid if
  /// the parent re-authenticates as a different user (it just won't push,
  /// since RLS will reject it).
  final Map<String, dynamic> payload;

  final DateTime createdAt;

  PendingOp({
    required this.id,
    required this.kind,
    required this.payload,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'payload': payload,
        'created_at': createdAt.toIso8601String(),
      };

  factory PendingOp.fromJson(Map<String, dynamic> j) => PendingOp(
        id: j['id'] as String,
        kind: PendingOpKind.values.firstWhere(
          (k) => k.name == j['kind'],
          orElse: () => PendingOpKind.upsertCard,
        ),
        payload: Map<String, dynamic>.from(j['payload'] as Map),
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

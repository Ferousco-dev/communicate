import 'dart:math';

/// Centralised id generator. Every primary key in the cache AND Supabase is
/// a UUIDv4 string — the Postgres `uuid` column type rejects everything else.
///
/// We roll our own with `Random.secure()` so we don't need the `uuid`
/// package — keeps the dependency tree small.
final Random _rng = Random.secure();

String newId() {
  final b = List<int>.generate(16, (_) => _rng.nextInt(256));
  // RFC 4122 §4.4: set the version (4) and variant (10xx) bits.
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  String h(int n) => n.toRadixString(16).padLeft(2, '0');
  final hex = b.map(h).join();
  return '${hex.substring(0, 8)}-'
      '${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}

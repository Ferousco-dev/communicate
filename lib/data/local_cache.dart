import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local cache bootstrap.
///
/// We were originally going to use Hive, but its package download has been
/// flaky on this machine. SharedPreferences is already pulled in
/// transitively by supabase_flutter, ships on every platform Flutter
/// supports, and is plenty fast for our volumes (tens to hundreds of
/// records per child).
///
/// The public API mimics Hive's `Box<Map>` so every repository can keep
/// reading `.values`, `.put(id, json)`, `.delete(id)`, etc. unchanged.
class LocalCache {
  LocalCache._();

  // Backing-store key namespaces. Bump the version suffix for breaking
  // on-disk migrations later.
  static const String childrenBox = 'children_v1';
  static const String cardsBox = 'cards_v1';
  static const String scheduleBox = 'schedule_v1';
  static const String moodBox = 'mood_v1';
  static const String pendingOpsBox = 'pending_ops_v1';
  static const String _metaPrefix = 'meta_v1:';

  static SharedPreferences? _prefs;
  static bool _initialised = false;

  static Future<void> init() async {
    if (_initialised) return;
    _prefs = await SharedPreferences.getInstance();
    _initialised = true;
  }

  // ---------------- box accessors ----------------
  static Box children() => Box._(_prefs!, childrenBox);
  static Box cards() => Box._(_prefs!, cardsBox);
  static Box schedule() => Box._(_prefs!, scheduleBox);
  static Box mood() => Box._(_prefs!, moodBox);
  static Box pendingOps() => Box._(_prefs!, pendingOpsBox);

  // ---------------- meta helpers ----------------
  // A handful of single-value flags. Stored under "meta_v1:<key>" so they
  // never collide with box rows.
  static const _kActiveChildId = 'active_child_id';
  static const _kIsChildDevice = 'is_child_device';

  static String? get activeChildId =>
      _prefs!.getString('$_metaPrefix$_kActiveChildId');
  static Future<void> setActiveChildId(String? id) async {
    final key = '$_metaPrefix$_kActiveChildId';
    if (id == null) {
      await _prefs!.remove(key);
    } else {
      await _prefs!.setString(key, id);
    }
  }

  static bool get isChildDevice =>
      _prefs!.getBool('$_metaPrefix$_kIsChildDevice') ?? false;
  static Future<void> setIsChildDevice(bool v) =>
      _prefs!.setBool('$_metaPrefix$_kIsChildDevice', v);

  /// Wipe everything an account contributed — children/cards/schedule/mood
  /// and the pending-op queue — so the next parent to sign in on the same
  /// device starts fresh. The child-device flag survives.
  static Future<void> clearAccountScopedData() async {
    await Future.wait([
      children().clear(),
      cards().clear(),
      schedule().clear(),
      mood().clear(),
      pendingOps().clear(),
    ]);
    await _prefs!.remove('$_metaPrefix$_kActiveChildId');
  }
}

/// A tiny Hive-compatible box, backed by one SharedPreferences string per
/// box. The string holds a JSON object of `{ recordId: { ...row } }`.
///
/// For our volumes this is fine: writes re-serialise the whole map, but
/// the map is small. If we ever outgrow this, swap implementations behind
/// this class without touching the repositories.
class Box {
  final SharedPreferences _prefs;
  final String _key;
  Box._(this._prefs, this._key);

  Map<String, Map<String, dynamic>> _read() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _write(Map<String, Map<String, dynamic>> data) =>
      _prefs.setString(_key, json.encode(data));

  // Hive's Box.values returns an iterable of the stored values.
  Iterable<Map> get values => _read().values;
  Iterable<String> get keys => _read().keys;
  int get length => _read().length;

  Map? get(String id) => _read()[id];

  Future<void> put(String id, Map value) async {
    final data = _read();
    data[id] = Map<String, dynamic>.from(value);
    await _write(data);
  }

  Future<void> putAll(Map<String, Map> entries) async {
    final data = _read();
    entries.forEach((k, v) => data[k] = Map<String, dynamic>.from(v));
    await _write(data);
  }

  Future<void> delete(String id) async {
    final data = _read();
    if (data.remove(id) != null) await _write(data);
  }

  Future<void> deleteAll(Iterable<String> ids) async {
    final data = _read();
    var changed = false;
    for (final id in ids) {
      if (data.remove(id) != null) changed = true;
    }
    if (changed) await _write(data);
  }

  Future<void> clear() => _prefs.remove(_key);
}

/// SharedPreferences gives us `Map<String, dynamic>` already, so this is a
/// no-op pass-through. We keep the helper around so repositories don't need
/// to know which backing store they're talking to.
Map<String, dynamic> hiveToJson(Map raw) =>
    raw.map((k, v) => MapEntry(k.toString(), v));

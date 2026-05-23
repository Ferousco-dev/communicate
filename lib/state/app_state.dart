import 'package:flutter/material.dart';

import '../data/cards_repository.dart';
import '../data/children_repository.dart';
import '../data/ids.dart';
import '../data/local_cache.dart';
import '../data/mood_repository.dart';
import '../data/schedule_repository.dart';
import '../data/seed_data.dart';
import '../services/sync_service.dart';
import '../models/models.dart';
import '../services/link_code_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

/// Everything the app knows.
///
/// The public surface (getters + mutators below the divider) is what the
/// screens depend on — it has stayed stable since the in-memory MVP so the
/// UI doesn't need to change as storage moves under it. What changed in
/// step 3a: the data now comes from Hive-backed repositories instead of
/// hardcoded seed lists, and survives across app restarts.
class AppState extends ChangeNotifier {
  // ---------------- settings ----------------
  bool _sensoryMode = false;
  bool get sensoryMode => _sensoryMode;

  bool childLockEnabled = true;

  void setSensory(bool v) {
    _sensoryMode = v;
    notifyListeners();
  }

  bool get soundOn => ttsService.soundOn;
  void setSound(bool v) {
    ttsService.soundOn = v;
    notifyListeners();
  }

  void setChildLock(bool v) {
    childLockEnabled = v;
    notifyListeners();
  }

  // ---------------- lifecycle ----------------
  bool _ready = false;
  bool get isReady => _ready;

  /// Call once at app start, AFTER [LocalCache.init]. Hydrates the in-memory
  /// mirrors from cache so screens have data the first frame they render.
  Future<void> init() async {
    children
      ..clear()
      ..addAll(ChildrenRepository.instance.loadAll());
    _isChildDevice = LocalCache.isChildDevice;

    // Restore the previously-active child, if any.
    final lastId = LocalCache.activeChildId;
    if (lastId != null) {
      final found = children.where((c) => c.id == lastId);
      if (found.isNotEmpty) {
        _activeChild = found.first;
      }
    }
    if (_activeChild != null) {
      await _loadActiveChildData();
    }
    _ready = true;
    notifyListeners();
  }

  // ---------------- sync triggers ----------------
  // These don't change AppState's public API for screens — they're called
  // by AuthGate at well-defined moments (post-sign-in, child becomes
  // active) and by the rest of AppState after seed work.

  /// Called after a Supabase session appears (parent log-in or anonymous
  /// pairing). Flushes any pending writes left by the previous offline
  /// session, then pulls the parent's children list.
  Future<void> syncOnSignIn() async {
    await SyncService.instance.flushPending();
    await SyncService.instance.pullChildren();
    children
      ..clear()
      ..addAll(ChildrenRepository.instance.loadAll());
    notifyListeners();
  }

  /// Called whenever [activeChild] changes (parent picks a profile, or a
  /// child device redeems a code). Pulls cards/schedule/mood for that
  /// child so the UI shows the freshest data.
  Future<void> _syncActiveChild() async {
    final child = _activeChild;
    if (child == null) return;
    await SyncService.instance.flushPending();
    await SyncService.instance.pullChildData(child.id);
  }

  Future<void> _loadActiveChildData() async {
    final child = _activeChild;
    if (child == null) {
      talkCards.clear();
      schedule.clear();
      moodLog.clear();
      sentence.clear();
      _usage.clear();
      notifyListeners();
      return;
    }
    // Pull remote first so a fresh device sees existing rows before we'd
    // otherwise install seed defaults. ensureSeeded becomes a no-op once
    // rows arrive from Supabase.
    await _syncActiveChild();

    final cards = await CardsRepository.instance.ensureSeeded(child.id);
    final sched = await ScheduleRepository.instance.ensureSeeded(child.id);
    final moods = MoodRepository.instance.loadForChild(child.id);

    talkCards
      ..clear()
      ..addAll(cards);
    schedule
      ..clear()
      ..addAll(sched);
    moodLog
      ..clear()
      ..addAll(moods);
    sentence.clear();
    _usage.clear();
    notifyListeners();
  }

  // ---------------- child profiles ----------------
  final List<ChildProfile> children = [];
  ChildProfile? _activeChild;
  ChildProfile? get activeChild => _activeChild;
  bool get hasChildren => children.isNotEmpty;
  bool get hasActiveChild => _activeChild != null;

  bool _isChildDevice = false;
  bool get isChildDevice => _isChildDevice;

  Future<void> addChildProfile(ChildProfile child,
      {bool makeActive = true}) async {
    children.add(child);
    await ChildrenRepository.instance.save(child);
    if (makeActive) {
      _activeChild = child;
      await LocalCache.setActiveChildId(child.id);
      await _loadActiveChildData();
    } else {
      notifyListeners();
    }
  }

  Future<void> removeChildProfile(ChildProfile child) async {
    children.removeWhere((c) => c.id == child.id);
    await ChildrenRepository.instance.delete(child.id);
    await CardsRepository.instance.deleteAllForChild(child.id);
    await ScheduleRepository.instance.deleteAllForChild(child.id);
    await MoodRepository.instance.deleteAllForChild(child.id);
    if (_activeChild?.id == child.id) {
      _activeChild = null;
      await LocalCache.setActiveChildId(null);
      await _loadActiveChildData();
    } else {
      notifyListeners();
    }
  }

  Future<void> setActiveChild(ChildProfile child) async {
    _activeChild = child;
    await LocalCache.setActiveChildId(child.id);
    await _loadActiveChildData();
  }

  Future<void> clearActiveChild() async {
    _activeChild = null;
    await LocalCache.setActiveChildId(null);
    await _loadActiveChildData();
  }

  // ---------------- link codes ----------------
  // Codes are in-memory only — they only make sense within the parent
  // session that minted them, and there's nothing useful to recover after a
  // restart. Step 3b moves them to public.link_codes.
  final List<LinkCode> _linkCodes = [];

  /// Mint a fresh code. Pushes a hashed row to Supabase when configured;
  /// plaintext stays in this in-memory cache so the share screen can
  /// redisplay it without re-rolling.
  Future<LinkCode> generateLinkCode(String childId,
      {Duration lifetime = const Duration(hours: 24)}) async {
    final lc = await LinkCodeService.instance.mint(childId, lifetime: lifetime);
    _linkCodes.add(lc);
    notifyListeners();
    return lc;
  }

  LinkCode? currentCodeFor(String childId) {
    final active = _linkCodes
        .where((c) => c.childId == childId && c.isUsable)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return active.isEmpty ? null : active.first;
  }

  /// Try the Supabase RPC first (real cross-device pairing). Fall back to
  /// the in-memory pool so same-device dev runs without keys still work.
  Future<ChildProfile?> consumeLinkCode(String typed) async {
    final code = typed.replaceAll(RegExp(r'\s+'), '');

    // ---- cross-device path ----
    try {
      final remote = await LinkCodeService.instance.redeem(code);
      // Save the child profile locally so the existing select/active-child
      // plumbing has something to point at, then mark this as a child device.
      if (!children.any((c) => c.id == remote.id)) {
        children.add(remote);
        await LocalCache.children().put(remote.id, remote.toJson());
      }
      _activeChild = remote;
      _isChildDevice = true;
      await LocalCache.setActiveChildId(remote.id);
      await LocalCache.setIsChildDevice(true);
      await _loadActiveChildData();
      return remote;
    } catch (_) {
      // Fall through to in-memory path below.
    }

    // ---- same-device dev path (no Supabase keys) ----
    final match = _linkCodes.firstWhere(
      (c) => c.code == code && c.isUsable,
      orElse: () => LinkCode(
          code: '',
          childId: '',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now()),
    );
    if (match.code.isEmpty) return null;
    final found = children.where((c) => c.id == match.childId);
    if (found.isEmpty) return null;
    final child = found.first;
    match.consumed = true;
    _activeChild = child;
    _isChildDevice = true;
    await LocalCache.setActiveChildId(child.id);
    await LocalCache.setIsChildDevice(true);
    await _loadActiveChildData();
    return child;
  }

  Future<void> unpairChildDevice() async {
    _isChildDevice = false;
    _activeChild = null;
    await LocalCache.setIsChildDevice(false);
    await LocalCache.setActiveChildId(null);
    await _loadActiveChildData();
  }

  // ---------------- talk: categories & cards ----------------
  final List<String> categories = SeedData.categories;

  /// In-memory mirror of CardsRepository for the active child. Mutated only
  /// through addCard/editCard/deleteCard so it stays in sync with Hive.
  final List<CommCard> talkCards = [];

  List<CommCard> cardsForCategory(String c) =>
      talkCards.where((card) => card.category == c).toList();

  Future<void> addCard(CommCard card) async {
    if (_activeChild != null) card.childId = _activeChild!.id;
    talkCards.add(card);
    await CardsRepository.instance.save(card);
    notifyListeners();
  }

  /// Call after mutating a card's fields in place — persists and refreshes UI.
  Future<void> editCard([CommCard? card]) async {
    if (card != null) {
      await CardsRepository.instance.save(card);
    }
    notifyListeners();
  }

  Future<void> deleteCard(CommCard card) async {
    talkCards.remove(card);
    await CardsRepository.instance.delete(card.id);
    notifyListeners();
  }

  // ---------------- talk: sentence strip ----------------
  final List<CommCard> sentence = [];

  void addToSentence(CommCard card) {
    sentence.add(card);
    _bumpUsage(card.label);
    notifyListeners();
    ttsService.speak(card.speakText);
  }

  void backspaceSentence() {
    if (sentence.isNotEmpty) {
      sentence.removeLast();
      notifyListeners();
    }
  }

  void clearSentence() {
    sentence.clear();
    notifyListeners();
  }

  void speakSentence() {
    final text = sentence.map((c) => c.speakText).join(' ');
    ttsService.speak(text);
  }

  // ---------------- feelings & mood log ----------------
  // Feelings are a universal palette — same six emotions for every child.
  // Per-child customisation can come later if a parent asks for it.
  final List<CommCard> feelings = SeedData.feelings();

  /// In-memory mirror of MoodRepository for the active child.
  final List<MoodEntry> moodLog = [];

  Future<void> logMood(CommCard feeling) async {
    final entry = MoodEntry(
      id: newId(),
      childId: _activeChild?.id,
      feelingId: feeling.id,
      label: feeling.label,
      time: DateTime.now(),
    );
    moodLog.add(entry);
    _bumpUsage(feeling.label);
    if (_activeChild != null) {
      await MoodRepository.instance.save(entry);
    }
    notifyListeners();
    ttsService.speak('I feel ${feeling.speakText}');
  }

  Map<String, int> moodCounts() {
    final m = <String, int>{};
    for (final e in moodLog) {
      m[e.label] = (m[e.label] ?? 0) + 1;
    }
    return m;
  }

  // ---------------- visual schedule ----------------
  /// In-memory mirror of ScheduleRepository for the active child.
  final List<ScheduleItem> schedule = [];

  int get scheduleDone => schedule.where((s) => s.done).length;
  int get nowIndex => schedule.indexWhere((s) => !s.done);

  Future<void> toggleScheduleDone(ScheduleItem item) async {
    item.done = !item.done;
    await ScheduleRepository.instance.save(item);
    notifyListeners();
  }

  // ---------------- usage stats ----------------
  final Map<String, int> _usage = {};
  void _bumpUsage(String label) => _usage[label] = (_usage[label] ?? 0) + 1;

  int get totalWordsUsed => _usage.values.fold(0, (a, b) => a + b);

  List<MapEntry<String, int>> topUsed([int n = 5]) {
    final entries = _usage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(n).toList();
  }

  Color tone(Color c) => calmIf(_sensoryMode, c);
}

final appState = AppState();

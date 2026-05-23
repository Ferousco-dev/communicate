import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../models/models.dart';

/// Mints + redeems the 6-digit codes that pair a child's device to a child
/// profile.
///
/// When Supabase is configured, codes get inserted into `public.link_codes`
/// as a SHA-256 hash (plaintext never leaves the parent's device), and the
/// child redeems them via the `redeem_link_code` RPC after anonymous sign-in.
///
/// When Supabase isn't configured (dev mode, no .env keys), this falls back
/// to the same-device in-memory mode AppState already provides — the link
/// code just won't actually work across devices.
class LinkCodeService {
  LinkCodeService._();
  static final LinkCodeService instance = LinkCodeService._();

  bool get _supabase => Env.isConfigured;
  SupabaseClient get _c => Supabase.instance.client;

  /// Generate a fresh code for [childId] and (if configured) insert the
  /// hashed row into Supabase. Plaintext stays in memory on the caller side.
  Future<LinkCode> mint(String childId,
      {Duration lifetime = const Duration(hours: 24)}) async {
    final rnd = Random.secure();
    final code = (rnd.nextInt(900000) + 100000).toString();
    final now = DateTime.now();
    final lc = LinkCode(
      code: code,
      childId: childId,
      createdAt: now,
      expiresAt: now.add(lifetime),
    );
    if (_supabase) {
      try {
        await _c.from('link_codes').insert({
          'child_id': childId,
          'code_hash': _hash(code),
          'expires_at': lc.expiresAt.toUtc().toIso8601String(),
        });
      } catch (e) {
        // Don't fail UX on a network blip — the parent can hit "New code"
        // to retry. We just won't actually pair cross-device this attempt.
        if (kDebugMode) debugPrint('link_codes: insert failed ($e)');
      }
    }
    return lc;
  }

  /// Child-device redemption.
  ///
  /// Returns a [ChildProfile] (id + name) on success. Throws on failure with
  /// a message safe to show.
  Future<ChildProfile> redeem(String typedCode) async {
    final code = typedCode.replaceAll(RegExp(r'\s+'), '');
    if (!_supabase) {
      throw const _RedeemError(
        'This build has no Supabase keys configured. Same-device test mode '
        "uses the parent's in-memory pool — open the auth welcome screen on "
        'this same device to redeem.',
      );
    }
    // Anonymous sign-in if we don't already have a session. We never sign
    // the child in as the parent.
    if (_c.auth.currentSession == null) {
      try {
        await _c.auth.signInAnonymously();
      } catch (e) {
        throw const _RedeemError(
          "Couldn't start a session on this device. Check the connection "
          'and try again.',
        );
      }
    }
    try {
      final raw = await _c.rpc('redeem_link_code', params: {'p_code': code});
      final rows = (raw as List).cast<Map<String, dynamic>>();
      if (rows.isEmpty) {
        throw const _RedeemError("That code didn't work. Ask your grown-up.");
      }
      final row = rows.first;
      return ChildProfile(
        id: row['child_id'] as String,
        name: row['child_name'] as String,
      );
    } on PostgrestException catch (e) {
      if (e.message.contains('invalid_or_expired_code')) {
        throw const _RedeemError("That code didn't work. Ask your grown-up.");
      }
      throw _RedeemError(e.message);
    }
  }

  String _hash(String code) =>
      sha256.convert(utf8.encode(code)).toString();
}

/// Surface-only exception so callers can `catch (e) { e.message }` without
/// importing Supabase types.
class _RedeemError implements Exception {
  final String message;
  const _RedeemError(this.message);
  @override
  String toString() => message;
}

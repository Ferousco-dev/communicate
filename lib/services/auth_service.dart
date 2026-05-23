import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../data/local_cache.dart';
import '../state/app_state.dart';

/// Wraps Supabase Auth so the rest of the app never imports Supabase directly.
/// Only the parent/caregiver ever signs in — the child uses the app under the
/// parent's session via a selected child profile.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  SupabaseClient get _client => Supabase.instance.client;

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentSession != null;

  /// Broadcast stream of auth changes. Use this to drive route guards.
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'display_name': name.trim(), 'role': 'parent'},
    );
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Native Google sign-in: get ID token, hand it to Supabase. Avoids the
  /// browser bounce so the parent never leaves the app.
  ///
  /// Requires platform setup (see README). If google_sign_in isn't configured,
  /// callers can fall back to [signInWithGoogleOAuth].
  Future<AuthResponse> signInWithGoogleNative() async {
    final google = GoogleSignIn(
      scopes: const ['email', 'profile', 'openid'],
    );
    final account = await google.signIn();
    if (account == null) {
      throw const AuthException('Google sign-in was cancelled.');
    }
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw const AuthException('Google did not return an ID token.');
    }
    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: auth.accessToken,
    );
  }

  /// OAuth browser-redirect fallback. Works without native Google config but
  /// needs the deep-link scheme registered (see README and .env).
  Future<bool> signInWithGoogleOAuth() {
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: Env.supabaseOAuthRedirect,
    );
  }

  /// Sign out and wipe everything the parent put on this device. Without
  /// this, the next account to sign in on the same device would inherit the
  /// previous parent's children + cards from the local cache.
  Future<void> signOut() async {
    await _client.auth.signOut();
    await LocalCache.clearAccountScopedData();
    appState.children.clear();
    appState.talkCards.clear();
    appState.schedule.clear();
    appState.moodLog.clear();
    appState.sentence.clear();
    await appState.clearActiveChild();
  }

  /// Best-effort, parent-friendly error message from a Supabase auth error.
  static String describeError(Object e) {
    if (e is AuthException) return e.message;
    if (kDebugMode) return e.toString();
    return 'Something went wrong. Please try again.';
  }
}

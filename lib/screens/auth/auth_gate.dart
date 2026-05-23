import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auth_service.dart';
import '../../state/app_state.dart';
import '../child_profile/child_profile_select_screen.dart';
import '../child_profile/child_profile_setup_screen.dart';
import '../home_shell.dart';
import '../onboarding_screen.dart';

/// Single source of truth for "where should the user be right now?".
///
/// Watches both the Supabase auth stream and AppState (for child profile
/// state) and rebuilds the right root screen:
///
///   no session                        → OnboardingScreen
///   session, paired child device      → HomeShell
///   session, no child profiles yet    → ChildProfileSetupScreen
///   session, profiles but none active → ChildProfileSelectScreen
///   session, active child             → HomeShell
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<AuthState>? _sub;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _session = AuthService.instance.currentSession;
    // If we already had a session at app start, kick off an initial sync so
    // children + active-child data pull immediately. Fire-and-forget — the
    // gate listens to AppState anyway.
    if (_session != null) {
      appState.syncOnSignIn();
    }
    _sub = AuthService.instance.onAuthStateChange.listen((event) {
      if (!mounted) return;
      final wasSignedIn = _session != null;
      setState(() => _session = event.session);
      if (!wasSignedIn && event.session != null) {
        // Just signed in (parent log-in or anonymous child pairing) — flush
        // queued writes and pull the latest children list.
        appState.syncOnSignIn();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        // Child device paired via link code → straight into the child app.
        // (No parent session needed on the child's device.)
        if (appState.isChildDevice && appState.activeChild != null) {
          return const HomeShell();
        }

        // Signed out → onboarding/auth flow.
        if (_session == null) return const OnboardingScreen();

        // Signed-in parent: branch on child profile state.
        if (!appState.hasChildren) {
          return const ChildProfileSetupScreen();
        }
        if (!appState.hasActiveChild) {
          return const ChildProfileSelectScreen();
        }
        return const HomeShell();
      },
    );
  }
}

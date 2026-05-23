import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/env.dart';
import 'data/local_cache.dart';
import 'services/tts_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Order matters: env first, then offline cache, then Supabase (auth tokens
  // are kept in secure storage by default on mobile), then hydrate AppState
  // from cache so the first frame shows real data.
  await Env.load();
  await LocalCache.init();
  if (Env.isConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  } else {
    debugPrint(
      'CommuniCare: .env has no Supabase keys yet — running without auth. '
      'See README to finish setup.',
    );
  }
  await appState.init();
  ttsService.init();

  runApp(const CommuniCareApp());
}

class CommuniCareApp extends StatelessWidget {
  const CommuniCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CommuniCare',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const SplashScreen(),
    );
  }
}

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads runtime config from the bundled `.env` file.
///
/// Keep all secrets here — no hardcoded keys anywhere else in the codebase.
/// See `.env.example` for the required keys and `README.md` for setup.
class Env {
  static Future<void> load() => dotenv.load(fileName: '.env');

  static String get supabaseUrl => _required('SUPABASE_URL');
  static String get supabaseAnonKey => _required('SUPABASE_ANON_KEY');

  /// Deep-link the OAuth provider redirects back to after Google sign-in.
  static String get supabaseOAuthRedirect =>
      dotenv.maybeGet('SUPABASE_OAUTH_REDIRECT') ??
      'io.communicare.app://login-callback/';

  /// True when Supabase keys are present. Lets the app run in a "demo" mode
  /// (in-memory only) for development without a Supabase project.
  static bool get isConfigured =>
      (dotenv.maybeGet('SUPABASE_URL') ?? '').isNotEmpty &&
      (dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '').isNotEmpty;

  static String _required(String key) {
    final v = dotenv.maybeGet(key);
    if (v == null || v.isEmpty) {
      throw StateError(
        'Missing $key in .env — copy .env.example to .env and fill it in.',
      );
    }
    return v;
  }
}

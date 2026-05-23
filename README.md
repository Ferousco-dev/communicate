# CommuniCare — Flutter

An autism communication support app for children, used by the child and parent together.
The parent owns the account; the child uses the app under the parent's session via a
selected child profile.

This branch finishes Phase 1 (offline AAC, feelings, schedule, parent area) and starts
Phase 2 by adding **parent accounts (Supabase Auth)**. Database + storage + push come
in the next steps; the existing screens still run offline against the in-memory
`AppState` until those land.

## What's in the app right now
- Splash + onboarding
- Parent sign-up / log-in (email + password, Google sign-in)
- **Child profiles** — parent can add 1+ children under their account
- **Link-code pairing** — parent shares a 6-digit code; the child's own
  device types it to pair without an email/password
- Session-aware routing via `AuthGate`
- Bottom-nav app shell: Talk, Feelings, My day, Parent (hidden on a
  paired child device)
- **Talk** — picture cards, sentence strip, real text-to-speech (offline);
  header greets the active child by name
- **Feelings** — tap to speak a feeling; every tap is logged
- **My day** — visual schedule with done / now / upcoming states
- **Customizable cards** — add a card with a photo (camera/gallery) or icon + label
- **Sensory / quiet mode**, **child lock**
- **Parent dashboard** — Progress / Children / Cards / Settings (with Log out)

## Pairing flow

```
PARENT                              CHILD'S DEVICE
──────                              ──────────────
sign up / log in                    open app
  │                                   │
  ▼                                   ▼
create child profile               onboarding → auth welcome
  │                                   │
  ▼                                   ▼  ("I have a code from my parent")
see 6-digit code                   type the 6 digits
  │  (read it out to the child)       │
  └────────── code ──────────────►   pair this device
                                      │
                                      ▼
                                  HomeShell, profile pre-selected,
                                  Parent tab hidden
```

The code is single-use. Each child profile can have one active code at a
time; the parent can regenerate it from **Parent → Children → Share code**.
Default lifetime is 24 hours.

> Cross-device pairing needs Supabase to be live (apply the SQL migration
> below). With Supabase unconfigured, you can still test the UI flow on a
> single device — generate a code in the parent area, hit the back arrow
> to the auth welcome, tap "I have a code", and type it.

## How to run
This archive ships `lib/` and `pubspec.yaml` only — generate the platform folders first:

```bash
flutter create .         # generates android/ ios/ etc. without touching lib/
flutter pub get
cp .env.example .env     # then fill in your Supabase keys (see below)
flutter run
```

If `.env` has no Supabase keys yet, the app falls back to the old in-memory flow so
you can still demo the child screens without a backend. As soon as you fill the keys
in, splash routes through `AuthGate` and the sign-up / log-in screens become active.

Requires Flutter 3.10+ (Dart 3).

## Supabase setup (parent accounts)

1. Create a project at https://supabase.com.
2. In **Settings → API**, copy the project URL and the anon public key.
3. Copy `.env.example` to `.env` and paste those values:
   ```
   SUPABASE_URL=https://YOUR-REF.supabase.co
   SUPABASE_ANON_KEY=eyJ...
   SUPABASE_OAUTH_REDIRECT=io.communicare.app://login-callback/
   ```
   `.env` is gitignored — never commit real keys.
4. In **Authentication → URL Configuration → Redirect URLs**, add the deep link
   `io.communicare.app://login-callback/` so Google OAuth can return to the app.
5. In **Authentication → Providers → Google**, enable Google and paste your OAuth
   client IDs. (You also need a Google Cloud OAuth client — see Supabase docs.)

### Deep link registration (Google sign-in)

For the OAuth fallback flow to return to the app you must register the URL scheme:

- **iOS** — in `ios/Runner/Info.plist`, add inside `<dict>`:
  ```xml
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>io.communicare.app</string>
      </array>
    </dict>
  </array>
  ```
- **Android** — in `android/app/src/main/AndroidManifest.xml`, inside the main
  `<activity>`, add:
  ```xml
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="io.communicare.app" android:host="login-callback" />
  </intent-filter>
  ```

If you prefer the native Google flow (`signInWithGoogleNative`, currently wired to
the button), follow the platform setup in the `google_sign_in` package README —
you'll need an iOS OAuth client (and `GoogleService-Info.plist`) and the Android
SHA-1 fingerprint registered in Google Cloud Console.

### Database

Migrations live under `supabase/migrations/`. Apply them in numeric order
(`0001` first, then `0002`, …).

`0001_children_and_link_codes.sql` is the foundation. It adds:

```
profiles        (id = auth.uid, display_name, role)
children        (id, owner_id -> profiles.id, name, avatar_url, birth_year)
child_devices   (id, child_id, auth_user_id, paired_at, last_seen_at)
link_codes      (id, child_id, code_hash, created_at, expires_at, consumed_at, consumed_by)
```

…plus RLS policies (parent owns their children's rows; child devices can
read their own linkage), a trigger that creates a `profiles` row on
sign-up, and a `redeem_link_code(p_code)` RPC the child device calls after
`signInAnonymously()`.

Apply it either via the Supabase Dashboard → SQL Editor → paste the file,
or with the Supabase CLI:

```bash
supabase db push
```

`0002_card_data.sql` adds the data tables:

```
cards           (id, child_id, label, category, icon_key, color_hex,
                 image_url, speak_text, sort_order, created_at, updated_at)
schedule_items  (id, child_id, label, icon_key, sort_order, done, ...)
mood_entries    (id, child_id, feeling_id, label, created_at)
```

…with the same RLS shape on every table: visible/writable when the row's
`child_id` either belongs to a child whose `owner_id = auth.uid()` (parent
device) or matches `is_paired_device(child_id)` (paired child device).

## Sync model (step 3b)

```
                           SyncService
                       (push + pull facade)
                              ▲
                              │
   write call ──► repo ──► Hive  ──┬──► Supabase  (try)
                                   └──► pending_ops_v1  (on failure)

   pull call  ──► repo ◄── Hive  ◄──── Supabase  (overwrite)
```

- **Hive is always the read source.** Every screen reads from Hive, so the
  app never blocks on a network call. Cold start with no signal: full
  functionality, just no cross-device sync.
- **Writes are Hive-first.** Repositories save to Hive, then ask
  `SyncService` to push. If the push fails (offline, RLS, transient
  error), the op lands in `pending_ops_v1` and gets retried next flush.
- **Pulls overwrite the local rows for that scope.** A flush always runs
  before a pull so queued offline writes get their chance to push first
  — otherwise the remote pull would clobber them.
- **Sync triggers:**
  - App start with an existing session → `appState.syncOnSignIn()`
  - Sign-in event (parent log-in OR anonymous child pairing) → same
  - `setActiveChild` → pulls that child's cards/schedule/mood
- **Mood writes are insert-only.** Mood history is parent-readable but
  not removable from a child device by design.

### Link codes (cross-device pairing)

Step 3b moves the pairing flow off the device:

1. Parent taps "Share code". App mints a 6-digit code, hashes it (SHA-256)
   and inserts `(child_id, code_hash, expires_at)` into `link_codes`.
   Plaintext only ever lives in the parent's in-memory cache.
2. Child enters the code. The child's device calls
   `supabase.auth.signInAnonymously()` so it has an auth identity,
   then calls the `redeem_link_code(p_code)` RPC. The RPC validates +
   atomically inserts into `child_devices` and marks the code consumed.
3. RLS on every data table allows the anonymous device to read/write
   rows for that one child via the `is_paired_device(child_id)` helper.

### Default deck conflict-safety

`CardsRepository.ensureSeeded` (and `ScheduleRepository.ensureSeeded`)
checks for any existing row for the child *after* the initial Supabase
pull. So the second device to load a child sees the pulled rows and
skips seeding — no duplicated defaults.

## Offline-first cache (step 3a)

Data lives in a local **Hive** cache under the app's documents directory.
The UI reads from this cache, so every screen works with no network.
Writes go straight to Hive and (in step 3b) get mirrored to Supabase.

Boxes (`lib/data/local_cache.dart`):

- `children_v1` — every child profile the parent has created
- `cards_v1`    — all cards, filtered by `child_id` at read time
- `schedule_v1` — schedule items, ditto
- `mood_v1`     — logged feelings
- `meta_v1`     — last-active-child id, is-this-device-paired flag

Bumping the `_vN` suffix is how we'd introduce a breaking on-disk migration
later without overwriting existing data.

### Icons are stored as keys, not raw font codepoints

Cards keep an `iconKey` (e.g. `"drink"`, `"music"`); the catalog in
`lib/data/icon_catalog.dart` resolves keys to `IconData` at render time.
This is on purpose — storing a raw `codePoint` breaks once Flutter
tree-shakes the icon font in release builds. Every key in the catalog
keeps a static `Icons.xxx` reference so its glyph survives tree-shaking.

When you add a new card icon: add it to `IconCatalog._byKey` AND (if it
should appear in the picker) `SeedData.editorIconChoices`.

### Default deck for a new child

`CardsRepository.ensureSeeded(childId)` installs the default deck the first
time a child profile is loaded. `ScheduleRepository.ensureSeeded` does the
same for the morning routine. Edits and deletes survive — `ensureSeeded`
is a no-op when any row already exists for that child.

### What happens on log-out

`AuthService.signOut()` calls `LocalCache.clearAccountScopedData()`, which
wipes children/cards/schedule/mood from disk so the next account on the
same device starts fresh. The child-device pairing flag survives — logging
out doesn't apply to a paired child device.

## Permissions (image_picker)

- **iOS** — in `ios/Runner/Info.plist`:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>Take a photo to make a communication card.</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>Choose a photo to make a communication card.</string>
  ```
- **Android** — works out of the box for gallery; for camera, ensure the device
  has one. No manifest changes needed for basic use.

`flutter_tts` needs no special permissions.

## Project structure

```
lib/
  main.dart                        env + Hive + Supabase init, then SplashScreen
  config/env.dart                  reads .env, exposes typed getters
  theme/app_theme.dart             palette + theme + sensory helper
  models/models.dart               CommCard, ScheduleItem, MoodEntry,
                                   ChildProfile, LinkCode (all JSON-able)
  data/
    icon_catalog.dart              named icons (tree-shake safe)
    ids.dart                       UUIDv4 generator
    local_cache.dart               Hive bootstrap + box accessors
    seed_data.dart                 default cards / schedule / feelings
    sync_op.dart                   PendingOp model
    sync_queue.dart                Hive-backed pending writes
    children_repository.dart       Hive write-through + sync push
    cards_repository.dart
    schedule_repository.dart
    mood_repository.dart
  services/
    tts_service.dart               offline text-to-speech wrapper
    auth_service.dart              Supabase Auth wrapper (email + Google)
    link_code_service.dart         mint (hashed) + redeem via RPC
    sync_service.dart              push pending + pull child data
  state/app_state.dart             reactive store, repo-backed
  widgets/
    card_tile.dart                 reusable picture card
    auth_text_field.dart           shared rounded input
    primary_button.dart            shared teal CTA (+ SecondaryButton)
    stat_card.dart                 parent dashboard tile
  screens/
    splash_screen.dart
    onboarding_screen.dart
    home_shell.dart                bottom nav + parent routing
    talk_screen.dart
    feelings_screen.dart
    schedule_screen.dart
    auth/
      auth_gate.dart               watches session + AppState, picks the
                                   right root: onboarding → auth → child
                                   setup/select → HomeShell
      auth_welcome_screen.dart     "create account or log in" + child code
      sign_up_screen.dart
      log_in_screen.dart
      child_code_entry_screen.dart 6-digit pairing input
    child_profile/
      child_profile_setup_screen.dart  parent creates a child profile
      child_profile_select_screen.dart "who's using the app today?"
      link_code_share_screen.dart      big code display + copy/refresh
    parent/
      parent_gate.dart             child lock ("ask a grown-up")
      parent_area.dart             dashboard shell (AppBar + TabBarView)
      card_editor_screen.dart
      tabs/
        progress_tab.dart
        children_tab.dart          list/add/select children + share code
        cards_tab.dart
        settings_tab.dart          sensory / sound / lock + log out

supabase/
  migrations/
    0001_children_and_link_codes.sql
    0002_card_data.sql
```

## Next steps in this phase
1. ~~**Parent accounts**~~ — done (Supabase Auth, email + Google).
2. ~~**Child profiles + link-code pairing**~~ — done (in-memory; SQL ships
   in `0001_children_and_link_codes.sql`).
3. **Step 3a — Local cache + repositories** — done. Data survives restart.
4. **Step 3b — Supabase sync** — done. Writes mirror to Postgres, queue
   when offline, and pull on sign-in / child switch. Link codes hashed
   and redeemed via RPC. Apply `0001_*.sql` and `0002_*.sql` to your
   Supabase project to turn it on.
5. **Storage** — upload card photos to Supabase Storage, replace
   `imagePath` with a public/signed URL.
6. **FCM** — Firebase Cloud Messaging (only) for gentle parent reminders.

## Responsible-use note
CommuniCare is a communication support tool, not a medical device or a replacement
for professional therapy. Your child's data belongs to you.
# communicate

# CommuniCare — Feature Specification

An autism communication support app for children, used by the child and parent together. Built in Flutter.

CommuniCare gives a child who struggles to communicate a clear voice (picture-based talking), helps them learn and express feelings, gives structure to their day, and gives parents and therapists real insight into progress — all in a calm, predictable, child-safe interface.

---

## Design principles (rules, not features)

These shape every decision and should be treated as non-negotiable:

- **Offline-first.** Core features (Talk, Feelings, Schedule) must work with zero internet. A child needing to say "bathroom" can't wait for a connection.
- **Calm and low-sensory.** Friendly and warm, but never overstimulating. No loud sounds, harsh flashing, or chaotic motion by default.
- **Predictable.** Buttons and symbols stay in the same place every time. Consistency builds trust and muscle memory.
- **Big touch targets.** Large, well-spaced buttons that tolerate imprecise taps.
- **Dual coding.** Every card = picture + word.
- **Privacy-minimal.** Collect as little personal data as possible. Keep data on-device by default. Never send raw health data to the cloud.
- **Support, not medical device.** The app assists communication and flags signals; it does not diagnose or replace therapy.

---

## Feature set

### 1. Talk — picture-based communication (core)
- Picture cards grouped by category (wants, feelings, food, play, people, places).
- Sentence strip: tap cards to build a sentence, then play it aloud.
- Text-to-speech with a clear, friendly voice.
- Multi-language and accent support — English plus Yoruba, Igbo, Hausa, and a local-sounding voice. (Strong differentiator; most AAC apps are US/UK English only.)
- Favorites / most-used quick bar for this child's high-frequency cards.
- **Customizable cards** — parent adds a photo (e.g. the child's real cup, their school, grandma), a label, a category, and the spoken phrase.
- Add a card straight from the camera.

### 2. Feelings — emotional learning
- Feeling picker (happy, sad, angry, scared, calm, tired, and more).
- "Tell someone" — speak the chosen feeling aloud.
- Emotion recognition exercises — gentle quiz mode ("can you find happy?").
- **Mood logging** — every feeling tapped is quietly recorded to feed the parent dashboard and reveal patterns.

### 3. My day — structure and routine
- Visual schedule with clear now / next / done states.
- Routine templates (morning, school, bedtime) the parent can edit.
- Transition timers / countdowns to ease the move between activities.
- Optional gentle reminders.

### 4. Stars — rewards and motivation
- Star count and a progress bar toward a prize.
- Badges for milestones (first word, streaks).
- Parent-defined real-world prizes.
- Gentle celebrations only (soft chime, calm animation — respects sensory needs).

### 5. Smart features (AI)
- **Smart card prediction** — surface the next likely cards based on time of day and history.
- **AI card-art generation** — parent types a description, app generates a clean cartoon card. (Also solves the art-asset and customization need.)
- **Plain-language dashboard insights** — AI summarizes trends in readable sentences instead of raw charts.
- **AI social stories** — generate a short, personalized story to prepare the child for an upcoming event.
- **Setup assistant** — parent describes a need ("bedtime is hard"), AI suggests cards and a routine.
- Note: generative features need the cloud (e.g. an LLM API); lightweight prediction/classification can run on-device with TensorFlow Lite. Send only what's necessary.

### 6. Voice and speech
- **Speak aloud (TTS)** — tap cards or a feeling and the app says it out loud ("Tell someone"). Must work offline.
- **Parent-recorded voice** — parent records their own voice for cards and praise. A child hearing a familiar real voice is hugely powerful; trivial to build (record + playback, no AI, offline).
- **Premium voices (optional, online)** — warmer/natural cloud voices when connected.
- **Voice-to-voice AI (later phase, supervised)** — narrow, bounded uses only: hands-free setup for the parent, gentle speech *practice* for verbal kids, and a calm companion during calm-down moments. Not an open-ended chatbot for children.
- Guardrails for any child-facing AI voice: locked kid-safe persona, tight system prompt, content filtering, and a parent on/off toggle.

Recommended voice stack:
- TTS: `flutter_tts` (free, offline, default + fallback); optional ElevenLabs or Google Cloud TTS for premium voices.
- STT: `speech_to_text` (free, OS-based) to start; Whisper or Google Cloud Speech-to-Text as a cloud upgrade.
- Voice-to-voice: use the **pipeline** — `speech_to_text` → LLM (e.g. Claude API) → TTS — not native realtime speech-to-speech APIs. The pipeline gives safety guardrails, lower cost, offline fallback, and control over local voices and languages. Reserve realtime APIs (OpenAI Realtime / Gemini Live) for a possible phase-3 experiment.
- Open question: Nigerian-language voices (Yoruba/Igbo/Hausa) and accents — mainstream TTS coverage is limited and changing; verify current API support before relying on it.

### 7. Wearable / health signals
- Connect a smartwatch via Apple HealthKit (iOS) or Google Health Connect / Wear OS / Fitbit (Android).
- Read **heart rate, HRV, and EDA (stress) signals** — these are the realistic, research-backed signals for arousal. (Note: consumer watches do **not** reliably measure continuous blood pressure.)
- **Early-distress flag** — when arousal spikes, gently alert the parent ("Tunde's heart rate is high, he may need a calm moment").
- Correlate biometrics with mood/usage to spot patterns over time.
- **Calm-down assist** — when a spike is detected, optionally offer the child a soothing breathing visual or their favorite calming content.
- Always framed as a parent support signal, never a medical diagnosis. Health data stays private.

### 8. Parent / caregiver tools (to be detailed later)
- Dashboard: words used, streaks, most-used cards, mood patterns.
- Exportable progress report to share with therapist or teacher.
- Card editor and routine editor.
- Set prizes and rewards.
- Multi-caregiver access (parent + therapist).
- Parent area protected behind a child-proof lock.

### 9. Accessibility and comfort
- **Sensory / quiet mode** — reduce animation, lower sounds, dim bright colors.
- Adjustable text size and high-contrast option.
- Reduce-motion toggle.
- Adjustable button size; left/right-hand friendly layout.
- **Child lock / guided access** — child can't accidentally exit the app or reach settings.

### 10. Platform and technical foundations
- Offline-first local storage (e.g. Hive or sqflite).
- Optional cloud sync for cross-device use (parent + therapist).
- Authentication (e.g. Firebase Auth: email/password + Google).
- Shared card data model: `{ id, label, imagePath, category, audioText }` — used by cards, feelings, and schedule items alike, which makes the parent "edit cards" feature far simpler.

---

## Suggested build phases

Building all of this at once will stall the project. A focused app that works beats an ambitious one that's half-broken.

### Phase 1 — MVP (build this first)
- Talk board with text-to-speech (English first).
- Feelings screen + mood logging.
- Basic visual schedule.
- Customizable cards (photo + label).
- Sensory/quiet mode + child lock.
- Simple parent area (basic stats, card editor).
- Offline-first local storage.

### Phase 2
- Stars / rewards system.
- Full parent dashboard + exportable reports.
- Favorites / most-used.
- Extra language(s) and local voices.
- Smart card prediction.
- AI card-art generation and dashboard insights.

### Phase 3 (advanced)
- Smartwatch connection and stress-signal early warning.
- Calm-down assist.
- AI social stories and setup assistant.
- Biometric + behavior correlation.
- Cloud sync and multi-caregiver.

---

## Responsible scope notes
- Use openly-licensed symbol sets (e.g. ARASAAC) or generated/own art — never copyrighted images pulled from the web.
- State clearly that the app is a support tool, not a medical device or a replacement for professional therapy.
- For a children's app, minimize data collection and keep data on-device wherever possible.
- AAC (picture-based communication) is evidence-based and supports, rather than hinders, speech development — a strong point for your project writeup.

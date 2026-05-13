# Chinnam AAC — CREST Gold Project Write‑Up

**Student (applicant):** Ishan Arun  
**Award level:** CREST **Gold**  
**App name:** Chinnam AAC  
**Project type:** Mobile AAC (Assistive Communication) app built with Flutter  

---

## 1) What this app is (in simple, layman language)

Chinnam AAC is a **communication app for people who find speaking difficult** (or cannot depend on speech every time). Instead of trying to type long messages from scratch, the user can **tap big picture/word buttons** on a grid. Each tap adds a word/phrase into a sentence strip at the top. When the user is ready, the phone can **speak the full sentence out loud** using text‑to‑speech (TTS).

You can think of it as a **digital picture board** on a phone/tablet:
- Visual (pictures/icons and big tiles)
- Predictable (no “AI guessing” words)
- Customizable (caregiver can add/delete words and images)
- Works offline for core features (vocabulary + settings stored on device)

The app also includes a **keyboard mode** (for typing), a **Speak tab** (speech‑to‑text + optional on‑device translation + speak output), and caregiver tools to manage vocabulary and view simple usage statistics.

---

## 2) The real problem it solves

People who use AAC often face these problems:

1) **Communication barrier**  
   The person may be non‑verbal or have unclear speech. They still need to express basic needs (“water”, “pain”, “help”), feelings (“sad”, “happy”), social words (“yes/no”), and sentences.

2) **Speed + independence**  
   Without an AAC tool, communication can be slow (gestures, writing) and the person may need a helper to interpret. With a grid, the person can communicate independently by tapping.

3) **Predictability and trust**  
   Many advanced AAC products use AI predictions. That can be helpful, but it can also feel unpredictable for some users. Chinnam AAC keeps things **manual and caregiver‑controlled** so the user sees consistent vocabulary and layout.

4) **Language in Indian contexts**  
   Many households and schools use Indian languages. Chinnam AAC supports **English and multiple Indian languages** in the UI and supports **TTS voice language selection**.

---

## 3) What features this app has (clear list)

Below are the main user‑visible features currently implemented in this codebase.

### A) Core AAC communication (Picture Grid)
Implemented mainly in: `lib/screens/communication_screen.dart`, `lib/widgets/sentence_bar.dart`, `lib/widgets/vocabulary_grid_item.dart`

- **Vocabulary grid:** a grid of tiles (each tile = one word/phrase) that the user taps.
- **Sentence Bar:** a strip at the top that shows the sentence being built.
  - Remove a specific word by tapping its chip.
  - Backspace (remove last word).
  - Clear the sentence.
  - Speak the sentence aloud.
- **Category filter bar:** filter tiles by category (e.g., QUICK, FOOD, PEOPLE).
- **Frozen row:** optionally show an always‑visible row for important words (e.g., Yes/No).

### B) Keyboard mode (typing)
Implemented mainly in: `lib/screens/keyboard_screen.dart`, `lib/providers/communication_provider.dart`

- **Type your message** using a text field, send it into the sentence bar, and speak it.
- **Simple on‑screen keyboard grid** (basic helper; system keyboard is also used).

### C) Speak tab (voice → text → translate → speak)
Implemented mainly in: `lib/screens/speak_screen.dart`, `lib/services/translation_service.dart`, `packages/speech_recognition/lib/speech_recognition.dart`, `lib/services/tts_service.dart`

- Tap mic → **speech recognition** converts voice to text.
- **Manual input** also supported (type/paste text).
- Optional **on‑device translation** (Google ML Kit Translation) into the selected language.
- Play translation using **TTS** in the selected language voice.

### D) Custom vocabulary creation
Implemented mainly in: `lib/screens/custom_vocabulary_screen.dart`

- Create your own tile:
  - Add an image (camera or gallery).
  - Enter title text (the main label).
  - Optional “detail” text (shown under label).
  - Optional “speech” text (intended for speaking).
  - Choose a category and a color accent.

### E) Caregiver dashboard (management + stats + backup)
Implemented mainly in: `lib/screens/caregiver_dashboard_screen.dart`, `lib/services/storage_service.dart`

- **Vocabulary management** (list + delete; add via dialog).
- **Usage statistics** (simple totals from tap counts):
  - total taps
  - taps per word
  - taps per category
- **Backup export**:
  - exports all vocabulary, usage logs, and settings to a JSON file and shares it.
- **Import backup**:
  - entry exists in UI, but **full import file-picking is not implemented yet** (placeholder function).

### F) Settings (language, layout, accessibility basics)
Implemented mainly in: `lib/screens/settings_screen.dart`, `lib/models/app_settings.dart`, `lib/providers/settings_provider.dart`

- Change **app language** (UI strings).
- Change **theme** (light/dark in UI; highContrast exists in model).
- Change **grid layout** (rows and columns).
- Accessibility toggles used by UI:
  - enable/disable frozen row
  - auto‑speak toggle (used when typing in keyboard mode)

### G) Offline‑first storage + reliability
Implemented mainly in: `lib/services/storage_service.dart`

- Stores data locally using **SQLite**.
- If database init/query fails, it falls back to **SharedPreferences** (so app can still function).

**How many features?**  
For CREST, it’s best to report feature groups (not “lines of code”). This app contains roughly **15–20 major feature groups** (AAC grid, sentence bar, TTS, categories, frozen row, keyboard mode, custom tiles, caregiver dashboard, usage stats, backup export, offline storage, multilingual UI, on‑device translation, speech recognition, settings controls, etc.).

---

## 4) What technologies are used (and why)

This project is built with Flutter and uses a clean “app layers” approach: Models → Services → Providers → Screens/Widgets.

### Core platform
- **Flutter (Dart):** cross‑platform UI framework used to build the whole mobile app (`lib/main.dart`).

### State management
- **Provider:** keeps app state in a predictable way (settings, vocabulary, sentence building).
  - `SettingsProvider` → app settings state
  - `VocabularyProvider` → vocabulary list, categories, usage tracking
  - `CommunicationProvider` → current sentence + speaking logic

### Storage (offline)
- **sqflite (SQLite):** main persistent store for vocabulary and usage logs.
- **SharedPreferences:** stores settings and acts as a fallback store if SQLite fails.

### Speech and language
- **flutter_tts:** turns text into speech.
- **speech_to_text** (via local wrapper `speech_recognition`): turns speech into text (Speak tab).
- **google_mlkit_translation:** on‑device translation models (privacy‑friendly compared to cloud translation).
- **flutter_translate + JSON assets:** app UI strings localized via files in `assets/translations/`.

### Other supporting packages
- **image_picker:** choose tile images from camera/gallery.
- **cached_network_image:** supports tile images via URL with caching.
- **share_plus:** shares exported backup JSON file.
- **path_provider / path:** storage paths and file creation.
- **uuid:** generates unique IDs for vocabulary and logs.

---

## 5) App architecture (how the code is organized)

The app is structured so that UI is separated from data logic:

1) **Models** (`lib/models/`)
   - Define the data structures (VocabularyItem, AppSettings, UsageLog).

2) **Services** (`lib/services/`)
   - `StorageService` for saving/loading data.
   - `TTSService` for speech output.
   - `TranslationService` for on‑device translation.

3) **Providers** (`lib/providers/`)
   - Control state and notify UI when things change.

4) **Screens & Widgets** (`lib/screens/`, `lib/widgets/`)
   - Actual pages: Communication, Speak, Custom, Settings, Caregiver Dashboard.
   - Reusable pieces: SentenceBar, VocabularyGridItem, FrozenRow.

### Example data flow (tap tile → speak)
1. User taps a tile in Communication screen.
2. `CommunicationProvider.addWordToSentence()` adds it into `_currentSentence`.
3. UI updates (`notifyListeners`) and SentenceBar shows the updated sentence.
4. When user taps Speak, `CommunicationProvider.speakCurrentSentence()` calls `TTSService.speak()`.
5. The app logs usage (`UsageLog`) and saves it via `StorageService`.

---

## 6) Data model (what the app stores) + schema (tables)

This section explains the *data model* in plain language and the *actual schema* used in the code.

### A) Main data objects

#### 1) VocabularyItem (one tile on the grid)
Defined in: `lib/models/vocabulary_item.dart`

Stores:
- unique id
- image (local path or URL)
- labels (a map of language → text, e.g. English + translations)
- category (e.g. FOOD, PEOPLE)
- usage tracking (tap count, last used)
- UI metadata (color scheme, position)
- flags (favorite, frozen)

#### 2) AppSettings (user preferences)
Defined in: `lib/models/app_settings.dart`

Stores:
- selected language
- theme mode
- grid size (rows/columns)
- icon/text scaling
- TTS settings (speech rate, pitch, voice)
- accessibility toggles (frozen row, auto‑speak, etc.)

#### 3) UsageLog (a “communication event”)
Defined in: `lib/models/usage_log.dart`

Stores:
- which word was used (vocabulary_item_id)
- timestamp
- language used
- full sentence spoken (optional)
- optional duration

### B) SQLite schema (actual tables created)
Implemented in: `lib/services/storage_service.dart`

#### Table: `vocabulary_items`
- `id` (TEXT, primary key)
- `image_path` (TEXT)
- `image_url` (TEXT)
- `labels` (TEXT; JSON string of language→label map)
- `category` (TEXT)
- `parent_id` (TEXT)
- `related_word_ids` (TEXT; JSON string list)
- `tap_count` (INTEGER)
- `last_used` (TEXT ISO date)
- `is_favorite` (INTEGER 0/1)
- `color_scheme` (TEXT)
- `grid_position` (INTEGER)
- `is_frozen` (INTEGER 0/1)

Index:
- `idx_category` on category

#### Table: `usage_logs`
- `id` (TEXT, primary key)
- `vocabulary_item_id` (TEXT; foreign key reference)
- `timestamp` (TEXT ISO date)
- `language_code` (TEXT)
- `sentence` (TEXT; optional full sentence)
- `session_duration` (INTEGER; stored as microseconds)

Index:
- `idx_timestamp` on timestamp

### C) SharedPreferences keys (settings + fallback)
Also in: `lib/services/storage_service.dart`

- `app_settings` → JSON of AppSettings
- Fallback keys (when DB fails):
  - `vocabulary_items` → JSON list of VocabularyItem
  - `usage_logs` → JSON list of UsageLog (trimmed to last 1000 to control size)

### D) Backup/export format
Exported by: `StorageService.exportAllData()`

The exported JSON contains:
- `vocabulary_items`: list of vocabulary items
- `usage_logs`: list of usage logs
- `settings`: settings object
- `export_date`: timestamp

---

## 7) Current limitations (honest evaluation)

For CREST Gold, it’s good to clearly state what is complete and what still needs improvement.

- **Backup import is not fully implemented** in the UI (the export works; import is placeholder).
- **High contrast theme exists in the data model** but the settings UI currently offers light/dark (high contrast can be added).
- **Some accessibility settings exist in AppSettings** (e.g., switch access scan interval), but are not fully wired into an actual switch scanning UI.
- **Translation model support limits:** ML Kit Translation does not support every language (code explicitly handles Malayalam by falling back).
- **Usage analytics are basic:** currently mostly tap counts and simple totals (could add date filters, charts, sessions).

---

## 8) Future improvements (next steps)

Practical next version improvements:
- Implement full **Import Backup**: file picker + validation + merge/replace options.
- Add a **proper high‑contrast theme** and larger accessibility toggles.
- Add a **caregiver lock / PIN** to protect editing screens.
- Improve analytics: trends over time, top words, category heatmap, session tracking.
- Improve multilingual behavior: cache/store translated labels so the UI does not re‑translate repeatedly.


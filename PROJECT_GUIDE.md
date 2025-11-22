# Awaz AAC - Project Guide

## 📁 Project Folder Structure

```
awaz/
├── lib/                          # Main application code
│   ├── main.dart                 # App entry point, initializes services & providers
│   ├── models/                   # Data models (VocabularyItem, AppSettings, UsageLog)
│   ├── providers/                # State management (Provider pattern)
│   │   ├── communication_provider.dart  # Manages sentence building & TTS
│   │   ├── settings_provider.dart       # Manages app settings
│   │   └── vocabulary_provider.dart     # Manages vocabulary items
│   ├── screens/                  # UI screens
│   │   ├── communication_screen.dart    # Main vocabulary grid screen
│   │   ├── keyboard_screen.dart         # Text input screen
│   │   ├── settings_screen.dart         # Settings screen
│   │   └── caregiver_dashboard_screen.dart  # Admin dashboard
│   ├── services/                 # Business logic & external services
│   │   ├── storage_service.dart         # Database & SharedPreferences
│   │   ├── tts_service.dart             # Text-to-speech
│   │   └── vocabulary_initializer.dart  # Default vocabulary setup
│   ├── utils/                    # Utility functions
│   │   ├── color_utils.dart      # Theme & color management
│   │   ├── image_helper.dart    # Image loading utilities
│   │   └── language_utils.dart  # Language support
│   └── widgets/                  # Reusable UI components
│       ├── vocabulary_grid_item.dart  # Individual vocabulary card
│       ├── sentence_bar.dart          # Sentence display bar
│       └── frozen_row.dart            # Always-visible words row
├── android/                      # Android-specific code
├── assets/                       # Images, icons, etc.
└── pubspec.yaml                  # Dependencies & project config
```

## 🔄 Application Flow

### 1. **App Startup (main.dart)**
```
main() function:
  ├── Initialize StorageService (database)
  ├── Initialize TTSService (text-to-speech)
  ├── Initialize default vocabulary
  └── Set portrait orientation
    └── Run AwazApp
```

### 2. **Provider Setup (main.dart)**
```
MultiProvider wraps the app:
  ├── SettingsProvider      → Manages app settings (theme, language, etc.)
  ├── VocabularyProvider    → Manages vocabulary items
  └── CommunicationProvider → Manages sentence building & TTS
      (depends on VocabularyProvider & SettingsProvider)
```

### 3. **Main Screen Flow (CommunicationScreen)**
```
User opens app:
  ├── Load settings from StorageService
  ├── Load vocabulary items from StorageService
  └── Display vocabulary grid
      │
      ├── User taps vocabulary item
      │   └── CommunicationProvider.addWordToSentence()
      │       ├── Add word to current sentence
      │       ├── Record usage in VocabularyProvider
      │       └── Update UI (notifyListeners)
      │
      ├── User builds sentence
      │   └── Sentence displayed in SentenceBar widget
      │
      └── User taps speak button
          └── CommunicationProvider.speakCurrentSentence()
              ├── Get sentence text
              ├── Call TTSService.speak()
              └── Log usage in StorageService
```

### 4. **Data Flow**

#### **Vocabulary Management:**
```
CaregiverDashboardScreen
  └── Add/Edit/Delete vocabulary
      └── VocabularyProvider
          └── StorageService
              ├── Save to SQLite database (primary)
              └── Fallback to SharedPreferences (if DB fails)
```

#### **Settings Management:**
```
SettingsScreen
  └── Change settings (theme, language, etc.)
      └── SettingsProvider
          ├── Update StorageService
          └── Apply to TTSService
```

#### **Communication:**
```
CommunicationScreen
  └── User interaction
      └── CommunicationProvider
          ├── Build sentence (list of VocabularyItem)
          ├── TTSService (speak text)
          └── StorageService (log usage)
```

## 📦 Dependencies & How They Work

### **State Management**
- **`provider: ^6.1.1`** - State management pattern
  - `ChangeNotifierProvider` - Provides state to widgets
  - `Consumer` - Listens to state changes
  - `MultiProvider` - Combines multiple providers
  - **How it works:** Providers hold state, notify listeners when state changes, widgets rebuild automatically

### **Text-to-Speech**
- **`flutter_tts: ^4.0.2`** - Text-to-speech engine
  - Converts text to speech in multiple languages
  - Supports Indian languages (Hindi, Tamil, Telugu, etc.)
  - **How it works:** TTSService wraps FlutterTts, sets language/rate/pitch, calls speak() method

### **Database**
- **`sqflite: ^2.3.0`** - SQLite database for Android
  - Stores vocabulary items, usage logs
  - **How it works:** SQLite database file in app documents directory, tables for vocabulary_items and usage_logs
- **`shared_preferences: ^2.2.2`** - Key-value storage
  - Stores app settings, fallback for vocabulary if DB fails
  - **How it works:** Simple key-value pairs stored in device storage

### **File System**
- **`path_provider: ^2.1.1`** - Get device file paths
  - Gets app documents directory for database
  - **How it works:** Returns File object pointing to app's data directory
- **`path: ^1.8.3`** - Path manipulation utilities
  - Joins file paths correctly

### **JSON Serialization**
- **`json_annotation: ^4.8.1`** - Annotations for JSON
- **`json_serializable: ^6.7.1`** (dev) - Code generator
- **`build_runner: ^2.4.7`** (dev) - Runs code generators
  - **How it works:** Annotations mark classes, build_runner generates toJson/fromJson methods

### **Image Handling**
- **`image_picker: ^1.0.7`** - Pick images from gallery/camera
  - Used in CaregiverDashboardScreen to add vocabulary images
  - **How it works:** Opens device image picker, returns file path
- **`cached_network_image: ^3.3.1`** - Load network images with caching
  - Displays vocabulary item images from URLs
  - **How it works:** Downloads and caches images, shows placeholder while loading

### **Utilities**
- **`uuid: ^4.2.1`** - Generate unique IDs
  - Creates unique IDs for vocabulary items, usage logs
  - **How it works:** Generates UUID v4 strings

### **Sharing/Export**
- **`share_plus: ^7.2.1`** - Share files/data
  - Exports backup data (vocabulary, logs, settings)
  - **How it works:** Shares files through Android share sheet

## 🏗️ Architecture Pattern

### **Provider Pattern (State Management)**
```
┌─────────────────┐
│   Widget        │
│  (UI Layer)     │
└────────┬────────┘
         │ listens to
         ▼
┌─────────────────┐
│   Provider      │
│  (State Layer)  │
└────────┬────────┘
         │ uses
         ▼
┌─────────────────┐
│   Service       │
│  (Logic Layer)  │
└────────┬────────┘
         │ stores in
         ▼
┌─────────────────┐
│   Storage       │
│  (Data Layer)   │
└─────────────────┘
```

### **Service Layer Pattern**
- **StorageService** - Singleton, handles all data persistence
- **TTSService** - Singleton, handles all text-to-speech
- Services are initialized once in main() and reused throughout app

### **Model Layer**
- All data models use JSON serialization
- Models are immutable (use copyWith for updates)
- Models stored in database as JSON strings

## 🔧 Key Components Explained

### **CommunicationProvider**
- **Purpose:** Manages sentence building and speech
- **State:**
  - `_currentSentence` - List of VocabularyItems user has selected
  - `_isKeyboardMode` - Whether keyboard mode is active
- **Methods:**
  - `addWordToSentence()` - Adds word to sentence, records usage
  - `speakCurrentSentence()` - Converts sentence to text, speaks it
  - `clearSentence()` - Clears current sentence
  - `removeLastWord()` - Removes last word from sentence

### **VocabularyProvider**
- **Purpose:** Manages vocabulary items
- **State:**
  - `_vocabularyItems` - List of all vocabulary items
  - `_recentWords` - Recently used words
  - `_currentCategory` - Currently filtered category
- **Methods:**
  - `loadVocabularyItems()` - Loads from StorageService
  - `addVocabularyItem()` - Adds new vocabulary item
  - `recordWordUsage()` - Tracks word usage statistics

### **StorageService**
- **Purpose:** Data persistence layer
- **Storage Strategy:**
  1. Primary: SQLite database (sqflite)
  2. Fallback: SharedPreferences (if DB fails)
- **Tables:**
  - `vocabulary_items` - All vocabulary words/phrases
  - `usage_logs` - Usage tracking data
- **Methods:**
  - `saveVocabularyItem()` - Saves to DB, falls back to SharedPreferences
  - `getAllVocabularyItems()` - Loads from DB, falls back to SharedPreferences
  - `saveUsageLog()` - Logs word usage
  - `exportAllData()` - Exports all data as JSON

## 🚀 Android Optimization

### **Removed Web Support:**
- ✅ Removed all `kIsWeb` checks
- ✅ Removed conditional imports for web
- ✅ Deleted web stub files (database_stub, file_stub, etc.)
- ✅ Simplified storage to use SQLite directly (no web fallback logic)

### **Android-Specific Features:**
- Uses SQLite database (not available on web)
- Uses File API for images (not available on web)
- Uses path_provider for file paths (Android-specific)

## 📱 How to Run

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate JSON serialization code:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Run on Android:**
   ```bash
   flutter run -d <android-device-id>
   ```

4. **Build APK:**
   ```bash
   flutter build apk
   ```

## 🔍 Troubleshooting

- **Missing dependencies:** Run `flutter pub get`
- **JSON errors:** Run `flutter pub run build_runner build`
- **Database errors:** Check Android permissions in AndroidManifest.xml
- **TTS not working:** Check device language support




# Awaz AAC - Assistive Communication App

An assistive communication application for people with disabilities, built with Flutter. Similar to Avaz AAC but without AI-based features, focusing on manual customization and reliability.

## Features

### Core Communication Features
- **Vocabulary Grid**: Tap images/icons to build sentences with text and voice output
- **Picture Mode**: Visual grid-based communication with customizable icons
- **Keyboard Mode**: Text entry mode for manual typing
- **Text-to-Speech**: Natural voice output in multiple languages
- **Multi-language Support**: English + Indian languages (Hindi, Tamil, Kannada, Telugu, Malayalam, Marathi, Bengali, Gujarati)

### Customization
- **Customizable Grid Layout**: Adjustable rows and columns
- **Icon Size Control**: Scale icons for accessibility
- **Color Coding**: Color-coded vocabulary items by category
- **Manual Image Assignment**: Upload or select images and manually assign words/phrases
- **Frozen Row**: Keep frequently used words always visible
- **Category Organization**: Organize vocabulary by categories

### Accessibility Features
- **High Contrast Themes**: Light, Dark, and High Contrast modes
- **Large Icons**: Adjustable icon sizes for motor control limitations
- **Screen Reader Support**: Compatible with accessibility services
- **Switch Access**: Support for switch-based navigation (configurable)
- **Simple Navigation**: Clear, consistent interface

### Caregiver/Therapist Tools
- **Vocabulary Management**: Add, edit, and delete vocabulary items
- **Usage Tracking**: Monitor word usage, tap counts, and session data
- **Usage Statistics**: View most used words and category analytics
- **Backup & Export**: Export all data (vocabulary, logs, settings) for backup
- **Import Data**: Restore from backup files

### Settings
- **Language Selection**: Switch between supported languages
- **Speech Settings**: Adjust speech rate and pitch
- **Display Settings**: Toggle text labels, icon sizes
- **Accessibility Options**: Configure frozen row, auto-speak, screen reader, switch access

## Architecture

### Data Models
- `VocabularyItem`: Represents a vocabulary word/phrase with images, labels, and metadata
- `AppSettings`: Application settings (theme, language, grid layout, etc.)
- `UsageLog`: Tracks usage of vocabulary items
- `UsageStatistics`: Aggregated usage data

### Services
- `TTSService`: Text-to-speech functionality with multi-language support
- `StorageService`: Database and local storage management
- `VocabularyInitializer`: Initializes default vocabulary items

### Providers (State Management)
- `VocabularyProvider`: Manages vocabulary items and categories
- `SettingsProvider`: Manages application settings
- `CommunicationProvider`: Handles sentence building and TTS

### Screens
- `CommunicationScreen`: Main vocabulary grid interface
- `KeyboardScreen`: Text entry mode
- `SettingsScreen`: Application settings
- `CaregiverDashboardScreen`: Vocabulary management and usage statistics

## Setup

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd awaz
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building for Android

```bash
flutter build apk
```

### Building for iOS

```bash
flutter build ios
```

## Usage

### For Users
1. **Start Communicating**: Open the app and tap on vocabulary items to build sentences
2. **Switch Modes**: Use the keyboard icon to toggle between picture and keyboard mode
3. **Speak**: Tap the speaker icon or enable auto-speak in settings
4. **Customize**: Access settings to adjust grid layout, icon size, and theme

### For Caregivers/Therapists
1. **Add Vocabulary**: Use the Caregiver Dashboard to add new words with images
2. **Track Usage**: View usage statistics to understand communication patterns
3. **Backup Data**: Export data regularly for backup and device migration
4. **Customize**: Adjust settings to match user needs and preferences

## Key Differences from AI-based AAC Apps

- **No Automatic Image Recognition**: Images must be manually assigned to words
- **No AI Autocomplete**: Simple recent/favorite words suggestions instead of predictive text
- **Manual Control**: All vocabulary management is manual, ensuring reliability and predictability
- **Simplified Interface**: Focus on core communication without complex AI features

## Supported Languages

- English (en)
- Hindi (hi) - हिंदी
- Tamil (ta) - தமிழ்
- Telugu (te) - తెలుగు
- Kannada (kn) - ಕನ್ನಡ
- Malayalam (ml) - മലയാളം
- Marathi (mr) - मराठी
- Bengali (bn) - বাংলা
- Gujarati (gu) - ગુજરાતી

## Dependencies

- `flutter_tts`: Text-to-speech
- `sqflite`: Local database
- `shared_preferences`: Settings storage
- `provider`: State management
- `image_picker`: Image selection
- `path_provider`: File system access
- `share_plus`: Export/sharing functionality

## License

[Add your license here]

## Contributing

[Add contribution guidelines here]

## Support

For issues and feature requests, please open an issue on the repository.

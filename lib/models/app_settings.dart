class AppSettings {
  final String currentLanguage; // Language code (en, hi, ta, etc.)
  final AppThemeMode themeMode; // light, dark, highContrast
  final int gridRows;
  final int gridColumns;
  final double iconSize; // Percentage or fixed size
  final bool showTextLabels;
  final bool enableSoundEffects;
  final bool enableVibration;
  final double speechRate;
  final double speechPitch;
  final String? selectedVoice; // TTS voice identifier
  final bool enableFrozenRow;
  final int frozenRowCount;
  final bool enableSwitchAccess;
  final int switchAccessScanInterval; // milliseconds
  final bool enableScreenReader;
  final List<String> favoriteCategories;
  final bool autoSpeak; // Auto speak on selection
  final int maxRecentWords; // For recent words suggestions

    AppSettings({
    this.currentLanguage = 'en',
    this.themeMode = AppThemeMode.light,
    this.gridRows = 4,
    this.gridColumns = 4,
    this.iconSize = 1.0,
    this.showTextLabels = true,
    this.enableSoundEffects = true,
    this.enableVibration = false,
    this.speechRate = 0.5,
    this.speechPitch = 1.0,
    this.selectedVoice,
    this.enableFrozenRow = true,
    this.frozenRowCount = 1,
    this.enableSwitchAccess = false,
    this.switchAccessScanInterval = 1000,
    this.enableScreenReader = true,
    this.favoriteCategories = const [],
    this.autoSpeak = true,
    this.maxRecentWords = 10,
  });

  AppSettings copyWith({
    String? currentLanguage,
    AppThemeMode? themeMode,
    int? gridRows,
    int? gridColumns,
    double? iconSize,
    bool? showTextLabels,
    bool? enableSoundEffects,
    bool? enableVibration,
    double? speechRate,
    double? speechPitch,
    String? selectedVoice,
    bool? enableFrozenRow,
    int? frozenRowCount,
    bool? enableSwitchAccess,
    int? switchAccessScanInterval,
    bool? enableScreenReader,
    List<String>? favoriteCategories,
    bool? autoSpeak,
    int? maxRecentWords,
  }) {
    return AppSettings(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      themeMode: themeMode ?? this.themeMode,
      gridRows: gridRows ?? this.gridRows,
      gridColumns: gridColumns ?? this.gridColumns,
      iconSize: iconSize ?? this.iconSize,
      showTextLabels: showTextLabels ?? this.showTextLabels,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
      enableVibration: enableVibration ?? this.enableVibration,
      speechRate: speechRate ?? this.speechRate,
      speechPitch: speechPitch ?? this.speechPitch,
      selectedVoice: selectedVoice ?? this.selectedVoice,
      enableFrozenRow: enableFrozenRow ?? this.enableFrozenRow,
      frozenRowCount: frozenRowCount ?? this.frozenRowCount,
      enableSwitchAccess: enableSwitchAccess ?? this.enableSwitchAccess,
      switchAccessScanInterval:
          switchAccessScanInterval ?? this.switchAccessScanInterval,
      enableScreenReader: enableScreenReader ?? this.enableScreenReader,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      autoSpeak: autoSpeak ?? this.autoSpeak,
      maxRecentWords: maxRecentWords ?? this.maxRecentWords,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      currentLanguage: json['currentLanguage'] as String? ?? 'en',
      themeMode: _themeModeFromString(json['themeMode'] as String?),
      gridRows: json['gridRows'] as int? ?? 4,
      gridColumns: json['gridColumns'] as int? ?? 4,
      iconSize: (json['iconSize'] as num?)?.toDouble() ?? 1.0,
      showTextLabels: json['showTextLabels'] as bool? ?? true,
      enableSoundEffects: json['enableSoundEffects'] as bool? ?? true,
      enableVibration: json['enableVibration'] as bool? ?? false,
      speechRate: (json['speechRate'] as num?)?.toDouble() ?? 0.5,
      speechPitch: (json['speechPitch'] as num?)?.toDouble() ?? 1.0,
      selectedVoice: json['selectedVoice'] as String?,
      enableFrozenRow: json['enableFrozenRow'] as bool? ?? true,
      frozenRowCount: json['frozenRowCount'] as int? ?? 1,
      enableSwitchAccess: json['enableSwitchAccess'] as bool? ?? false,
      switchAccessScanInterval: json['switchAccessScanInterval'] as int? ?? 1000,
      enableScreenReader: json['enableScreenReader'] as bool? ?? true,
      favoriteCategories: (json['favoriteCategories'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          const [],
      autoSpeak: json['autoSpeak'] as bool? ?? true,
      maxRecentWords: json['maxRecentWords'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentLanguage': currentLanguage,
      'themeMode': themeMode.name,
      'gridRows': gridRows,
      'gridColumns': gridColumns,
      'iconSize': iconSize,
      'showTextLabels': showTextLabels,
      'enableSoundEffects': enableSoundEffects,
      'enableVibration': enableVibration,
      'speechRate': speechRate,
      'speechPitch': speechPitch,
      'selectedVoice': selectedVoice,
      'enableFrozenRow': enableFrozenRow,
      'frozenRowCount': frozenRowCount,
      'enableSwitchAccess': enableSwitchAccess,
      'switchAccessScanInterval': switchAccessScanInterval,
      'enableScreenReader': enableScreenReader,
      'favoriteCategories': favoriteCategories,
      'autoSpeak': autoSpeak,
      'maxRecentWords': maxRecentWords,
    };
  }
}

enum AppThemeMode {
  light,
  dark,
  highContrast,
}

AppThemeMode _themeModeFromString(String? value) {
  switch (value) {
    case 'dark':
      return AppThemeMode.dark;
    default:
      return AppThemeMode.light;
  }
}

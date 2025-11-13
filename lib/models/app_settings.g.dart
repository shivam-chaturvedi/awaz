// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
  currentLanguage: json['currentLanguage'] as String? ?? 'en',
  themeMode:
      $enumDecodeNullable(_$AppThemeModeEnumMap, json['themeMode']) ??
      AppThemeMode.light,
  gridRows: (json['gridRows'] as num?)?.toInt() ?? 4,
  gridColumns: (json['gridColumns'] as num?)?.toInt() ?? 4,
  iconSize: (json['iconSize'] as num?)?.toDouble() ?? 1.0,
  showTextLabels: json['showTextLabels'] as bool? ?? true,
  enableSoundEffects: json['enableSoundEffects'] as bool? ?? true,
  enableVibration: json['enableVibration'] as bool? ?? false,
  speechRate: (json['speechRate'] as num?)?.toDouble() ?? 0.5,
  speechPitch: (json['speechPitch'] as num?)?.toDouble() ?? 1.0,
  selectedVoice: json['selectedVoice'] as String?,
  enableFrozenRow: json['enableFrozenRow'] as bool? ?? true,
  frozenRowCount: (json['frozenRowCount'] as num?)?.toInt() ?? 1,
  enableSwitchAccess: json['enableSwitchAccess'] as bool? ?? false,
  switchAccessScanInterval:
      (json['switchAccessScanInterval'] as num?)?.toInt() ?? 1000,
  enableScreenReader: json['enableScreenReader'] as bool? ?? true,
  favoriteCategories:
      (json['favoriteCategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  autoSpeak: json['autoSpeak'] as bool? ?? true,
  maxRecentWords: (json['maxRecentWords'] as num?)?.toInt() ?? 10,
);

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'currentLanguage': instance.currentLanguage,
      'themeMode': _$AppThemeModeEnumMap[instance.themeMode]!,
      'gridRows': instance.gridRows,
      'gridColumns': instance.gridColumns,
      'iconSize': instance.iconSize,
      'showTextLabels': instance.showTextLabels,
      'enableSoundEffects': instance.enableSoundEffects,
      'enableVibration': instance.enableVibration,
      'speechRate': instance.speechRate,
      'speechPitch': instance.speechPitch,
      'selectedVoice': instance.selectedVoice,
      'enableFrozenRow': instance.enableFrozenRow,
      'frozenRowCount': instance.frozenRowCount,
      'enableSwitchAccess': instance.enableSwitchAccess,
      'switchAccessScanInterval': instance.switchAccessScanInterval,
      'enableScreenReader': instance.enableScreenReader,
      'favoriteCategories': instance.favoriteCategories,
      'autoSpeak': instance.autoSpeak,
      'maxRecentWords': instance.maxRecentWords,
    };

const _$AppThemeModeEnumMap = {
  AppThemeMode.light: 'light',
  AppThemeMode.dark: 'dark',
  AppThemeMode.highContrast: 'highContrast',
};

import 'package:flutter/material.dart';
import '../models/vocabulary_item.dart';
import '../models/app_settings.dart';

class ColorUtils {
  static Color getColorForScheme(VocabularyColorScheme scheme) {
    switch (scheme) {
      case VocabularyColorScheme.blue:
        return Colors.blue;
      case VocabularyColorScheme.green:
        return Colors.green;
      case VocabularyColorScheme.yellow:
        return Colors.yellow;
      case VocabularyColorScheme.orange:
        return Colors.orange;
      case VocabularyColorScheme.red:
        return Colors.red;
      case VocabularyColorScheme.purple:
        return Colors.purple;
      case VocabularyColorScheme.brown:
        return Colors.brown;
      case VocabularyColorScheme.white:
        return Colors.white;
      case VocabularyColorScheme.lightBlue:
        return Colors.lightBlue;
      case VocabularyColorScheme.pink:
        return Colors.pink;
      case VocabularyColorScheme.gray:
        return Colors.grey;
    }
  }

  static Color getTextColorForScheme(VocabularyColorScheme scheme, bool isDark) {
    final color = getColorForScheme(scheme);
    if (isDark) {
      return Colors.white;
    }
    // Return contrasting text color
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  static ThemeData getThemeForMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        );
      case AppThemeMode.dark:
        return ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[900],
        );
      case AppThemeMode.highContrast:
        return ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            secondary: Colors.yellow,
            surface: Colors.black,
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onSurface: Colors.white,
          ),
        );
    }
  }
}


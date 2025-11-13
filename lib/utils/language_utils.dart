class LanguageUtils {
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिंदी (Hindi)',
    'ta': 'தமிழ் (Tamil)',
    'te': 'తెలుగు (Telugu)',
    'kn': 'ಕನ್ನಡ (Kannada)',
    'ml': 'മലയാളം (Malayalam)',
    'mr': 'मराठी (Marathi)',
    'bn': 'বাংলা (Bengali)',
    'gu': 'ગુજરાતી (Gujarati)',
  };

  static const List<String> supportedLanguages = [
    'en',
    'hi',
    'ta',
    'te',
    'kn',
    'ml',
    'mr',
    'bn',
    'gu',
  ];

  static String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }

  static bool isSupported(String languageCode) {
    return supportedLanguages.contains(languageCode);
  }
}



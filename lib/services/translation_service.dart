import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final Map<String, OnDeviceTranslator> _translators = {};
  final Map<String, String> _translationCache = {};

  Future<String> translate({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'en',
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return '';

    try {
      final cacheKey = '${normalizedText}_$sourceLanguage\_$targetLanguage';
      if (_translationCache.containsKey(cacheKey)) {
        return _translationCache[cacheKey]!;
      }

      final translatorKey = '${sourceLanguage}_$targetLanguage';

      // Create translator if not exists
      if (!_translators.containsKey(translatorKey)) {
        final sourceLang = _getTranslateLanguage(sourceLanguage);
        final targetLang = _getTranslateLanguage(targetLanguage);

        _translators[translatorKey] = OnDeviceTranslator(
          sourceLanguage: sourceLang,
          targetLanguage: targetLang,
        );
      }

      final translator = _translators[translatorKey]!;
      
      // Check if models are downloaded
      final modelManager = OnDeviceTranslatorModelManager();
      final targetLang = _getTranslateLanguage(targetLanguage);
      final sourceLangModel = _getTranslateLanguage(sourceLanguage);
      
      final isSourceDownloaded = await modelManager.isModelDownloaded(sourceLangModel.bcpCode);
      if (!isSourceDownloaded) {
        debugPrint('Translation: Downloading model for $sourceLanguage...');
        await modelManager.downloadModel(sourceLangModel.bcpCode);
      }

      final isDownloaded = await modelManager.isModelDownloaded(targetLang.bcpCode);
      if (!isDownloaded) {
        debugPrint('Translation: Downloading model for $targetLanguage...');
        await modelManager.downloadModel(targetLang.bcpCode);
        debugPrint('Translation: Model downloaded for $targetLanguage');
      }

      // Translate
      final result = await translator.translateText(normalizedText);
      debugPrint('Translation: "$text" -> "$result" ($sourceLanguage -> $targetLanguage)');
      _translationCache[cacheKey] = result;
      return result;
    } catch (e) {
      debugPrint('Translation error: $e');
      return text; // Return original text on error
    }
  }

  TranslateLanguage _getTranslateLanguage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return TranslateLanguage.english;
      case 'hi':
        return TranslateLanguage.hindi;
      case 'bn':
        return TranslateLanguage.bengali;
      case 'ta':
        return TranslateLanguage.tamil;
      case 'te':
        return TranslateLanguage.telugu;
      case 'kn':
        return TranslateLanguage.kannada;
      case 'mr':
        return TranslateLanguage.marathi;
      case 'gu':
        return TranslateLanguage.gujarati;
      case 'ml':
        // Malayalam is NOT supported by ML Kit Translation
        // Fall back to English
        debugPrint('Warning: Malayalam translation not supported by ML Kit, falling back to English');
        return TranslateLanguage.english;
      default:
        return TranslateLanguage.english;
    }
  }

  Future<bool> isModelDownloaded(String languageCode) async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      final language = _getTranslateLanguage(languageCode);
      return await modelManager.isModelDownloaded(language.bcpCode);
    } catch (e) {
      debugPrint('Error checking model: $e');
      return false;
    }
  }

  Future<void> downloadModel(String languageCode) async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      final language = _getTranslateLanguage(languageCode);
      await modelManager.downloadModel(language.bcpCode);
      debugPrint('Downloaded translation model for $languageCode');
    } catch (e) {
      debugPrint('Error downloading model: $e');
    }
  }

  Future<void> deleteModel(String languageCode) async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      final language = _getTranslateLanguage(languageCode);
      await modelManager.deleteModel(language.bcpCode);
      debugPrint('Deleted translation model for $languageCode');
    } catch (e) {
      debugPrint('Error deleting model: $e');
    }
  }

  void dispose() {
    for (var translator in _translators.values) {
      translator.close();
    }
    _translators.clear();
  }
}

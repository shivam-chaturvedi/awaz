import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  String _currentLanguage = 'en';
  Future<void>? _initFuture;
  Future<void> _speakFuture = Future.value();

  Future<void> initialize() {
    if (_isInitialized) return Future.value();
    return _initFuture ??= _doInitialize();
  }

  Future<void> _doInitialize() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSpeakCompletion(true);
      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS: initialize failed: $e');
      _initFuture = null; // allow retry
    }
  }

  Future<void> setLanguage(String languageCode) async {
    await initialize();
    _currentLanguage = languageCode;
    
    // Map language codes to TTS language codes
    String ttsLanguageCode = _getTTSLanguageCode(languageCode);
    
    debugPrint('TTS: Setting language from $languageCode to $ttsLanguageCode');
    
    try {
      await _flutterTts.setLanguage(ttsLanguageCode);
      debugPrint('TTS: Successfully set language to $ttsLanguageCode');
    } catch (e) {
      debugPrint('TTS: Error setting language to $ttsLanguageCode: $e');
      // Fallback to English
      try {
        await _flutterTts.setLanguage('en-US');
        debugPrint('TTS: Fallback to en-US successful');
      } catch (fallbackError) {
        debugPrint('TTS: Fallback to en-US also failed: $fallbackError');
      }
    }
  }

  String _getTTSLanguageCode(String languageCode) {
    // Map Indian languages and English to TTS language codes
    final Map<String, String> languageMap = {
      'en': 'en-US',
      'hi': 'hi-IN', // Hindi
      'ta': 'ta-IN', // Tamil
      'te': 'te-IN', // Telugu
      'kn': 'kn-IN', // Kannada
      'ml': 'ml-IN', // Malayalam
      'mr': 'mr-IN', // Marathi
      'bn': 'bn-IN', // Bengali
      'gu': 'gu-IN', // Gujarati
      'es': 'es-ES', // Spanish
      'de': 'de-DE', // German
      'fr': 'fr-FR', // French
    };
    
    return languageMap[languageCode] ?? 'en-US';
  }

  Future<void> setSpeechRate(double rate) async {
    await initialize();
    try {
      await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('TTS: setSpeechRate failed: $e');
    }
  }

  Future<void> setPitch(double pitch) async {
    await initialize();
    try {
      await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
    } catch (e) {
      debugPrint('TTS: setPitch failed: $e');
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    
    await initialize();
    debugPrint('TTS: Speaking text in language $_currentLanguage: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
    
    _speakFuture = _speakFuture.then((_) async {
      try {
        await _flutterTts.setLanguage(_getTTSLanguageCode(_currentLanguage));
        await _flutterTts.speak(text);
      } catch (e) {
        debugPrint('TTS: speak failed: $e');
      }
    });
    
    return _speakFuture;
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS: stop failed: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      debugPrint('TTS: pause failed: $e');
    }
  }

  Future<List<dynamic>> getAvailableLanguages() async {
    await initialize();
    try {
      return await _flutterTts.getLanguages;
    } catch (e) {
      debugPrint('TTS: getAvailableLanguages failed: $e');
      return const [];
    }
  }

  Future<List<dynamic>> getAvailableVoices() async {
    await initialize();
    try {
      return await _flutterTts.getVoices;
    } catch (e) {
      debugPrint('TTS: getAvailableVoices failed: $e');
      return const [];
    }
  }

  Future<void> setVoice(String voiceIdentifier) async {
    await initialize();
    try {
      await _flutterTts.setVoice(
        {'name': voiceIdentifier, 'locale': _getTTSLanguageCode(_currentLanguage)},
      );
    } catch (e) {
      debugPrint('TTS: setVoice failed: $e');
    }
  }

  String get currentLanguage => _currentLanguage;
}

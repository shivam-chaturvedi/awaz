import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  String _currentLanguage = 'en';

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _isInitialized = true;
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    
    // Map language codes to TTS language codes
    String ttsLanguageCode = _getTTSLanguageCode(languageCode);
    
    try {
      await _flutterTts.setLanguage(ttsLanguageCode);
    } catch (e) {
      debugPrint('Error setting TTS language: $e');
      // Fallback to English
      await _flutterTts.setLanguage('en-US');
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
    };
    
    return languageMap[languageCode] ?? 'en-US';
  }

  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
  }

  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    
    await initialize();
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> pause() async {
    await _flutterTts.pause();
  }

  Future<List<dynamic>> getAvailableLanguages() async {
    await initialize();
    return await _flutterTts.getLanguages;
  }

  Future<List<dynamic>> getAvailableVoices() async {
    await initialize();
    return await _flutterTts.getVoices;
  }

  Future<void> setVoice(String voiceIdentifier) async {
    await initialize();
    await _flutterTts.setVoice({'name': voiceIdentifier, 'locale': _getTTSLanguageCode(_currentLanguage)});
  }

  String get currentLanguage => _currentLanguage;
}



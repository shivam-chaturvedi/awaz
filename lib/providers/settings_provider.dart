import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final TTSService _ttsService = TTSService();
  AppSettings _settings = AppSettings();
  bool _isLoading = false;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _storageService.getSettings();
      await _applySettings();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    try {
      _settings = newSettings;
      await _storageService.saveSettings(_settings);
      await _applySettings();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating settings: $e');
    }
  }

  Future<void> _applySettings() async {
    // Apply TTS settings
    await _ttsService.setLanguage(_settings.currentLanguage);
    await _ttsService.setSpeechRate(_settings.speechRate);
    await _ttsService.setPitch(_settings.speechPitch);
    if (_settings.selectedVoice != null) {
      await _ttsService.setVoice(_settings.selectedVoice!);
    }
  }

  Future<void> setLanguage(String languageCode) async {
    final updated = _settings.copyWith(currentLanguage: languageCode);
    await updateSettings(updated);
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    final updated = _settings.copyWith(themeMode: themeMode);
    await updateSettings(updated);
  }

  Future<void> setGridLayout(int rows, int columns) async {
    final updated = _settings.copyWith(gridRows: rows, gridColumns: columns);
    await updateSettings(updated);
  }

  Future<void> setIconSize(double size) async {
    final updated = _settings.copyWith(iconSize: size);
    await updateSettings(updated);
  }

  Future<void> setSpeechRate(double rate) async {
    final updated = _settings.copyWith(speechRate: rate);
    await updateSettings(updated);
  }

  Future<void> setSpeechPitch(double pitch) async {
    final updated = _settings.copyWith(speechPitch: pitch);
    await updateSettings(updated);
  }
}


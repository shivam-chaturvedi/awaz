import 'package:flutter/foundation.dart';
import '../models/vocabulary_item.dart';
import '../models/usage_log.dart';
import '../services/storage_service.dart';
import '../services/translation_service.dart';
import '../services/tts_service.dart';
import 'vocabulary_provider.dart';
import 'settings_provider.dart';
import 'package:uuid/uuid.dart';

class CommunicationProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final TTSService _ttsService = TTSService();
  VocabularyProvider? _vocabularyProvider;
  SettingsProvider? _settingsProvider;
  final Uuid _uuid = const Uuid();

  List<VocabularyItem> _currentSentence = [];
  bool _isKeyboardMode = false;

  List<VocabularyItem> get currentSentence => _currentSentence;
  bool get isKeyboardMode => _isKeyboardMode;

  CommunicationProvider(VocabularyProvider? vocabularyProvider, SettingsProvider? settingsProvider)
      : _vocabularyProvider = vocabularyProvider,
        _settingsProvider = settingsProvider;
  
  void updateProviders(VocabularyProvider vocabularyProvider, SettingsProvider settingsProvider) {
    _vocabularyProvider = vocabularyProvider;
    _settingsProvider = settingsProvider;
  }

  void toggleKeyboardMode() {
    _isKeyboardMode = !_isKeyboardMode;
    notifyListeners();
  }

  void setKeyboardMode(bool isKeyboard) {
    _isKeyboardMode = isKeyboard;
    notifyListeners();
  }

  Future<void> addWordToSentence(VocabularyItem item) async {
    debugPrint('addWordToSentence called with item: ${item.id}');
    debugPrint('Current sentence length before: ${_currentSentence.length}');
    final languageCode = _settingsProvider?.settings.currentLanguage ?? 'en';
    var localizedItem = item;

    if (languageCode != 'en') {
      try {
        final baseText = item.labels['en'] ?? item.labels.values.first;
        final translatedText = await TranslationService().translate(
          text: baseText,
          targetLanguage: languageCode,
        );
        localizedItem = item.copyWith(
          labels: {...item.labels, languageCode: translatedText},
        );
      } catch (e) {
        debugPrint('Translation failed in sentence builder: $e');
      }
    }

    _currentSentence = [..._currentSentence, localizedItem];
    
    // Debug: Print added word
    debugPrint('Added word: ${localizedItem.getLabel(languageCode)}, Total: ${_currentSentence.length}');
    debugPrint('Notifying listeners...');
    
    // Immediately notify listeners
    notifyListeners();
    
    debugPrint('Listeners notified. Current sentence: ${_currentSentence.map((i) => i.getLabel(_settingsProvider?.settings.currentLanguage ?? 'en')).join(' ')}');

    // Record usage (async, but don't wait for it to update UI)
    _vocabularyProvider?.recordWordUsage(item.id);

    // Don't auto-speak individual words - let user build sentence first
    // Auto-speak only when explicitly requested or when sentence is complete
  }

  Future<void> addTextToSentence(String text) async {
    // Create a temporary vocabulary item for typed text
    final languageCode = _settingsProvider?.settings.currentLanguage ?? 'en';
    final item = VocabularyItem(
      id: _uuid.v4(),
      labels: {languageCode: text},
      category: 'TYPED',
    );
    _currentSentence = [..._currentSentence, item];
    notifyListeners();

    // Auto-speak if enabled
    if (_settingsProvider?.settings.autoSpeak ?? true) {
      await speakCurrentSentence();
    }
  }

  void clearSentence() {
    _currentSentence = [];
    notifyListeners();
  }

  void removeLastWord() {
    if (_currentSentence.isNotEmpty) {
      _currentSentence = List.from(_currentSentence)..removeLast();
      notifyListeners();
    }
  }

  void removeWordAt(int index) {
    if (index >= 0 && index < _currentSentence.length) {
      _currentSentence = List.from(_currentSentence)..removeAt(index);
      notifyListeners();
    }
  }

  String getSentenceText() {
    final languageCode = _settingsProvider?.settings.currentLanguage ?? 'en';
    return _currentSentence
        .map((item) => item.getLabel(languageCode))
        .join(' ');
  }

  Future<void> speakCurrentSentence() async {
    final text = getSentenceText();
    if (text.isNotEmpty) {
      await _ttsService.speak(text);
      
      // Log usage
      if (_currentSentence.isNotEmpty) {
        final languageCode = _settingsProvider?.settings.currentLanguage ?? 'en';
        final log = UsageLog(
          id: _uuid.v4(),
          vocabularyItemId: _currentSentence.first.id,
          timestamp: DateTime.now(),
          languageCode: languageCode,
          sentence: text,
        );
        await _storageService.saveUsageLog(log);
      }
    }
  }

  Future<void> speakText(String text) async {
    await _ttsService.speak(text);
  }
}

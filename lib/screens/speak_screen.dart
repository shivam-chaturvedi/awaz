import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:speech_recognition/speech_recognition.dart';
import '../services/tts_service.dart';
import '../services/translation_service.dart';
import '../providers/settings_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../utils/language_utils.dart';

const _cardBackgroundColor = Color(0xFF1B1B1F);
const _dropdownBackgroundColor = Color(0xFF101010);

class SpeakScreen extends StatefulWidget {
  const SpeakScreen({super.key});

  @override
  State<SpeakScreen> createState() => _SpeakScreenState();
}

class _SpeakScreenState extends State<SpeakScreen> {
  final SpeechRecognition _speechRecognition = SpeechRecognition();
  final TranslationService _translationService = TranslationService();
  final TTSService _ttsService = TTSService();
  final TextEditingController _manualTextController = TextEditingController();

  String _selectedLanguageCode = 'en';
  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isTranslating = false;
  bool _isPlaying = false;
  bool _isTranslatingWholeApp = false;
  String _recognizedText = '';
  String _translatedText = '';
  String _statusMessage = 'Tap the mic to start speaking';

  @override
  void initState() {
    super.initState();
    _configureSpeechRecognition();
    // Initialize selected language from app settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      setState(() {
        _selectedLanguageCode = settingsProvider.settings.currentLanguage;
      });
    });
  }

  Future<void> _configureSpeechRecognition() async {
    _speechRecognition.setAvailabilityHandler((available) {
      if (!mounted) return;
      setState(() {
        _speechAvailable = available;
        _statusMessage = available ? 'Tap the mic to start speaking' : 'Microphone unavailable';
      });
    });

    _speechRecognition.setRecognitionStartedHandler(() {
      if (!mounted) return;
      setState(() {
        _isListening = true;
        _statusMessage = 'Listening...';
      });
    });

    _speechRecognition.setRecognitionResultHandler((text) {
      if (!mounted) return;
      setState(() => _recognizedText = text);
    });

    _speechRecognition.setRecognitionCompleteHandler((status) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _statusMessage = status == 'done' ? 'Tap the mic to start speaking' : status;
      });
    });

    _speechRecognition.setErrorHandler(() {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _statusMessage = 'Something went wrong, try again';
      });
    });

    final available = await _speechRecognition.activate();
    if (!mounted) return;
    setState(() {
      _speechAvailable = available;
      _statusMessage = available ? _statusMessage : 'Microphone unavailable';
    });
  }

  Future<void> _toggleRecording() async {
    if (!_speechAvailable) return;
    if (_isListening) {
      await _speechRecognition.stop();
    } else {
      await _speechRecognition.listen(locale: 'en_US');
    }
  }

  Future<void> _translateText() async => _performTranslation(_recognizedText);

  Future<void> _translateManualText() async {
    final manualText = _manualTextController.text;
    if (manualText.trim().isEmpty) return;
    await _performTranslation(manualText, updateRecognized: true);
  }

  Future<void> _performTranslation(String text, {bool updateRecognized = false}) async {
    final inputText = text.trim();
    if (inputText.isEmpty) return;
    if (updateRecognized && mounted) {
      setState(() => _recognizedText = inputText);
    }

    if (mounted) setState(() => _isTranslating = true);
    try {
      final translatedText = await _translationService.translate(
        text: inputText,
        targetLanguage: _selectedLanguageCode,
        sourceLanguage: 'en',
      );
      if (!mounted) return;
      setState(() => _translatedText = translatedText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Translation failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  Future<void> _playTranslation() async {
    if (_translatedText.trim().isEmpty) return;
    setState(() => _isPlaying = true);
    final previousLanguage = _ttsService.currentLanguage;
    try {
      await _ttsService.setLanguage(_selectedLanguageCode);
      await _ttsService.speak(_translatedText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to play audio: ${e.toString()}')),
        );
      }
    } finally {
      await _ttsService.setLanguage(previousLanguage);
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  void _clearAll() {
    setState(() {
      _recognizedText = '';
      _translatedText = '';
      _manualTextController.clear();
    });
  }

  Widget _buildCard({
    required int step,
    required String title,
    required Widget child,
    Color? accent,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade800),
        color: _cardBackgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: accent ?? Colors.orange.shade100,
                  child: Text(
                    '$step',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.purple.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x80FFFFFF),
            ),
            child: const Icon(Icons.translate_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Voice to Multilingual',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 4),
                Text(
                  'Speak in any language · Hear in another',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualInputCard() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade800),
        color: _cardBackgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.amber.shade300,
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  translate('speak.manual_input_title'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
                TextField(
                  controller: _manualTextController,
                  minLines: 3,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black54,
                    hintText: translate('speak.manual_input_hint'),
                    hintStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTranslating ? null : _translateManualText,
                    icon: _isTranslating
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.swap_horiz_rounded),
                    label: Text(
                      _isTranslating ? 'Converting...' : translate('speak.manual_input_button'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => _manualTextController.clear(),
                  child: Text(translate('speak.manual_input_clear')),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              translate('speak.manual_input_helper'),
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        color: Colors.black,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Speak',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Translate your voice into another language in four simple steps.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 18),
              _buildHeader(),
              const SizedBox(height: 6),
              _buildManualInputCard(),
              _buildCard(
                step: 1,
                title: 'Record Your Voice',
                accent: Colors.redAccent.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isListening
                              ? [Colors.purple.shade500, Colors.purple.shade300]
                              : [Colors.deepPurple.shade500, Colors.deepPurple.shade300],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _toggleRecording,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 14),
                              Text(
                                _isListening ? 'Listening...' : 'Tap to Record',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _speechAvailable ? _statusMessage : 'Microphone unavailable',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              _buildCard(
                step: 2,
                title: 'Your Text',
                accent: Colors.teal.shade100,
                trailing: TextButton(
                  onPressed: _clearAll,
                  child: const Text('Clear'),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: _cardBackgroundColor,
                      ),
                      child: Text(
                        _recognizedText.isNotEmpty ? _recognizedText : 'What you said appears here.',
                        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isTranslating ? null : _translateText,
                      icon: _isTranslating
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.translate_rounded),
                    label: Text(
                      _isTranslating ? 'Translating...' : 'Transcribe & Translate',
                      style: const TextStyle(color: Colors.white),
                    ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade400,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              _buildCard(
                step: 3,
                title: 'Choose Output Language',
                accent: Colors.orange.shade100,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedLanguageCode,
                  dropdownColor: _dropdownBackgroundColor,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: _cardBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade600),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.white,
                  items: LanguageUtils.supportedLanguages
                      .map(
                        (langCode) => DropdownMenuItem(
                          value: langCode,
                          child: Row(
                            children: [
                              Text(LanguageUtils.getLanguageFlag(langCode)),
                              const SizedBox(width: 10),
                              Text(
                                LanguageUtils.getLanguageName(langCode),
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedLanguageCode = value);
                  },
                ),
              ),
              _buildCard(
                step: 4,
                title: 'Play Audio',
                accent: Colors.green.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: _cardBackgroundColor,
                      ),
                      child: Text(
                        _translatedText.isNotEmpty
                            ? _translatedText
                            : 'Translated text will appear here.',
                        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: (_translatedText.trim().isEmpty || _isPlaying) ? null : _playTranslation,
                      icon: _isPlaying
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.play_circle_rounded),
                      label: Text(
                        _isPlaying 
                            ? 'Playing ${LanguageUtils.getLanguageName(_selectedLanguageCode)} audio' 
                            : 'Play ${LanguageUtils.getLanguageName(_selectedLanguageCode)} Audio',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              _buildCard(
                step: 5,
                title: 'Apply to Entire App',
                accent: Colors.blue.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Set ${LanguageUtils.getLanguageName(_selectedLanguageCode)} as the default language for the entire app. This will translate the interface and vocabulary, and change the default text-to-speech language.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isTranslatingWholeApp ? null : () async {
                        setState(() => _isTranslatingWholeApp = true);
                        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
                        final vocabularyProvider = Provider.of<VocabularyProvider>(context, listen: false);
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          // First, set the app locale
                          await changeLocale(context, _selectedLanguageCode);
                          await settingsProvider.setLanguage(_selectedLanguageCode);
                          
                          // Now translate all the vocabulary in the background
                          await vocabularyProvider.translateAllVocabulary(_selectedLanguageCode);
                          
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('App language and vocabulary set to ${LanguageUtils.getLanguageName(_selectedLanguageCode)}'),
                                backgroundColor: Colors.green.shade700,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(content: Text('Failed to set language: ${e.toString()}')),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isTranslatingWholeApp = false);
                          }
                        }
                      },
                      icon: _isTranslatingWholeApp
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.language_rounded),
                      label: Text(
                        _isTranslatingWholeApp ? 'Translating App...' : 'Translate Whole App',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _manualTextController.dispose();
    super.dispose();
  }
}

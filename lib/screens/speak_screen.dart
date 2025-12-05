import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:speech_recognition/speech_recognition.dart';
import '../services/tts_service.dart';

const _cardBackgroundColor = Color(0xFF1B1B1F);
const _dropdownBackgroundColor = Color(0xFF101010);

class SpeakScreen extends StatefulWidget {
  const SpeakScreen({super.key});

  @override
  State<SpeakScreen> createState() => _SpeakScreenState();
}

class SpeakLanguage {
  final String name;
  final String code;
  final String flag;

  const SpeakLanguage({
    required this.name,
    required this.code,
    required this.flag,
  });
}

class _SpeakScreenState extends State<SpeakScreen> {
  final SpeechRecognition _speechRecognition = SpeechRecognition();
  final GoogleTranslator _translator = GoogleTranslator();
  final TTSService _ttsService = TTSService();

  final _languages = const [
    SpeakLanguage(name: 'English', code: 'en', flag: '🇺🇸'),
    SpeakLanguage(name: 'Hindi', code: 'hi', flag: '🇮🇳'),
    SpeakLanguage(name: 'Bengali', code: 'bn', flag: '🇧🇩'),
    SpeakLanguage(name: 'Tamil', code: 'ta', flag: '🇮🇳'),
    SpeakLanguage(name: 'Telugu', code: 'te', flag: '🇮🇳'),
    SpeakLanguage(name: 'Spanish', code: 'es', flag: '🇪🇸'),
  ];

  late SpeakLanguage _selectedLanguage = _languages[2];
  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isTranslating = false;
  bool _isPlaying = false;
  String _recognizedText = '';
  String _translatedText = '';
  String _statusMessage = 'Tap the mic to start speaking';

  @override
  void initState() {
    super.initState();
    _configureSpeechRecognition();
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

  Future<void> _translateText() async {
    if (_recognizedText.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final translation = await _translator.translate(
        _recognizedText,
        to: _selectedLanguage.code,
      );
      if (!mounted) return;
      setState(() => _translatedText = translation.text);
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
      await _ttsService.setLanguage(_selectedLanguage.code);
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
            child: const Icon(Icons.translate, color: Colors.white, size: 28),
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
                                _isListening ? Icons.mic_off : Icons.mic,
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
                          : const Icon(Icons.translate),
                      label: Text(_isTranslating ? 'Translating...' : 'Transcribe & Translate'),
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
                  initialValue: _selectedLanguage.code,
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
                  items: _languages
                      .map(
                        (language) => DropdownMenuItem(
                          value: language.code,
                          child: Row(
                            children: [
                              Text(language.flag),
                              const SizedBox(width: 10),
                              Text(
                                language.name,
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    final selection = _languages.firstWhere(
                      (lang) => lang.code == value,
                      orElse: () => _selectedLanguage,
                    );
                    setState(() => _selectedLanguage = selection);
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
                          : const Icon(Icons.play_circle),
                      label: Text(
                        _isPlaying ? 'Playing ${_selectedLanguage.name} audio' : 'Play ${_selectedLanguage.name} Audio',
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
            ],
          ),
        ),
      ),
    );
  }
}

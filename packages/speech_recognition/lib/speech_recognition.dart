import 'package:speech_to_text/speech_to_text.dart';

typedef SpeechRecognitionResultHandler = void Function(String recognizedText);
typedef SpeechRecognitionStatusHandler = void Function(String status);
typedef SpeechRecognitionAvailabilityHandler = void Function(bool available);
typedef SpeechRecognitionVoidHandler = void Function();

class SpeechRecognition {
  final SpeechToText _speechToText = SpeechToText();
  SpeechRecognitionAvailabilityHandler? _availabilityHandler;
  SpeechRecognitionVoidHandler? _recognitionStartedHandler;
  SpeechRecognitionResultHandler? _resultHandler;
  SpeechRecognitionStatusHandler? _recognitionCompleteHandler;
  SpeechRecognitionVoidHandler? _errorHandler;
  bool _initialized = false;

  bool get isListening => _speechToText.isListening;

  void setAvailabilityHandler(SpeechRecognitionAvailabilityHandler handler) {
    _availabilityHandler = handler;
  }

  void setRecognitionStartedHandler(SpeechRecognitionVoidHandler handler) {
    _recognitionStartedHandler = handler;
  }

  void setRecognitionResultHandler(SpeechRecognitionResultHandler handler) {
    _resultHandler = handler;
  }

  void setRecognitionCompleteHandler(SpeechRecognitionStatusHandler handler) {
    _recognitionCompleteHandler = handler;
  }

  void setErrorHandler(SpeechRecognitionVoidHandler handler) {
    _errorHandler = handler;
  }

  Future<bool> activate() async {
    if (_initialized) {
      return _speechToText.isAvailable;
    }
    _initialized = await _speechToText.initialize(
      onStatus: _onStatus,
      onError: _onError,
    );
    _availabilityHandler?.call(_initialized);
    return _initialized;
  }

  Future<void> listen({String locale = 'en_US'}) async {
    if (!_initialized) await activate();
    if (!_initialized) return;

    await _speechToText.listen(
      onResult: _onResult,
      localeId: locale,
    );
  }

  Future<void> stop() async {
    if (!_initialized) return;
    await _speechToText.stop();
  }

  Future<void> cancel() async {
    if (!_initialized) return;
    await _speechToText.cancel();
  }

  void _onStatus(String status) {
    if (status == 'listening') {
      _recognitionStartedHandler?.call();
    } else if (status == 'done' || status == 'notListening') {
      _recognitionCompleteHandler?.call(status);
    }
  }

  void _onResult(dynamic result) {
    final recognizedWords = result?.recognizedWords ?? '';
    _resultHandler?.call(recognizedWords);
  }

  void _onError(dynamic error) {
    _errorHandler?.call();
    _availabilityHandler?.call(false);
  }
}

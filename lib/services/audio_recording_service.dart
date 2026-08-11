import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Service for recording and playing back custom audio clips for vocabulary tiles.
class AudioRecordingService {
  static final AudioRecordingService _instance = AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;
  AudioRecordingService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;

  /// Start recording audio to a file named [fileName] (without extension).
  /// Returns the full path where the audio will be saved.
  Future<String?> startRecording(String fileName) async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        debugPrint('AudioRecordingService: No recording permission');
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory(p.join(directory.path, 'custom_audio'));
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      final filePath = p.join(audioDir.path, '$fileName.m4a');

      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
      );

      await _recorder.start(config, path: filePath);
      _isRecording = true;
      debugPrint('AudioRecordingService: Recording started → $filePath');
      return filePath;
    } catch (e) {
      debugPrint('AudioRecordingService: startRecording failed: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Stop recording and return the path of the recorded file.
  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      debugPrint('AudioRecordingService: Recording stopped → $path');
      return path;
    } catch (e) {
      debugPrint('AudioRecordingService: stopRecording failed: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Play a recorded audio file from [filePath].
  Future<void> playRecording(String filePath) async {
    try {
      await _player.stop();
      await _player.play(DeviceFileSource(filePath));
      _isPlaying = true;

      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });

      debugPrint('AudioRecordingService: Playing → $filePath');
    } catch (e) {
      debugPrint('AudioRecordingService: playRecording failed: $e');
      _isPlaying = false;
    }
  }

  /// Stop any active playback.
  Future<void> stopPlayback() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('AudioRecordingService: stopPlayback failed: $e');
    }
  }

  /// Delete a recorded audio file.
  Future<void> deleteRecording(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('AudioRecordingService: Deleted → $filePath');
      }
    } catch (e) {
      debugPrint('AudioRecordingService: deleteRecording failed: $e');
    }
  }

  /// Check whether a recorded file exists at [filePath].
  Future<bool> recordingExists(String filePath) async {
    try {
      return await File(filePath).exists();
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}

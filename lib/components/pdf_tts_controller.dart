import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as pdf_core;

class PdfTtsController extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  Timer? _progressTimer;

  bool _isActive = false;
  bool _isPlaying = false;
  double _speechRate = 1.0;

  List<String> _paragraphs = [];
  int _currentParagraphIndex = 0;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  static const double _charsPerSecond = 15.0;

  bool get isActive => _isActive;
  bool get isPlaying => _isPlaying;
  double get speechRate => _speechRate;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  PdfTtsController() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("pt-BR");
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5 * _speechRate);
    } catch (e) {
      debugPrint("TTS Init Error: $e");
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _flutterTts.setQueueMode(1);
      } catch (e) {
        debugPrint("Queue mode ignored: $e");
      }
    }

    // 1. Completion Handler (Advances sequentially when audio actually finishes)
    _flutterTts.setCompletionHandler(() {
      debugPrint("Finished playing paragraph index: $_currentParagraphIndex");

      // If user paused or stopped, ignore this event
      if (!_isPlaying) return;

      if (_currentParagraphIndex < _paragraphs.length - 1) {
        _currentParagraphIndex++;
        notifyListeners();

        // Short buffer pause to allow Web Speech engine to clear audio queue
        Future.delayed(Duration(milliseconds: kIsWeb ? 200 : 50), () {
          if (_isPlaying) {
            _speakCurrentIndex();
          }
        });
      } else {
        _stopProgressTimer();
        _isPlaying = false;
        _currentPosition = _totalDuration;
        notifyListeners();
      }
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint("TTS Engine Error: $msg");
      if (!_isPlaying) return;
      _stopProgressTimer();
      _isPlaying = false;
      notifyListeners();
    });
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPlaying) return;
      if (_currentPosition.inSeconds < _totalDuration.inSeconds) {
        _currentPosition += const Duration(seconds: 1);
        notifyListeners();
      }
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  /// Sanitizes raw PDF text and splits it into browser-safe chunks
  List<String> _extractAndCleanChunks(Uint8List fileData) {
    final pdf_core.PdfDocument document = pdf_core.PdfDocument(
      inputBytes: fileData,
    );
    final String rawText = pdf_core.PdfTextExtractor(document).extractText();
    document.dispose();

    // Remove unprintable control characters and PDF ligatures
    final cleaned = rawText
        .replaceAll(RegExp(r'[\r\n\t]+'), ' ')
        .replaceAll(RegExp(r'[^\p{L}\p{N}\p{P}\p{Z}]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) return [];

    // Split by punctuation marks (. ! ?) to prevent Chrome 200-character speech drops
    final rawChunks = cleaned.split(RegExp(r'(?<=[.!?])\s+'));

    final List<String> result = [];
    for (var chunk in rawChunks) {
      final trimmed = chunk.trim();
      if (trimmed.length > 180) {
        for (int i = 0; i < trimmed.length; i += 180) {
          int end = (i + 180 < trimmed.length) ? i + 180 : trimmed.length;
          result.add(trimmed.substring(i, end).trim());
        }
      } else if (trimmed.length > 2) {
        result.add(trimmed);
      }
    }
    return result;
  }

  Future<void> togglePlayer(Uint8List fileData) async {
    if (_isActive) {
      if (_isPlaying) {
        _isPlaying =
            false; // Set false BEFORE calling stop to block completion trigger
        _stopProgressTimer();
        await _flutterTts.stop();
      } else {
        _isPlaying = true;
        _startProgressTimer();
        _speakCurrentIndex();
      }
      notifyListeners();
      return;
    }

    _isActive = true;
    _isPlaying = true;
    notifyListeners();

    final chunks = _extractAndCleanChunks(fileData);

    if (chunks.isEmpty) {
      _isActive = false;
      _isPlaying = false;
      notifyListeners();
      return;
    }

    final int totalChars = chunks.fold(0, (sum, str) => sum + str.length);

    _paragraphs = chunks;
    _currentParagraphIndex = 0;
    _totalDuration = Duration(
      seconds: (totalChars / (_charsPerSecond * _speechRate)).round(),
    );
    _currentPosition = Duration.zero;

    _startProgressTimer();
    notifyListeners();

    _speakCurrentIndex();
  }

  Future<void> _speakCurrentIndex() async {
    if (!_isPlaying || _currentParagraphIndex >= _paragraphs.length) return;

    final String text = _paragraphs[_currentParagraphIndex];
    debugPrint(
      "Speaking paragraph $_currentParagraphIndex / ${_paragraphs.length}: $text",
    );

    try {
      await _flutterTts.setLanguage("pt-BR");
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.5 * _speechRate);

      // DO NOT call _flutterTts.stop() here. Simply speak the new chunk.
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("TTS Speech Exception: $e");
    }
  }

  void seekTo(Duration targetPosition) async {
    if (_paragraphs.isEmpty) return;

    final int targetSeconds = targetPosition.inSeconds;
    int accumulatedChars = 0;
    int newIndex = 0;

    for (int i = 0; i < _paragraphs.length; i++) {
      final int segmentSecs =
          (_paragraphs[i].length / (_charsPerSecond * _speechRate)).round();
      final int currentSecs =
          (accumulatedChars / (_charsPerSecond * _speechRate)).round();

      if (currentSecs + segmentSecs >= targetSeconds) {
        newIndex = i;
        break;
      }
      accumulatedChars += _paragraphs[i].length;
    }

    _isPlaying = false;
    await _flutterTts.stop();

    _currentParagraphIndex = newIndex;
    _currentPosition = targetPosition;
    _isPlaying = true;

    _startProgressTimer();
    notifyListeners();
    _speakCurrentIndex();
  }

  void skipBy(int seconds) {
    final int newSecs = (_currentPosition.inSeconds + seconds).clamp(
      0,
      _totalDuration.inSeconds,
    );
    seekTo(Duration(seconds: newSecs));
  }

  void setSpeed(double newSpeed) async {
    _speechRate = newSpeed;
    final int totalChars = _paragraphs.fold(0, (sum, str) => sum + str.length);
    _totalDuration = Duration(
      seconds: (totalChars / (_charsPerSecond * newSpeed)).round(),
    );

    await _flutterTts.setSpeechRate(0.5 * newSpeed);
    notifyListeners();

    if (_isPlaying) {
      _isPlaying = false;
      await _flutterTts.stop();
      _isPlaying = true;
      _speakCurrentIndex();
    }
  }

  void close() async {
    _isPlaying = false;
    _stopProgressTimer();
    await _flutterTts.stop();
    _isActive = false;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    _paragraphs.clear();
    _currentParagraphIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopProgressTimer();
    _flutterTts.stop();
    super.dispose();
  }
}

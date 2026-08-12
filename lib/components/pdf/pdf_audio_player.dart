import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as pdf_core;

enum TtsState { playing, paused, stopped }

class WordInfo {
  final String word;
  final int start;
  final int end;

  WordInfo({required this.word, required this.start, required this.end});
}

class PdfAudioPlayer extends StatefulWidget {
  final double containerHeight;
  final Uint8List fileData;

  const PdfAudioPlayer({
    super.key,
    required this.fileData,
    this.containerHeight = 180.0,
  });

  @override
  State<PdfAudioPlayer> createState() => _PdfAudioPlayerState();
}

class _PdfAudioPlayerState extends State<PdfAudioPlayer> {
  final FlutterTts _flutterTts = FlutterTts();

  String _audioContent = '';
  bool _isExtractingText = true;

  TtsState _ttsState = TtsState.stopped;

  double _progress = 0.0;
  double _selectedSpeed = 1.0;

  List<WordInfo> _words = [];
  int _currentWordIndex = 0;
  int _speechStartOffset = 0;

  @override
  void initState() {
    super.initState();

    _initTts();
    _extractPdfText();
  }

  Future<void> _extractPdfText() async {
    pdf_core.PdfDocument? document;

    try {
      document = pdf_core.PdfDocument(inputBytes: widget.fileData);

      final extractor = pdf_core.PdfTextExtractor(document);
      final StringBuffer textBuffer = StringBuffer();

      for (int i = 0; i < document.pages.count; i++) {
        final pageText = extractor.extractText(
          startPageIndex: i,
          endPageIndex: i,
        );

        if (pageText.trim().isNotEmpty) {
          textBuffer.write(pageText);
          textBuffer.write(' ');
        }
      }

      final extractedText = _normalizeTextForSpeech(textBuffer.toString());

      if (!mounted) return;

      setState(() {
        _audioContent = extractedText;
        _isExtractingText = false;

        if (_audioContent.isNotEmpty) {
          _words = _parseWords(_audioContent);
        }
      });
    } catch (e, stackTrace) {
      debugPrint('PDF text extraction failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _audioContent = '';
        _words = [];
        _isExtractingText = false;
      });
    } finally {
      document?.dispose();
    }
  }

  String _normalizeTextForSpeech(String text) {
    var result = text;

    // Convert newlines, tabs, multiple spaces, etc. into one space.
    result = result.replaceAll(RegExp(r'\s+'), ' ');
    // Remove spaces before punctuation.
    result = result.replaceAll(RegExp(r'\s+([,.!?;:])'), r'$1');
    // Remove spaces immediately after opening brackets.
    result = result.replaceAll(RegExp(r'([(\[]) +'), r'$1');
    // Remove spaces immediately before closing brackets.
    result = result.replaceAll(RegExp(r' +([)\]])'), r'$1');

    return result.trim();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('pt-BR');
    await _flutterTts.setPitch(1.0);

    await _applyPlatformSpeechRate();

    _flutterTts.setCompletionHandler(() {
      if (!mounted) return;

      setState(() {
        _ttsState = TtsState.stopped;
        _progress = 1.0;
        _currentWordIndex = 0;
        _speechStartOffset = 0;
      });
    });

    _flutterTts.setErrorHandler((msg) {
      final errorStr = msg.toString().toLowerCase();

      if (errorStr.contains('interrupted') ||
          errorStr.contains('canceled') ||
          errorStr.contains('cancelled') ||
          errorStr.contains('speechsynthesiserrorevent') ||
          _ttsState == TtsState.paused ||
          _ttsState == TtsState.stopped) {
        return;
      }

      debugPrint('TTS error: $msg');

      if (!mounted) return;

      setState(() {
        _ttsState = TtsState.stopped;
      });
    });

    _flutterTts.setProgressHandler((
      String text,
      int start,
      int end,
      String word,
    ) {
      if (!mounted || _audioContent.isEmpty) return;

      final absoluteStart = _speechStartOffset + start;
      final absoluteEnd = _speechStartOffset + end;

      int wordIndex = -1;

      for (int i = 0; i < _words.length; i++) {
        final currentWord = _words[i];

        if (absoluteStart >= currentWord.start &&
            absoluteStart <= currentWord.end) {
          wordIndex = i;
          break;
        }
      }

      if (wordIndex == -1) {
        wordIndex = _words.indexWhere((item) => item.start >= absoluteStart);

        if (wordIndex == -1 && _words.isNotEmpty) {
          wordIndex = _words.length - 1;
        }
      }

      final clampedEnd = absoluteEnd.clamp(0, _audioContent.length);

      final newProgress = (clampedEnd / _audioContent.length).clamp(0.0, 1.0);

      setState(() {
        if (wordIndex >= 0) {
          _currentWordIndex = wordIndex;
        }

        _progress = newProgress;
      });
    });

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        await _flutterTts.setSharedInstance(true);

        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
          IosTextToSpeechAudioMode.defaultMode,
        );
      } catch (e) {
        debugPrint('iOS Audio Configuration error: $e');
      }
    }
  }

  double _getEngineRate(double speedMultiplier) {
    if (kIsWeb) {
      switch (speedMultiplier) {
        case 0.5:
          return 0.75;
        case 1.0:
          return 1.0;
        case 1.5:
          return 1.22;
        case 2.0:
          return 1.45;
        default:
          return 1.0;
      }
    }

    switch (speedMultiplier) {
      case 0.5:
        return 0.35;
      case 1.0:
        return 0.50;
      case 1.5:
        return 0.62;
      case 2.0:
        return 0.75;
      default:
        return 0.50;
    }
  }

  Future<void> _applyPlatformSpeechRate() async {
    final engineRate = _getEngineRate(_selectedSpeed);

    await _flutterTts.setSpeechRate(engineRate);
  }

  Future<void> _setSpeechRate(double speed) async {
    if (_selectedSpeed == speed) return;

    final wasPlaying = _ttsState == TtsState.playing;
    int resumeOffset = 0;

    if (_words.isNotEmpty &&
        _currentWordIndex >= 0 &&
        _currentWordIndex < _words.length) {
      resumeOffset = _words[_currentWordIndex].start;
    }

    setState(() {
      _selectedSpeed = speed;
    });

    await _applyPlatformSpeechRate();

    if (!wasPlaying || _audioContent.isEmpty) {
      return;
    }

    await _flutterTts.stop();

    if (!mounted) return;

    _speechStartOffset = resumeOffset;

    final remainingText = _audioContent.substring(
      resumeOffset.clamp(0, _audioContent.length),
    );

    if (remainingText.trim().isEmpty) {
      return;
    }

    setState(() {
      _ttsState = TtsState.playing;
    });

    await _flutterTts.speak(remainingText);
  }

  List<WordInfo> _parseWords(String text) {
    final List<WordInfo> list = [];

    final matches = RegExp(r'\S+').allMatches(text);

    for (final match in matches) {
      final word = match.group(0)!;

      list.add(WordInfo(word: word, start: match.start, end: match.end));
    }

    return list;
  }

  Future<void> _playOrPause() async {
    if (_isExtractingText || _audioContent.isEmpty) {
      return;
    }

    if (_ttsState == TtsState.playing) {
      await _flutterTts.stop();

      if (!mounted) return;

      setState(() {
        _ttsState = TtsState.paused;
      });

      return;
    }

    if (_words.isEmpty) {
      _words = _parseWords(_audioContent);
    }

    if (_ttsState == TtsState.paused) {
      int resumeOffset = 0;

      if (_currentWordIndex >= 0 && _currentWordIndex < _words.length) {
        resumeOffset = _words[_currentWordIndex].start;
      }

      _speechStartOffset = resumeOffset;

      final remainingText = _audioContent.substring(
        resumeOffset.clamp(0, _audioContent.length),
      );

      if (remainingText.trim().isEmpty) {
        return;
      }

      setState(() {
        _ttsState = TtsState.playing;
      });

      await _flutterTts.speak(remainingText);

      return;
    }

    _currentWordIndex = 0;
    _speechStartOffset = 0;
    _progress = 0.0;

    setState(() {
      _ttsState = TtsState.playing;
    });

    await _flutterTts.speak(_audioContent);
  }

  Future<void> _stopSpeech() async {
    await _flutterTts.stop();

    if (!mounted) return;

    setState(() {
      _ttsState = TtsState.stopped;
      _progress = 0.0;
      _currentWordIndex = 0;
      _speechStartOffset = 0;
    });
  }

  Future<void> _seekToFraction(double fraction, String fullText) async {
    if (fullText.isEmpty) return;

    if (_words.isEmpty) {
      _words = _parseWords(fullText);
    }

    if (_words.isEmpty) return;

    final clampedFraction = fraction.clamp(0.0, 1.0);

    final targetChar = (clampedFraction * fullText.length).round();

    int targetIndex = _words.indexWhere((word) => word.end >= targetChar);

    if (targetIndex == -1) {
      targetIndex = _words.length - 1;
    }

    final targetWord = _words[targetIndex];
    final targetOffset = targetWord.start;

    final wasPlaying = _ttsState == TtsState.playing;

    if (wasPlaying) {
      await _flutterTts.stop();
    }

    if (!mounted) return;

    setState(() {
      _currentWordIndex = targetIndex;
      _progress = (targetWord.end / fullText.length).clamp(0.0, 1.0);

      _speechStartOffset = targetOffset;
    });

    if (!wasPlaying) {
      return;
    }

    final remainingText = fullText.substring(targetOffset);

    if (remainingText.trim().isEmpty) {
      return;
    }

    setState(() {
      _ttsState = TtsState.playing;
    });

    await _flutterTts.speak(remainingText);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPlay = !_isExtractingText && _audioContent.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                if (_isExtractingText)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Extracting PDF text...',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                if (!_isExtractingText && _audioContent.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No readable text was found in this PDF.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6.0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14.0,
                    ),
                    activeTrackColor: Theme.of(context).primaryColor,
                    inactiveTrackColor: Colors.grey.shade200,
                    thumbColor: Theme.of(context).primaryColor,
                  ),
                  child: Slider(
                    value: _progress.clamp(0.0, 1.0),
                    onChanged: canPlay
                        ? (value) => _seekToFraction(value, _audioContent)
                        : null,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _ttsState == TtsState.playing
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            size: 36,
                          ),
                          color: Theme.of(context).primaryColor,
                          onPressed: canPlay ? _playOrPause : null,
                        ),

                        IconButton(
                          icon: const Icon(Icons.stop_circle, size: 32),
                          color: Colors.redAccent,
                          onPressed: _ttsState == TtsState.stopped
                              ? null
                              : _stopSpeech,
                        ),
                      ],
                    ),
                    PopupMenuButton<double>(
                      initialValue: _selectedSpeed,
                      tooltip: 'Playback Speed',
                      onSelected: _setSpeechRate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Text(
                          '${_selectedSpeed == _selectedSpeed.toInt() ? _selectedSpeed.toInt() : _selectedSpeed}x',
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      itemBuilder: (BuildContext context) =>
                          const <PopupMenuEntry<double>>[
                            PopupMenuItem<double>(
                              value: 0.5,
                              child: Text('0.5x Speed'),
                            ),
                            PopupMenuItem<double>(
                              value: 1.0,
                              child: Text('1.0x Speed (Normal)'),
                            ),
                            PopupMenuItem<double>(
                              value: 1.5,
                              child: Text('1.5x Speed'),
                            ),
                            PopupMenuItem<double>(
                              value: 2.0,
                              child: Text('2.0x Speed'),
                            ),
                          ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

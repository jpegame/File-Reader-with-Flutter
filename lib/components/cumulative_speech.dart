import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, paused, stopped }

class WordInfo {
  final String word;
  final int start;
  final int end;
  final int durationMs;

  WordInfo({
    required this.word,
    required this.start,
    required this.end,
    required this.durationMs,
  });
}

class CumulativeSpeechWidget extends StatefulWidget {
  final double containerHeight;

  const CumulativeSpeechWidget({
    Key? key,
    this.containerHeight = 180.0,
  }) : super(key: key);

  @override
  State<CumulativeSpeechWidget> createState() => _CumulativeSpeechWidgetState();
}

class _CumulativeSpeechWidgetState extends State<CumulativeSpeechWidget> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final List<String> _sentences = [];

  TtsState _ttsState = TtsState.stopped;
  double _progress = 0.0;
  double _selectedSpeed = 1.0;

  List<WordInfo> _words = [];
  int _currentWordIndex = 0;
  int _currentStart = 0;
  int _currentEnd = 0;

  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);

    await _applyPlatformSpeechRate();

    _flutterTts.setCompletionHandler(() {
      _stopTimer();
      if (mounted) {
        setState(() {
          _ttsState = TtsState.stopped;
          _progress = 1.0;
          _currentWordIndex = 0;
          _currentStart = 0;
          _currentEnd = 0;
        });
      }
    });

    _flutterTts.setErrorHandler((msg) {
      final errorStr = msg.toString().toLowerCase();

      if (errorStr.contains('interrupted') ||
          errorStr.contains('canceled') ||
          errorStr.contains('speechsynthesiserrorevent') ||
          _ttsState == TtsState.paused ||
          _ttsState == TtsState.stopped) {
        return;
      }

      _stopTimer();
      if (mounted) {
        setState(() => _ttsState = TtsState.stopped);
      }
    });

    _flutterTts.setProgressHandler((String text, int? start, int? end, String word) {
      if (!mounted || start == null || end == null) return;

      final matchIndex = _words.indexWhere((w) => w.start >= start);
      if (matchIndex != -1) {
        _currentWordIndex = matchIndex;
      }
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
        debugPrint("iOS Audio Configuration error: $e");
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
    } else {
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
  }

  Future<void> _applyPlatformSpeechRate() async {
    final engineRate = _getEngineRate(_selectedSpeed);
    await _flutterTts.setSpeechRate(engineRate);
  }

  Future<void> _setSpeechRate(double speed) async {
    if (_selectedSpeed == speed) return;

    setState(() {
      _selectedSpeed = speed;
    });

    await _applyPlatformSpeechRate();

    final fullParagraph = _sentences.join(' ');
    if (fullParagraph.isNotEmpty) {
      _words = _parseWords(fullParagraph);

      if (_ttsState == TtsState.playing) {
        _stopTimer();
        await _flutterTts.stop();

        final resumeCharIndex = (_currentWordIndex < _words.length)
            ? _words[_currentWordIndex].start
            : 0;

        final remainingText = fullParagraph.substring(resumeCharIndex);

        _startTimer(fullParagraph);
        await _flutterTts.speak(remainingText.isNotEmpty ? remainingText : fullParagraph);
      }
    }
  }

  List<WordInfo> _parseWords(String text) {
    final List<WordInfo> list = [];
    final regExp = RegExp(r'\S+');
    final matches = regExp.allMatches(text);

    for (final match in matches) {
      final wordStr = match.group(0)!;

      int duration = 110 + (wordStr.length * 16);
      if (wordStr.contains('.') ||
          wordStr.contains('!') ||
          wordStr.contains('?')) {
        duration += 650;
      } else if (wordStr.contains(',') ||
          wordStr.contains(';') ||
          wordStr.contains(':')) {
        duration += 180;
      }

      final scaledDuration = (duration / _selectedSpeed).round();

      list.add(
        WordInfo(
          word: wordStr,
          start: match.start,
          end: match.end,
          durationMs: scaledDuration,
        ),
      );
    }
    return list;
  }

  void _startTimer(String fullText) {
    _stopTimer();
    if (_words.isEmpty) return;

    _playbackTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_ttsState != TtsState.playing || !mounted) {
        timer.cancel();
        return;
      }

      if (_currentWordIndex < _words.length) {
        final currentWord = _words[_currentWordIndex];

        setState(() {
          _currentStart = currentWord.start;
          _currentEnd = currentWord.end;
          _progress = (currentWord.end / fullText.length).clamp(0.0, 1.0);
        });

        _playbackTimer?.cancel();
        _playbackTimer = Timer(Duration(milliseconds: currentWord.durationMs), () {
          _currentWordIndex++;
          if (_currentWordIndex < _words.length && _ttsState == TtsState.playing) {
            _startTimer(fullText);
          }
        });
      }
    });
  }

  void _stopTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  Future<void> _seekToFraction(double fraction, String fullParagraph) async {
    if (fullParagraph.isEmpty) return;

    if (_words.isEmpty) {
      _words = _parseWords(fullParagraph);
    }
    if (_words.isEmpty) return;

    final clampedFraction = fraction.clamp(0.0, 1.0);
    final targetChar = (clampedFraction * fullParagraph.length).round();

    int targetIndex = _words.indexWhere((w) => w.end >= targetChar);
    if (targetIndex == -1) {
      targetIndex = _words.length - 1;
    }

    final targetWord = _words[targetIndex];

    setState(() {
      _currentWordIndex = targetIndex;
      _currentStart = targetWord.start;
      _currentEnd = targetWord.end;
      _progress = (targetWord.end / fullParagraph.length).clamp(0.0, 1.0);
    });

    if (_ttsState == TtsState.playing) {
      _stopTimer();
      await _flutterTts.stop();
      final remainingText = fullParagraph.substring(targetWord.start);
      _startTimer(fullParagraph);
      await _flutterTts.speak(remainingText);
    }
  }

  Future<void> _playOrPause() async {
    final fullParagraph = _sentences.join(' ');
    if (fullParagraph.isEmpty) return;

    if (_ttsState == TtsState.playing) {
      await _flutterTts.stop();
      _stopTimer();
      setState(() => _ttsState = TtsState.paused);
    } else if (_ttsState == TtsState.paused) {
      if (_words.isEmpty) {
        _words = _parseWords(fullParagraph);
      }

      final resumeCharIndex = (_currentWordIndex < _words.length)
          ? _words[_currentWordIndex].start
          : 0;

      final remainingText = fullParagraph.substring(resumeCharIndex);

      setState(() => _ttsState = TtsState.playing);
      _startTimer(fullParagraph);
      await _flutterTts.speak(remainingText.isNotEmpty ? remainingText : fullParagraph);
    } else {
      _words = _parseWords(fullParagraph);
      _currentWordIndex = 0;
      _progress = 0.0;

      setState(() => _ttsState = TtsState.playing);
      _startTimer(fullParagraph);
      await _flutterTts.speak(fullParagraph);
    }
  }

  Future<void> _stopSpeech() async {
    await _flutterTts.stop();
    _stopTimer();
    if (mounted) {
      setState(() {
        _ttsState = TtsState.stopped;
        _progress = 0.0;
        _currentWordIndex = 0;
        _currentStart = 0;
        _currentEnd = 0;
      });
    }
  }

  Future<void> _handleConfirm() async {
    final newText = _controller.text.trim();
    FocusScope.of(context).unfocus();

    if (newText.isNotEmpty) {
      setState(() {
        _sentences.add(newText);
        _controller.clear();
      });

      final fullParagraph = _sentences.join(' ');
      _words = _parseWords(fullParagraph);

      await _flutterTts.stop();
      _stopTimer();

      final newSentenceIndex = fullParagraph.lastIndexOf(newText);
      final wordIndex = _words.indexWhere((w) => w.start >= newSentenceIndex);

      _currentWordIndex = wordIndex != -1 ? wordIndex : 0;
      _progress = (_currentWordIndex / _words.length).clamp(0.0, 1.0);

      setState(() => _ttsState = TtsState.playing);
      _startTimer(fullParagraph);
      await _flutterTts.speak(newText);
    } else if (_sentences.isNotEmpty) {
      await _playOrPause();
    }
  }

  void _clearAllSentences() {
    _stopSpeech();
    setState(() {
      _sentences.clear();
      _words.clear();
    });
  }

  @override
  void dispose() {
    _stopTimer();
    _controller.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Widget _buildHighlightedText(String text) {
    final start = _currentStart;
    final end = _currentEnd;

    final isInvalidState = _ttsState == TtsState.stopped ||
        text.isEmpty ||
        start < 0 ||
        end < 0 ||
        start >= text.length ||
        end > text.length ||
        start >= end;

    if (isInvalidState) {
      return Text(
        text,
        style: const TextStyle(fontSize: 18.0, height: 1.5, color: Colors.black87),
      );
    }

    try {
      final before = text.substring(0, start);
      final highlighted = text.substring(start, end);
      final after = text.substring(end);

      return RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 18.0, height: 1.5, color: Colors.black87),
          children: [
            TextSpan(text: before),
            TextSpan(
              text: highlighted,
              style: TextStyle(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            TextSpan(text: after),
          ],
        ),
      );
    } catch (_) {
      return Text(
        text,
        style: const TextStyle(fontSize: 18.0, height: 1.5, color: Colors.black87),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullParagraph = _sentences.join(' ');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: widget.containerHeight,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SingleChildScrollView(
              child: _sentences.isEmpty
                  ? const Text(
                      'Your cumulative text will build up here...',
                      style: TextStyle(color: Colors.grey),
                    )
                  : _buildHighlightedText(fullParagraph),
            ),
          ),
        ),
        const SizedBox(height: 12.0),

        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                    activeTrackColor: Theme.of(context).primaryColor,
                    inactiveTrackColor: Colors.grey.shade200,
                    thumbColor: Theme.of(context).primaryColor,
                  ),
                  child: Slider(
                    value: _progress.clamp(0.0, 1.0),
                    onChanged: fullParagraph.isEmpty
                        ? null
                        : (val) => _seekToFraction(val, fullParagraph),
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
                          onPressed: fullParagraph.isEmpty ? null : _playOrPause,
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop_circle, size: 32),
                          color: Colors.redAccent,
                          onPressed: _ttsState == TtsState.stopped ? null : _stopSpeech,
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
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<double>>[
                        const PopupMenuItem<double>(value: 0.5, child: Text('0.5x Speed')),
                        const PopupMenuItem<double>(value: 1.0, child: Text('1.0x Speed (Normal)')),
                        const PopupMenuItem<double>(value: 1.5, child: Text('1.5x Speed')),
                        const PopupMenuItem<double>(value: 2.0, child: Text('2.0x Speed')),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 22),
                      color: Colors.grey.shade600,
                      tooltip: 'Clear All',
                      onPressed: _sentences.isEmpty ? null : _clearAllSentences,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  hintText: 'Type a sentence...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                ),
                onSubmitted: (_) => _handleConfirm(),
              ),
            ),
            const SizedBox(width: 8.0),
            ElevatedButton.icon(
              onPressed: _handleConfirm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }
}
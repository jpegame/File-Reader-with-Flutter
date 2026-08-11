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

  const CumulativeSpeechWidget({Key? key, this.containerHeight = 180.0})
    : super(key: key);

  @override
  State<CumulativeSpeechWidget> createState() => _CumulativeSpeechWidgetState();
}

class _CumulativeSpeechWidgetState extends State<CumulativeSpeechWidget> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final List<String> _sentences = [];

  TtsState _ttsState = TtsState.stopped;
  double _progress = 0.0;

  // Word-tracking State
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

    // Normalize speech rate across platforms
    if (kIsWeb) {
      await _flutterTts.setSpeechRate(1.0);
    } else {
      await _flutterTts.setSpeechRate(0.5);
    }

    // Completion Callback
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

    // Error Handler (ignores benign Web interrupt logs on stop/pause)
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

    // Native Progress Handler Sync
    _flutterTts.setProgressHandler((
      String text,
      int? start,
      int? end,
      String word,
    ) {
      if (!mounted || start == null || end == null) return;

      final matchIndex = _words.indexWhere((w) => w.start >= start);
      if (matchIndex != -1) {
        _currentWordIndex = matchIndex;
      }
    });

    // iOS Audio Category Setup
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

  // Your Fine-Tuned Word Parser
  List<WordInfo> _parseWords(String text) {
    final List<WordInfo> list = [];
    final regExp = RegExp(r'\S+');
    final matches = regExp.allMatches(text);

    for (final match in matches) {
      final wordStr = match.group(0)!;
      // Base word duration + extra delay for punctuation pauses
      int duration = 110 + (wordStr.length * 16);
      if (wordStr.contains('.') ||
          wordStr.contains('!') ||
          wordStr.contains('?')) {
        duration += 750; // Pause at end of sentence
      } else if (wordStr.contains(',') ||
          wordStr.contains(';') ||
          wordStr.contains(':')) {
        duration += 180; // Pause at comma/clause
      }

      list.add(
        WordInfo(
          word: wordStr,
          start: match.start,
          end: match.end,
          durationMs: duration,
        ),
      );
    }
    return list;
  }

  // Playback Timer Engine
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
        _playbackTimer = Timer(
          Duration(milliseconds: currentWord.durationMs),
          () {
            _currentWordIndex++;
            if (_currentWordIndex < _words.length &&
                _ttsState == TtsState.playing) {
              _startTimer(fullText);
            }
          },
        );
      }
    });
  }

  void _stopTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  // Jump/Seek directly to a fraction [0.0 - 1.0] along the progress bar
  Future<void> _seekToFraction(double fraction, String fullParagraph) async {
    if (fullParagraph.isEmpty) return;

    if (_words.isEmpty) {
      _words = _parseWords(fullParagraph);
    }
    if (_words.isEmpty) return;

    final clampedFraction = fraction.clamp(0.0, 1.0);
    final targetChar = (clampedFraction * fullParagraph.length).round();

    // Locate the word corresponding to target position
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

    // If currently playing, jump speech directly to the seeked location
    if (_ttsState == TtsState.playing) {
      _stopTimer();
      await _flutterTts.stop();
      final remainingText = fullParagraph.substring(targetWord.start);
      _startTimer(fullParagraph);
      await _flutterTts.speak(remainingText);
    }
  }

  // Play / Pause / Resume
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
      await _flutterTts.speak(
        remainingText.isNotEmpty ? remainingText : fullParagraph,
      );
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

    final isInvalidState =
        _ttsState == TtsState.stopped ||
        text.isEmpty ||
        start < 0 ||
        end < 0 ||
        start >= text.length ||
        end > text.length ||
        start >= end;

    if (isInvalidState) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 18.0,
          height: 1.5,
          color: Colors.black87,
        ),
      );
    }

    try {
      final before = text.substring(0, start);
      final highlighted = text.substring(start, end);
      final after = text.substring(end);

      return RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 18.0,
            height: 1.5,
            color: Colors.black87,
          ),
          children: [
            TextSpan(text: before),
            TextSpan(
              text: highlighted,
              style: TextStyle(
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.3),
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
        style: const TextStyle(
          fontSize: 18.0,
          height: 1.5,
          color: Colors.black87,
        ),
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
        // 1. Text View
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

        // 2. Audio Player Bar
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
                // Interactive Seekable Progress Slider
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
                          onPressed: fullParagraph.isEmpty
                              ? null
                              : _playOrPause,
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

        // 3. Input Row
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

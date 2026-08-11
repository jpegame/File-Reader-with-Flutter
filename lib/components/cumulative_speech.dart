import 'package:flutter/foundation.dart'; // Required for kIsWeb & defaultTargetPlatform
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("pt-BR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    // iOS-Only Category Configuration
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

  // Safely trigger speech playback
  Future<void> _speakText(String text) async {
    if (text.isEmpty) return;
    // Stop any stuck audio streams before initiating new speech
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> _handleConfirm() async {
    final newText = _controller.text.trim();
    FocusScope.of(context).unfocus();

    // Case 1: User typed new text into the input field
    if (newText.isNotEmpty) {
      setState(() {
        _sentences.add(newText);
        _controller.clear();
      });
      await _speakText(newText);
    }
    // Case 2: Input field is empty, but user tapped "Speak" to hear cumulative text
    else if (_sentences.isNotEmpty) {
      final fullParagraph = _sentences.join(' ');
      await _speakText(fullParagraph);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _flutterTts.stop();
    super.dispose();
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
                  : Text(
                      fullParagraph,
                      style: const TextStyle(fontSize: 18.0, height: 1.5),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16.0),

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
              icon: const Icon(Icons.volume_up),
              label: const Text('Speak'),
            ),
          ],
        ),
      ],
    );
  }
}

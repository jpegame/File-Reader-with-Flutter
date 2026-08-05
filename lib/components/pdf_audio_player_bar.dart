import 'package:flutter/material.dart';
import 'pdf_tts_controller.dart';
import 'dart:typed_data';

class PdfAudioPlayerBar extends StatelessWidget {
  final PdfTtsController ttsController;
  final Uint8List fileData;

  const PdfAudioPlayerBar({
    super.key,
    required this.ttsController,
    required this.fileData,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final double maxSecs = ttsController.totalDuration.inSeconds > 0
        ? ttsController.totalDuration.inSeconds.toDouble()
        : 1.0;
    final double currentSecs = ttsController.currentPosition.inSeconds
        .toDouble()
        .clamp(0.0, maxSecs);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(_formatDuration(ttsController.currentPosition),
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    trackHeight: 3,
                    activeTrackColor: Colors.redAccent,
                    thumbColor: Colors.redAccent,
                  ),
                  child: Slider(
                    value: currentSecs,
                    min: 0.0,
                    max: maxSecs,
                    onChanged: (val) => ttsController.seekTo(Duration(seconds: val.toInt())),
                  ),
                ),
              ),
              Text(_formatDuration(ttsController.totalDuration),
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PopupMenuButton<double>(
                initialValue: ttsController.speechRate,
                onSelected: ttsController.setSpeed,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${ttsController.speechRate}x",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                itemBuilder: (_) => [0.75, 1.0, 1.25, 1.5, 2.0]
                    .map((s) => PopupMenuItem(value: s, child: Text("${s}x")))
                    .toList(),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.white),
                    onPressed: () => ttsController.skipBy(-10),
                  ),
                  IconButton(
                    iconSize: 38,
                    icon: Icon(
                      ttsController.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      color: Colors.white,
                    ),
                    onPressed: () => ttsController.togglePlayer(fileData),
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.white),
                    onPressed: () => ttsController.skipBy(10),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                onPressed: ttsController.close,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
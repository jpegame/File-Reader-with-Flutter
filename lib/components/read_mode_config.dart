import 'package:flutter/material.dart';

class ReadModeConfig {
  final double fontSize;
  final double lineSpacing;
  final Color backgroundColor;
  final Color textColor;

  const ReadModeConfig({
    this.fontSize = 16.0,
    this.lineSpacing = 1.15,
    this.backgroundColor = const Color.fromARGB(255, 241, 241, 241),
    this.textColor = const Color.fromARGB(255, 0, 0, 0),
  });

  ReadModeConfig copyWith({
    double? fontSize,
    double? lineSpacing,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return ReadModeConfig(
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
    );
  }
}
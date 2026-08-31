import 'package:flutter/material.dart';

class ReadModeConfig {
  final double fontSize;
  final double lineSpacing;
  final Color backgroundColor;
  final Color textColor;

  const ReadModeConfig({
    this.fontSize = 16.0,
    this.lineSpacing = 1.15,
    this.backgroundColor = const Color(0xFFF1F1F1),
    this.textColor = Colors.black87,
  });

  factory ReadModeConfig.fromContext(
    BuildContext context, {
    double fontSize = 16.0,
    double lineSpacing = 1.15,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ReadModeConfig(
      fontSize: fontSize,
      lineSpacing: lineSpacing,
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF1F1F1),
      textColor: isDark ? Colors.white70 : Colors.black87,
    );
  }

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
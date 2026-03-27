import 'package:flutter/material.dart';

class ConfigPage extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const ConfigPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Row(
        spacing: 12,
        children: [
          const Text(
            "Modo escuro",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Switch(value: isDarkMode, onChanged: onThemeChanged),
        ],
      ),
    );
  }
}

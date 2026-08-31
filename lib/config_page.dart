import 'package:flutter/material.dart';
import '../database/app_database.dart';

class ConfigPage extends StatelessWidget {
  final AppDatabase db;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const ConfigPage({
    super.key,
    required this.db,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Modo escuro",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: isDarkMode,
                onChanged: (value) async {
                  await db.configDao.upsertConfig(
                    'dark_mode',
                    value.toString(),
                  );
                  onThemeChanged(value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

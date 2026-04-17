import 'package:flutter/material.dart';
import '../database/app_database.dart'; // Adjust path to your db file

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
    return Scaffold(
      appBar: AppBar(title: const Text("Configurações")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Theme Setting Row
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
                    // 1. Update the database via the DAO
                    await db.configDao.upsertConfig('dark_mode', value.toString());
                    
                    // 2. Notify the app to change the UI theme
                    onThemeChanged(value);
                  },
                ),
              ],
            ),
            
            const Divider(height: 40),

            // Example: Display current DB path or status
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text("Banco de dados SQLite"),
              subtitle: const Text("Status: Conectado"),
              trailing: IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.red),
                onPressed: () => _confirmDelete(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Limpar dados?"),
        content: const Text("Isso apagará todas as categorias, documentos e anotações."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              // Drift clean up (requires custom query or deleting all tables)
              // For a simple test, we can just delete the categories 
              // which cascades to documents because of your foreign keys
              final categories = await db.categoryDao.watchCategories().first;
              for (var cat in categories) {
                await db.categoryDao.deleteCategory(cat.id);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Apagar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
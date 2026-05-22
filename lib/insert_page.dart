import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../database/app_database.dart';

class InsertPage extends StatefulWidget {
  final AppDatabase db;
  final VoidCallback onSave;
  const InsertPage({super.key, required this.db, required this.onSave});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _newCatController = TextEditingController();

  PlatformFile? _pickedFile;
  Uint8List? _fileBytes;

  List<CategoryData> _categories = <CategoryData>[];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await widget.db.categoryDao.watchCategories().first;
    if (mounted) {
      setState(() => _categories = cats);
    }
  }

  String cleanFileName(String fileName) {
    if (fileName.isEmpty) return '';

    int lastDotIndex = fileName.lastIndexOf('.');
    String nameWithoutExtension = (lastDotIndex != -1)
        ? fileName.substring(0, lastDotIndex)
        : fileName;

    String cleaned = nameWithoutExtension
        .replaceAllMapped(
          RegExp(r'(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])'),
          (Match m) => ' ',
        )
        .replaceAll(RegExp(r'[-_]'), ' ');

    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _pickedFile = result.files.first;
        _fileBytes = _pickedFile!.bytes;
        if (_nameController.text.isEmpty) {
          _nameController.text = cleanFileName(_pickedFile!.name);
        }
      });
    }
  }

  Future<void> _saveDocument() async {
    if (_pickedFile == null || _selectedCategoryId == null) return;

    await widget.db.documentDao.insertDocument(
      name: _nameController.text,
      categoryId: _selectedCategoryId!,
      fileData: kIsWeb ? _pickedFile!.bytes : null,
      filePath: kIsWeb ? null : _pickedFile!.path,
    );

    widget.onSave();
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nova Categoria"),
        content: TextField(
          controller: _newCatController,
          decoration: const InputDecoration(hintText: "Nome da categoria"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              if (_newCatController.text.isNotEmpty) {
                await widget.db.categoryDao.insertCategory(
                  _newCatController.text,
                );
                _newCatController.clear();
                if (context.mounted) Navigator.pop(context);
                await _loadCategories();
              }
            },
            child: const Text("Adicionar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome do Documento',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final cat in _categories)
                      DropdownMenuItem(value: cat.id, child: Text(cat.name)),
                  ],
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                  hint: const Text("Selecione"),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _showAddCategoryDialog,
                icon: const Icon(Icons.add),
              ),
            ],
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.picture_as_pdf),
            label: Text(
              _pickedFile == null ? "Selecionar PDF" : _pickedFile!.name,
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            "Preview (Pág. 1)",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _fileBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SfPdfViewer.memory(
                      _fileBytes!,
                      enableDoubleTapZooming: false,
                      enableTextSelection: false,
                      canShowPaginationDialog: false,
                      canShowScrollHead: false,
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.picture_as_pdf,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
          ),

          const SizedBox(height: 24),
          FilledButton(
            onPressed: (_pickedFile == null || _selectedCategoryId == null)
                ? null
                : _saveDocument,
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

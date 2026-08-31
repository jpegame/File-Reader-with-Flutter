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
  final _formKey = GlobalKey<FormState>();
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

  @override
  void dispose() {
    _nameController.dispose();
    _newCatController.dispose();
    super.dispose();
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
        if (_nameController.text.trim().isEmpty) {
          _nameController.text = cleanFileName(_pickedFile!.name);
        }
      });
    }
  }

  Future<void> _saveDocument() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um arquivo PDF antes de salvar.'),
        ),
      );
      return;
    }

    await widget.db.documentDao.insertDocument(
      name: _nameController.text.trim(),
      categoryId: _selectedCategoryId!,
      fileData: kIsWeb ? _pickedFile!.bytes : null,
      filePath: kIsWeb ? null : _pickedFile!.path,
    );

    widget.onSave();
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Nova Categoria"),
        content: TextField(
          controller: _newCatController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Nome da categoria",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _newCatController.clear();
              Navigator.pop(dialogContext);
            },
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () async {
              final catName = _newCatController.text.trim();
              if (catName.isNotEmpty) {
                await widget.db.categoryDao.insertCategory(catName);
                _newCatController.clear();

                if (mounted) {
                  Navigator.pop(dialogContext);
                  final updatedCats = await widget.db.categoryDao
                      .watchCategories()
                      .first;
                  final createdCat = updatedCats.firstWhere(
                    (c) => c.name.toLowerCase() == catName.toLowerCase(),
                    orElse: () => updatedCats.last,
                  );

                  setState(() {
                    _categories = updatedCats;
                    _selectedCategoryId = createdCat.id;
                  });
                }
              }
            },
            child: const Text("Adicionar"),
          ),
        ],
      ),
    );
  }

  List<String> _getMissingRequirements() {
    List<String> missing = [];
    if (_nameController.text.trim().isEmpty) missing.add("Nome do documento");
    if (_selectedCategoryId == null) missing.add("Categoria");
    if (_pickedFile == null) missing.add("Arquivo PDF");
    return missing;
  }

  @override
  Widget build(BuildContext context) {
    final missingFields = _getMissingRequirements();
    final bool isReadyToSave = missingFields.isEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Documento *',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, informe o nome do documento';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Categoria *',
                      border: const OutlineInputBorder(),
                      helperText: _categories.isEmpty
                          ? "Nenhuma categoria cadastrada"
                          : null,
                      helperStyle: const TextStyle(color: Colors.orange),
                    ),
                    items: [
                      for (final cat in _categories)
                        DropdownMenuItem(value: cat.id, child: Text(cat.name)),
                    ],
                    onChanged: (val) =>
                        setState(() => _selectedCategoryId = val),
                    hint: Text(
                      _categories.isEmpty
                          ? "Cadastre uma categoria ao lado ->"
                          : "Selecione uma categoria",
                    ),
                    validator: (val) {
                      if (val == null) return 'Selecione uma categoria';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: IconButton.filled(
                    tooltip: "Adicionar Nova Categoria",
                    onPressed: _showAddCategoryDialog,
                    icon: const Icon(Icons.add),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: _pickedFile == null ? Colors.orange : Colors.grey,
                ),
              ),
              onPressed: _pickFile,
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(
                _pickedFile == null
                    ? "Selecionar PDF *"
                    : "Arquivo: ${_pickedFile!.name}",
                style: TextStyle(
                  fontWeight: _pickedFile == null
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Preview",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 380,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Nenhum arquivo selecionado",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            if (!isReadyToSave)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 8.0,
                ),
                child: Text(
                  "Pendente: ${missingFields.join(', ')}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            FilledButton(
              onPressed: isReadyToSave ? _saveDocument : null,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show TypedResult;
import 'pdf_view_page.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';

class HomePage extends StatefulWidget {
  final AppDatabase db;
  const HomePage({super.key, required this.db});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _selectedCategoryId;
  Future<List<CategoryData>>? _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    _categoriesFuture = widget.db.select(widget.db.category).get();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesFuture = _categoriesFuture ??= widget.db
        .select(widget.db.category)
        .get();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.75,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: _buildCategoryDropdown(categoriesFuture),
            ),
          ),
        ),

        Expanded(
          child: StreamBuilder<List<TypedResult>>(
            stream: widget.db.documentDao.watchDocumentsWithCategory(
              categoryId: _selectedCategoryId,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text("Erro ao carregar documentos"));
              }

              final results = snapshot.data ?? [];

              if (results.isEmpty) {
                return const Center(
                  child: Text("Nenhum documento encontrado para este filtro."),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final row = results[index];
                  final doc = row.readTable(widget.db.document);
                  final cat = row.readTable(widget.db.category);

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PdfPage(doc: doc, db: widget.db),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16.0),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 120,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 218, 218, 218),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.picture_as_pdf,
                                    size: 45,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        cat.name.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.blue.shade900,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Acessado em: ${DateFormat('dd/MM/yyyy').format(doc.lastAccess.toLocal())}",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () async {
                                bool? confirmDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirmar Exclusão"),
                                      content: Text(
                                        "Tem certeza que deseja excluir o documento '${doc.name}'?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text("Cancelar"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text("Excluir"),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmDelete == true) {
                                  await widget.db.documentDao.deleteDocument(
                                    doc.id,
                                  );

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Documento excluído"),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(Future<List<CategoryData>> future) {
    return FutureBuilder<List<CategoryData>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return DropdownButtonFormField<int?>(
            decoration: InputDecoration(
              labelText: "Filtrar por Categoria",
              border: OutlineInputBorder(),
            ),
            items: [],
            onChanged: null,
          );
        }

        final categories = snapshot.data!;

        return DropdownButtonFormField<int?>(
          value: _selectedCategoryId,
          decoration: InputDecoration(
            labelText: "Filtrar por Categoria",
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text("Todos os Documentos"),
            ),
            ...categories.map((category) {
              return DropdownMenuItem<int?>(
                value: category.id,
                child: Text(category.name),
              );
            }),
          ],
          onChanged: (newValue) {
            setState(() {
              _selectedCategoryId = newValue;
            });
          },
        );
      },
    );
  }
}

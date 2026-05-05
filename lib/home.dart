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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<TypedResult>>(
        stream: widget.db.documentDao.watchDocumentsWithCategory(),
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
              child: Text("Nenhum documento encontrado. Importe um PDF!"),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
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
                      builder: (context) => PdfPage(doc: doc, db: widget.db),
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
                  child: Column(
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
                            size: 50,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
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
                                  fontSize: 10,
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Acessado em: ${DateFormat('dd/MM/yyyy HH:mm').format(doc.lastAccess.toLocal())}",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
    );
  }
}

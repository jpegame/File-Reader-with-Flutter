import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../database/app_database.dart';
import 'pdf_page_controller.dart';

class PdfPageModals {
  static void showSummaryMenu(
    BuildContext context,
    PdfPageController controller,
  ) {
    // 1. Trigger summary generation BEFORE opening the sheet/during the button press
    if (controller.autoSummaryItems.isEmpty &&
        !controller.isGeneratingSummary) {
      controller.generateAutoSummary();
    }

    // 2. Open the modal bottom sheet
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 16.0,
                right: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sumário Automático (Estrutura)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Principais âncoras de texto identificadas por página:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: controller.isGeneratingSummary
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 12),
                                Text(
                                  "Analisando estrutura do PDF sob demanda...",
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: controller.autoSummaryItems.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = controller.autoSummaryItems[index];
                              final int pageNum = item['pageNumber'];

                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  child: Text(
                                    "$pageNum",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item['heading'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  controller.pdfViewerController.jumpToPage(
                                    pageNum,
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showAnnotationsMenu(
    BuildContext context,
    PdfPageController controller,
  ) {
    final Map<String, List<AnnotationData>> grouped = {};
    for (var note in controller.allAnnotations) {
      grouped.putIfAbsent(note.type, () => []).add(note);
    }

    final Map<String, Map<String, dynamic>> typeConfig = {
      'sticky_note': {'label': 'Notas Adesivas', 'icon': Icons.speaker_notes},
      'highlight': {
        'label': 'Destaques (Highlights)',
        'icon': Icons.border_color,
      },
      'underline': {'label': 'Sublinhados', 'icon': Icons.format_underlined},
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Anotações do Documento',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: grouped.isEmpty
                    ? const Center(child: Text("Nenhuma anotação encontrada."))
                    : ListView(
                        children: grouped.entries.map((entry) {
                          final config =
                              typeConfig[entry.key] ??
                              {
                                'label': entry.key.toUpperCase(),
                                'icon': Icons.bookmark_border,
                              };

                          return ExpansionTile(
                            leading: Icon(config['icon'] as IconData),
                            title: Text(
                              "${config['label']} (${entry.value.length})",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            children: entry.value.map((annotation) {
                              return ListTile(
                                dense: true,
                                title: Text(
                                  annotation.content ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text("Página ${annotation.page}"),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  controller.pdfViewerController.jumpToPage(
                                    annotation.page,
                                  );
                                },
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void showSettingsModal(
    BuildContext context,
    PdfPageController controller,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Opções de Visualização',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.swap_vert),
                    title: const Text('Rolagem Vertical Contínua'),
                    selected:
                        controller.pageLayoutMode ==
                            PdfPageLayoutMode.continuous &&
                        controller.scrollDirection ==
                            PdfScrollDirection.vertical &&
                        !controller.isReadModeEnabled,
                    onTap: () {
                      controller.setViewLayout(
                        layout: PdfPageLayoutMode.continuous,
                        direction: PdfScrollDirection.vertical,
                      );
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: const Text('Rolagem Horizontal (Estilo Kindle)'),
                    selected:
                        controller.pageLayoutMode == PdfPageLayoutMode.single &&
                        controller.scrollDirection ==
                            PdfScrollDirection.horizontal &&
                        !controller.isReadModeEnabled,
                    onTap: () {
                      controller.setViewLayout(
                        layout: PdfPageLayoutMode.single,
                        direction: PdfScrollDirection.horizontal,
                      );
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.chrome_reader_mode),
                    title: const Text('Modo Leitura'),
                    subtitle: const Text(
                      'Exibe o texto adaptado para telas mobile',
                    ),
                    value: controller.isReadModeEnabled,
                    onChanged: (bool value) {
                      controller.setReadMode(value);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Future<String?> showCommentDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Adicionar Nota de Papel"),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Escreva seu comentário aqui...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  static void showStickyNoteDetail(
    BuildContext context,
    PdfPageController controller,
    StickyNoteAnnotation annotation,
  ) {
    AnnotationData? dbMatch;

    for (var note in controller.dbStickyNotes) {
      try {
        final List<dynamic> rects = jsonDecode(note.rectsJson);
        if (note.page == annotation.pageNumber &&
            ((rects[0]['left'] as num).toDouble() - annotation.position.dx)
                    .abs() <
                0.1 &&
            ((rects[0]['top'] as num).toDouble() - annotation.position.dy)
                    .abs() <
                0.1) {
          dbMatch = note;
          break;
        }
      } catch (_) {}
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Nota Papel - Pág. ${annotation.pageNumber}"),
        content: SingleChildScrollView(child: Text(annotation.text)),
        actions: [
          TextButton(
            onPressed: () async {
              if (dbMatch != null) {
                await controller.deleteStickyNote(dbMatch, annotation);
              } else {
                controller.pdfViewerController.deselectAnnotation(annotation);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              controller.pdfViewerController.deselectAnnotation(annotation);
              Navigator.pop(context);
            },
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  static Future<int?> showPageJumpDialog(
    BuildContext context,
    int currentPage,
    int totalPages,
  ) {
    final pageController = TextEditingController(text: currentPage.toString());
    final formKey = GlobalKey<FormState>();

    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ir para a página"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: pageController,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Digite uma página entre 1 e $totalPages",
              suffixText: "/ $totalPages",
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Digite um número";
              final parsed = int.tryParse(value);
              if (parsed == null || parsed < 1 || parsed > totalPages) {
                return "Página inválida";
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, int.parse(pageController.text));
              }
            },
            child: const Text("Ir"),
          ),
        ],
      ),
    );
  }
}

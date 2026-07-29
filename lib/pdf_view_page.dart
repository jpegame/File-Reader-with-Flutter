import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as pdf_core;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;

import '../database/app_database.dart';
import 'floating_horizontal_menu.dart';
import 'utils/annotation_extension.dart';
import 'components/pdf_search_bar.dart';
import 'components/pdf_text_selection_toolbar.dart';
import 'components/pdf_read_mode_overlay.dart';

class PdfPage extends StatefulWidget {
  final DocumentData doc;
  final AppDatabase db;

  const PdfPage({super.key, required this.doc, required this.db});

  @override
  State<PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> with PdfAnnotationManager {
  final PdfViewerController _controller = PdfViewerController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey =
      GlobalKey<SfPdfViewerState>();
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(1);

  PdfTextSearchResult? _searchResult;
  Timer? _searchDebounce;
  Timer? _saveDebounce;

  int totalPages = 0;
  bool _showSearchBar = false;
  bool _isInitialJumpDone = false;
  bool _isCommentModeEnabled = false;
  bool _isGeneratingSummary = false;

  bool _isReadModeEnabled = false;
  PdfPageLayoutMode _pageLayoutMode = PdfPageLayoutMode.continuous;
  PdfScrollDirection _scrollDirection = PdfScrollDirection.vertical;

  PdfTextSelectionChangedDetails? _currentSelectionDetails;
  List<AnnotationData> _allAnnotations = [];
  List<AnnotationData> _dbStickyNotes = [];

  List<Map<String, dynamic>> _autoSummaryItems = [];

  @override
  void initState() {
    super.initState();
    _loadAllAnnotations();
  }

  @override
  void dispose() {
    _currentPageNotifier.dispose();
    _searchController.dispose();
    _searchResult?.clear();
    _searchDebounce?.cancel();
    _saveDebounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAllAnnotations() async {
    try {
      final annotations = await (widget.db.select(
        widget.db.annotation,
      )..where((t) => t.documentId.equals(widget.doc.id))).get();

      applyAnnotationsToController(
        controller: _controller,
        annotations: annotations,
      );

      setState(() {
        _allAnnotations = annotations;
        _dbStickyNotes = annotations
            .where((element) => element.type == 'sticky_note')
            .toList();
      });
    } catch (e) {
      debugPrint("Error loading annotations: $e");
    }
  }

  Future<void> _generateAutoSummary(StateSetter modalSetState) async {
    if (_autoSummaryItems.isNotEmpty) return;

    modalSetState(() => _isGeneratingSummary = true);

    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final pdf_core.PdfDocument document = pdf_core.PdfDocument(
        inputBytes: widget.doc.fileData!,
      );
      final pdf_core.PdfTextExtractor extractor = pdf_core.PdfTextExtractor(
        document,
      );

      List<Map<String, dynamic>> items = [];

      final RegExp titleCaseRegex = RegExp(r'^[A-Z0-9À-Ú]');
      final RegExp standaloneNumberRegex = RegExp(r'^\d+$');
      final RegExp paginationInlineRegex = RegExp(
        r'(\b(pág|pag|page|página)\b\.?\s*\d+)|(^\d+\s*[\s|•\|\-\/])|([\s|•\|\-\/]\s*\d+$)',
      );

      for (int i = 0; i < document.pages.count; i++) {
        final List<pdf_core.TextLine> pageLines = extractor.extractTextLines(
          startPageIndex: i,
          endPageIndex: i,
        );

        String? foundHeading;

        double pageHeightThreshold = 800.0;
        if (pageLines.isNotEmpty) {
          pageHeightThreshold = pageLines
              .map((e) => e.bounds.bottom)
              .reduce((a, b) => a > b ? a : b);
        }

        final double headerZoneLimit = pageHeightThreshold * 0.10;
        final double footerZoneLimit = pageHeightThreshold * 0.90;

        for (var line in pageLines) {
          final String cleanedText = line.text.trim();
          final double lineTop = line.bounds.top;
          final double lineLeft = line.bounds.left;

          if (cleanedText.length < 3) continue;
          if (standaloneNumberRegex.hasMatch(cleanedText)) continue;
          if (paginationInlineRegex.hasMatch(cleanedText)) continue;
          if (lineTop < headerZoneLimit || lineTop > footerZoneLimit) continue;
          if (lineLeft > 420.0) continue;

          bool isBold = false;
          if (line.wordCollection.isNotEmpty) {
            final firstWordStyle = line.wordCollection.first.fontStyle;
            isBold = firstWordStyle.contains(pdf_core.PdfFontStyle.bold);
          }

          bool isTitleStyle = titleCaseRegex.hasMatch(cleanedText);

          bool isStandaloneLine =
              line.wordCollection.length < 12 && !cleanedText.endsWith('.');

          if ((isBold || isTitleStyle) && isStandaloneLine) {
            foundHeading = cleanedText;
            if (foundHeading.length > 60) {
              foundHeading = "${foundHeading.substring(0, 57)}...";
            }
            break;
          }
        }

        items.add({
          'pageNumber': i + 1,
          'heading': foundHeading ?? "Página ${i + 1} (Conteúdo contínuo)",
        });
      }

      document.dispose();

      modalSetState(() {
        _autoSummaryItems = items;
        _isGeneratingSummary = false;
      });
      setState(() {});
    } catch (e) {
      debugPrint("Error creating auto summary extraction: $e");
      modalSetState(() => _isGeneratingSummary = false);
    }
  }

  void _showSummaryMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (_autoSummaryItems.isEmpty && !_isGeneratingSummary) {
              _generateAutoSummary(setModalState);
            }

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
                    child: _isGeneratingSummary
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
                            itemCount: _autoSummaryItems.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = _autoSummaryItems[index];
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
                                  _controller.jumpToPage(pageNum);
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

  void _showAnnotationsMenu() {
    final Map<String, List<AnnotationData>> grouped = {};
    for (var note in _allAnnotations) {
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
                                  _controller.jumpToPage(annotation.page);
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

  void _handlePageTap(PdfGestureDetails details) async {
    if (!_isCommentModeEnabled) return;
    setState(() => _isCommentModeEnabled = false);

    final String? commentText = await _showCommentDialog();
    if (commentText == null || commentText.isEmpty) return;

    List<Map<String, double>> geometry = [
      {
        'left': details.pagePosition.dx,
        'top': details.pagePosition.dy,
        'width': 30.0,
        'height': 30.0,
      },
    ];

    await widget.db.annotationDao.saveAnnotation(
      AnnotationCompanion(
        documentId: drift.Value(widget.doc.id),
        page: drift.Value(details.pageNumber),
        type: drift.Value('sticky_note'),
        content: drift.Value(commentText),
        rectsJson: drift.Value(jsonEncode(geometry)),
      ),
    );
    await _loadAllAnnotations();
  }

  Future<String?> _showCommentDialog() {
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

  void _handleAnnotationSelected(Annotation annotation) {
    if (annotation is! StickyNoteAnnotation) return;
    AnnotationData? dbMatch;

    for (var note in _dbStickyNotes) {
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
                await (widget.db.delete(
                  widget.db.annotation,
                )..where((t) => t.id.equals(dbMatch!.id))).go();
              }
              _controller.deselectAnnotation(annotation);
              Navigator.pop(context);
              _loadAllAnnotations();
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              _controller.deselectAnnotation(annotation);
              Navigator.pop(context);
            },
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String text) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (text.isEmpty) {
        _searchResult?.clear();
        setState(() {});
        return;
      }
      setState(() => _searchResult = _controller.searchText(text));
    });
  }

  Future<void> _saveProgress(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page_id_${widget.doc.id}', page);
    await (widget.db.update(
      widget.db.document,
    )..where((t) => t.id.equals(widget.doc.id))).write(
      DocumentCompanion(
        lastPage: drift.Value(page),
        lastAccess: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> _handleInitialJump() async {
    if (_isInitialJumpDone) return;
    final prefs = await SharedPreferences.getInstance();
    final int savedPage =
        prefs.getInt('last_page_id_${widget.doc.id}') ?? widget.doc.lastPage;

    if (savedPage > 1) {
      Future.delayed(
        const Duration(milliseconds: 200),
        () => _controller.jumpToPage(savedPage),
      );
    }
    _isInitialJumpDone = true;
  }

  Future<void> _executeSaveAnnotation(String type) async {
    if (_currentSelectionDetails?.selectedText == null) return;

    final String selectedText = _currentSelectionDetails!.selectedText!;
    List<Map<String, double>> rectsList = [];
    int targetPage = _currentPageNotifier.value;

    final List<PdfTextLine>? selectedLines = _pdfViewerKey.currentState
        ?.getSelectedTextLines();
    setState(() => _currentSelectionDetails = null);

    if (selectedLines != null && selectedLines.isNotEmpty) {
      targetPage = selectedLines.first.pageNumber;
      for (PdfTextLine line in selectedLines) {
        rectsList.add({
          'left': line.bounds.left,
          'top': line.bounds.top,
          'width': line.bounds.width,
          'height': line.bounds.height,
        });
      }
    }
    if (rectsList.isEmpty) return;

    await widget.db.annotationDao.saveAnnotation(
      AnnotationCompanion(
        documentId: drift.Value(widget.doc.id),
        page: drift.Value(targetPage),
        type: drift.Value(type),
        content: drift.Value(selectedText),
        rectsJson: drift.Value(jsonEncode(rectsList)),
      ),
    );
    _controller.clearSelection();
    await _loadAllAnnotations();
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
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
                        _pageLayoutMode == PdfPageLayoutMode.continuous &&
                        _scrollDirection == PdfScrollDirection.vertical &&
                        !_isReadModeEnabled,
                    onTap: () {
                      setState(() {
                        _isReadModeEnabled = false;
                        _pageLayoutMode = PdfPageLayoutMode.continuous;
                        _scrollDirection = PdfScrollDirection.vertical;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: const Text('Rolagem Horizontal (Estilo Kindle)'),
                    selected:
                        _pageLayoutMode == PdfPageLayoutMode.single &&
                        _scrollDirection == PdfScrollDirection.horizontal &&
                        !_isReadModeEnabled,
                    onTap: () {
                      setState(() {
                        _isReadModeEnabled = false;
                        _pageLayoutMode = PdfPageLayoutMode.single;
                        _scrollDirection = PdfScrollDirection.horizontal;
                      });
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
                    value: _isReadModeEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _isReadModeEnabled = value;
                      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doc.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize),
            tooltip: "Gerar Sumário Automático",
            onPressed: _showSummaryMenu,
          ),
          IconButton(
            icon: const Icon(Icons.collections_bookmark),
            tooltip: "Ver todas as anotações",
            onPressed: _showAnnotationsMenu,
          ),
          IconButton(
            icon: Icon(
              Icons.note_add,
              color: _isCommentModeEnabled ? Colors.amber : null,
            ),
            tooltip: "Ferramenta Nota Autoadesiva",
            onPressed: () {
              setState(() => _isCommentModeEnabled = !_isCommentModeEnabled);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isCommentModeEnabled
                        ? "Modo ativo. Toque na página."
                        : "Modo desativado.",
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
        bottom: _showSearchBar
            ? PdfSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onPrevMatch: () => _searchResult?.previousInstance(),
                onNextMatch: () => _searchResult?.nextInstance(),
                onClose: () {
                  _searchController.clear();
                  _searchResult?.clear();
                  setState(() => _showSearchBar = false);
                },
              )
            : null,
      ),
      body: Stack(
        children: [
          SfPdfViewer.memory(
            widget.doc.fileData!,
            key: _pdfViewerKey,
            controller: _controller,
            canShowTextSelectionMenu: false,
            onTextSelectionChanged: (d) => setState(
              () => _currentSelectionDetails =
                  d.selectedText?.trim().isEmpty ?? true ? null : d,
            ),
            onTap: _handlePageTap,
            onAnnotationSelected: _handleAnnotationSelected,
            currentSearchTextHighlightColor: const Color.fromRGBO(
              255,
              72,
              0,
              0.35,
            ),
            otherSearchTextHighlightColor: const Color.fromRGBO(
              208,
              255,
              0,
              0.35,
            ),
            pageLayoutMode: _pageLayoutMode,
            scrollDirection: _scrollDirection,
            onDocumentLoaded: (d) {
              setState(() => totalPages = d.document.pages.count);
              _handleInitialJump();
            },
            onPageChanged: (d) {
              _currentPageNotifier.value = d.newPageNumber;
              _saveDebounce?.cancel();
              _saveDebounce = Timer(
                const Duration(milliseconds: 1500),
                () => _saveProgress(d.newPageNumber),
              );
            },
          ),
          if (_isReadModeEnabled)
            PdfReadModeOverlay(
              docBytes: widget.doc.fileData!,
              initialPage: _currentPageNotifier.value,
              totalPages: totalPages,
              annotations: _dbStickyNotes,
              onPageChanged: (newPage) {
                _currentPageNotifier.value = newPage;
                _controller.jumpToPage(newPage);
              },
              onClose: () => setState(() => _isReadModeEnabled = false),
            ),
          if (_currentSelectionDetails?.globalSelectedRegion != null)
            PdfTextSelectionToolbar(
              selectionDetails: _currentSelectionDetails!,
              onHighlightPressed: () => _executeSaveAnnotation('highlight'),
              onUnderlinePressed: () => _executeSaveAnnotation('underline'),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingHorizontalMenu(
              children: [
                FloatingActionButton(
                  heroTag: "search_fab",
                  mini: true,
                  onPressed: () => setState(() => _showSearchBar = true),
                  child: const Icon(Icons.search),
                ),
                FloatingActionButton(
                  heroTag: "settings_fab",
                  mini: true,
                  onPressed: _showSettingsModal,
                  child: const Icon(Icons.settings),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ValueListenableBuilder<int>(
              valueListenable: _currentPageNotifier,
              builder: (context, pageValue, _) => GestureDetector(
                onTap: () async {
                  final int? targetPage = await showDialog<int>(
                    context: context,
                    builder: (context) {
                      final pageController = TextEditingController(
                        text: pageValue.toString(),
                      );
                      final formKey = GlobalKey<FormState>();

                      return AlertDialog(
                        title: const Text("Ir para a página"),
                        content: Form(
                          key: formKey,
                          child: TextFormField(
                            controller: pageController,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText:
                                  "Digite uma página entre 1 e $totalPages",
                              suffixText: "/ $totalPages",
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Digite um número";
                              }
                              final parsed = int.tryParse(value);
                              if (parsed == null ||
                                  parsed < 1 ||
                                  parsed > totalPages) {
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
                                Navigator.pop(
                                  context,
                                  int.parse(pageController.text),
                                );
                              }
                            },
                            child: const Text("Ir"),
                          ),
                        ],
                      );
                    },
                  );
                  if (targetPage != null) {
                    _controller.jumpToPage(targetPage);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        "$pageValue / $totalPages",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

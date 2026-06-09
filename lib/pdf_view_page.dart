import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
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
  bool _isReadModeEnabled = false;

  PdfTextSelectionChangedDetails? _currentSelectionDetails;
  List<AnnotationData> _dbStickyNotes = [];

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
        _dbStickyNotes = annotations
            .where((element) => element.type == 'sticky_note')
            .toList();
      });
    } catch (e) {
      debugPrint("Error loading annotations: $e");
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doc.name),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _showSearchBar = !_showSearchBar),
          ),
          IconButton(
            icon: Icon(
              _isReadModeEnabled
                  ? Icons.chrome_reader_mode
                  : Icons.chrome_reader_mode_outlined,
              color: _isReadModeEnabled ? Colors.greenAccent : null,
            ),
            tooltip: "Modo Leitura Reflow",
            onPressed: () =>
                setState(() => _isReadModeEnabled = !_isReadModeEnabled),
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
            pageLayoutMode: PdfPageLayoutMode.continuous,
            onDocumentLoaded: (d) {
              setState(() => totalPages = d.document.pages.count);
              _handleInitialJump();
              _loadAllAnnotations();
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
                  onPressed: () => debugPrint("Settings clicked"),
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
              builder: (context, pageValue, _) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 0, 0, 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$pageValue / $totalPages",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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

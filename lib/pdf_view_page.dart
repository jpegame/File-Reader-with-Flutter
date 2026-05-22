import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';
import 'floating_horizontal_menu.dart';

class PdfPage extends StatefulWidget {
  final DocumentData doc;
  final AppDatabase db;

  const PdfPage({super.key, required this.doc, required this.db});

  @override
  State<PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  final PdfViewerController _controller = PdfViewerController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey =
      GlobalKey<SfPdfViewerState>();

  PdfTextSearchResult? _searchResult;
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  Timer? _saveDebounce;

  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(1);
  int totalPages = 0;
  bool _showSearchBar = false;
  bool _isInitialJumpDone = false;

  PdfTextSelectionChangedDetails? _currentSelectionDetails;
  List<AnnotationData> _dbStickyNotes = [];
  bool _isCommentModeEnabled = false;

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
    _searchResult = null;
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

      _controller.removeAllAnnotations();
      List<AnnotationData> freshStickyNotes = [];

      for (var annotation in annotations) {
        try {
          final List<dynamic> rects = jsonDecode(annotation.rectsJson);

          if (annotation.type == 'sticky_note') {
            freshStickyNotes.add(annotation);

            final Offset position = Offset(
              (rects[0]['left'] as num).toDouble(),
              (rects[0]['top'] as num).toDouble(),
            );

            final stickyNote = StickyNoteAnnotation(
              position: position,
              pageNumber: annotation.page,
              text: annotation.content ?? "",
              icon: PdfStickyNoteIcon.comment,
            );

            _controller.addAnnotation(stickyNote);
            continue;
          }

          final List<PdfTextLine> textLines = [];
          for (var r in rects) {
            textLines.add(
              PdfTextLine(
                Rect.fromLTWH(
                  (r['left'] as num).toDouble(),
                  (r['top'] as num).toDouble(),
                  (r['width'] as num).toDouble(),
                  (r['height'] as num).toDouble(),
                ),
                "",
                annotation.page,
              ),
            );
          }

          if (textLines.isNotEmpty) {
            if (annotation.type == 'underline') {
              final underline = UnderlineAnnotation(
                textBoundsCollection: textLines,
              );
              underline.color = Colors.red;
              _controller.addAnnotation(underline);
            } else if (annotation.type == 'note') {
              final noteLine = UnderlineAnnotation(
                textBoundsCollection: textLines,
              );
              noteLine.color = Colors.blue;
              _controller.addAnnotation(noteLine);
            } else {
              final highlight = HighlightAnnotation(
                textBoundsCollection: textLines,
              );
              highlight.color = Colors.yellow;
              highlight.opacity = 0.5;
              _controller.addAnnotation(highlight);
            }
          }
        } catch (e) {
          debugPrint("Failed parsing layout geometry: $e");
        }
      }

      setState(() {
        _dbStickyNotes = freshStickyNotes;
      });
    } catch (e) {
      debugPrint("Error loading annotations: $e");
    }
  }
  void _handlePageTap(PdfGestureDetails details) async {
    if (!_isCommentModeEnabled) return;

    setState(() {
      _isCommentModeEnabled = false;
    });

    final Offset pagePosition = details.pagePosition;
    final int pageNumber = details.pageNumber;

    final TextEditingController commentController = TextEditingController();

    final String? commentText = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Adicionar Nota de Papel"),
        content: TextField(
          controller: commentController,
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
            onPressed: () =>
                Navigator.pop(context, commentController.text.trim()),
            child: const Text("Salvar"),
          ),
        ],
      ),
    );

    if (commentText == null || commentText.isEmpty) return;

    List<Map<String, double>> geometry = [
      {
        'left': pagePosition.dx,
        'top': pagePosition.dy,
        'width': 30.0,
        'height': 30.0,
      },
    ];

    await widget.db.annotationDao.saveAnnotation(
      AnnotationCompanion(
        documentId: drift.Value(widget.doc.id),
        page: drift.Value(pageNumber),
        type: drift.Value('sticky_note'),
        content: drift.Value(commentText),
        rectsJson: drift.Value(jsonEncode(geometry)),
      ),
    );

    await _loadAllAnnotations();
  }

  void _handleAnnotationSelected(Annotation annotation) {
    if (annotation is StickyNoteAnnotation) {
      AnnotationData? dbMatch;

      for (var note in _dbStickyNotes) {
        try {
          final List<dynamic> rects = jsonDecode(note.rectsJson);
          final double left = (rects[0]['left'] as num).toDouble();
          final double top = (rects[0]['top'] as num).toDouble();

          if (note.page == annotation.pageNumber &&
              (left - annotation.position.dx).abs() < 0.1 &&
              (top - annotation.position.dy).abs() < 0.1) {
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
  }

  void _onSearchChanged(String text) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (text.isEmpty) {
        _searchResult?.clear();
        setState(() {});
        return;
      }
      setState(() {
        _searchResult = _controller.searchText(text);
      });
    });
  }

  void _nextMatch() => _searchResult?.nextInstance();
  void _prevMatch() => _searchResult?.previousInstance();

  void _clearSearch() {
    _searchController.clear();
    _searchResult?.clear();
    _searchResult = null;
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
      Future.delayed(const Duration(milliseconds: 200), () {
        _controller.jumpToPage(savedPage);
      });
    }
    _isInitialJumpDone = true;
  }

  void _onTextSelectionChanged(PdfTextSelectionChangedDetails details) {
    setState(() {
      if (details.selectedText == null ||
          details.selectedText!.trim().isEmpty) {
        _currentSelectionDetails = null;
      } else {
        _currentSelectionDetails = details;
      }
    });
  }

  Future<void> _executeSaveAnnotation(String type) async {
    if (_currentSelectionDetails == null ||
        _currentSelectionDetails!.selectedText == null) {
      return;
    }

    final String selectedText = _currentSelectionDetails!.selectedText!;
    List<Map<String, double>> rectsList = [];
    int targetPage = _currentPageNotifier.value;

    final List<PdfTextLine>? selectedLines = _pdfViewerKey.currentState
        ?.getSelectedTextLines();

    setState(() {
      _currentSelectionDetails = null;
    });

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
              setState(() {
                _isCommentModeEnabled = !_isCommentModeEnabled;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isCommentModeEnabled
                        ? "Modo de comentário ativo. Toque na página para fixar."
                        : "Modo de comentário desativado.",
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
        ],
        bottom: _showSearchBar ? _buildSearchAppBar() : null,
      ),
      body: Stack(
        children: [
          SfPdfViewer.memory(
            widget.doc.fileData!,
            key: _pdfViewerKey,
            controller: _controller,
            canShowTextSelectionMenu: false,
            onTextSelectionChanged: _onTextSelectionChanged,
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
            onDocumentLoaded: (details) {
              setState(() => totalPages = details.document.pages.count);
              _handleInitialJump();
              _loadAllAnnotations();
            },
            onPageChanged: (details) {
              _currentPageNotifier.value = details.newPageNumber;
              _saveDebounce?.cancel();
              _saveDebounce = Timer(const Duration(milliseconds: 1500), () {
                _saveProgress(details.newPageNumber);
              });
            },
          ),
          if (_currentSelectionDetails != null &&
              _currentSelectionDetails!.globalSelectedRegion != null)
            Builder(
              builder: (context) {
                final RenderBox? renderBox =
                    context.findRenderObject() as RenderBox?;
                final Offset localOffset = renderBox != null
                    ? renderBox.globalToLocal(
                        _currentSelectionDetails!
                            .globalSelectedRegion!
                            .topCenter,
                      )
                    : _currentSelectionDetails!.globalSelectedRegion!.topCenter;

                final double screenWidth = MediaQuery.of(context).size.width;
                final double screenHeight = MediaQuery.of(context).size.height;

                return Positioned(
                  top: (localOffset.dy - 60).clamp(10.0, screenHeight - 100),
                  left: (localOffset.dx - 100).clamp(10.0, screenWidth - 210),
                  child: Material(
                    elevation: 12,
                    borderRadius: BorderRadius.circular(30),
                    color: const Color(0xFF1E1E1E),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.border_color,
                              color: Colors.yellow,
                              size: 20,
                            ),
                            tooltip: "Highlight",
                            onPressed: () =>
                                _executeSaveAnnotation('highlight'),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.format_underlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            tooltip: "Underline",
                            onPressed: () =>
                                _executeSaveAnnotation('underline'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
              builder: (context, pageValue, child) {
                return Container(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSize _buildSearchAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Procurar palavra",
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _prevMatch,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _nextMatch,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _clearSearch();
                setState(() => _showSearchBar = false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

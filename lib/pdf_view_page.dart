import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../database/app_database.dart';
import 'utils/annotation_extension.dart';
import 'components/pdf/pdf_page_controller.dart';
import 'components/pdf/pdf_page_modals.dart';
import 'floating_horizontal_menu.dart';
import 'components/pdf/pdf_search_bar.dart';
import 'components/pdf/pdf_text_selection_toolbar.dart';
import 'components/pdf/pdf_read_mode_overlay.dart';
import 'components/pdf/pdf_audio_player.dart';

class PdfPage extends StatefulWidget {
  final DocumentData doc;
  final AppDatabase db;

  const PdfPage({super.key, required this.doc, required this.db});

  @override
  State<PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> with PdfAnnotationManager {
  late final PdfPageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PdfPageController(
      doc: widget.doc,
      db: widget.db,
      onApplyAnnotations: (annotations) {
        applyAnnotationsToController(
          controller: _pageController.pdfViewerController,
          annotations: annotations,
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageTap(PdfGestureDetails details) async {
    if (!_pageController.isCommentModeEnabled) return;
    _pageController.toggleCommentMode();

    final String? commentText = await PdfPageModals.showCommentDialog(context);
    if (commentText == null || commentText.isEmpty) return;

    await _pageController.addStickyNote(details, commentText);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _pageController,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.doc.name),
            actions: [
              IconButton(
                icon: Icon(
                  _pageController.isAudioPlaying
                      ? Icons.volume_up
                      : Icons.volume_up_outlined,
                  color: _pageController.isAudioPlaying
                      ? Colors.redAccent
                      : null,
                ),
                onPressed: () => _pageController.toggleAudioPlayer(),
              ),
              IconButton(
                icon: const Icon(Icons.summarize),
                tooltip: "Gerar Sumário Automático",
                onPressed: () =>
                    PdfPageModals.showSummaryMenu(context, _pageController),
              ),
              IconButton(
                icon: const Icon(Icons.collections_bookmark),
                tooltip: "Ver todas as anotações",
                onPressed: () =>
                    PdfPageModals.showAnnotationsMenu(context, _pageController),
              ),
              IconButton(
                icon: Icon(
                  Icons.note_add,
                  color: _pageController.isCommentModeEnabled
                      ? Colors.amber
                      : null,
                ),
                tooltip: "Ferramenta Nota Autoadesiva",
                onPressed: () {
                  _pageController.toggleCommentMode();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _pageController.isCommentModeEnabled
                            ? "Modo ativo. Toque na página."
                            : "Modo desativado.",
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
            bottom: _pageController.showSearchBar
                ? PdfSearchBar(
                    controller: _pageController.searchController,
                    onChanged: _pageController.onSearchChanged,
                    onPrevMatch: () =>
                        _pageController.searchResult?.previousInstance(),
                    onNextMatch: () =>
                        _pageController.searchResult?.nextInstance(),
                    onClose: () => _pageController.toggleSearchBar(false),
                  )
                : null,
          ),
          body: Stack(
            children: [
              SfPdfViewer.memory(
                widget.doc.fileData!,
                key: _pageController.pdfViewerKey,
                controller: _pageController.pdfViewerController,
                canShowTextSelectionMenu: false,
                onTextSelectionChanged: _pageController.updateSelection,
                onTap: _handlePageTap,
                onAnnotationSelected: (annotation) {
                  if (annotation is StickyNoteAnnotation) {
                    PdfPageModals.showStickyNoteDetail(
                      context,
                      _pageController,
                      annotation,
                    );
                  }
                },
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
                pageLayoutMode: _pageController.pageLayoutMode,
                scrollDirection: _pageController.scrollDirection,
                onDocumentLoaded: (d) {
                  _pageController.setTotalPages(d.document.pages.count);
                  _pageController.handleInitialJump();
                },
                onPageChanged: (d) =>
                    _pageController.updatePage(d.newPageNumber),
              ),
              if (_pageController.isReadModeEnabled)
                PdfReadModeOverlay(
                  docBytes: widget.doc.fileData!,
                  initialPage: _pageController.currentPage,
                  totalPages: _pageController.totalPages,
                  annotations: _pageController.dbStickyNotes,
                  onPageChanged: (newPage) {
                    _pageController.updatePage(newPage);
                    _pageController.pdfViewerController.jumpToPage(newPage);
                  },
                  onClose: () => _pageController.setReadMode(false),
                ),
              if (_pageController
                      .currentSelectionDetails
                      ?.globalSelectedRegion !=
                  null)
                PdfTextSelectionToolbar(
                  selectionDetails: _pageController.currentSelectionDetails!,
                  onHighlightPressed: () =>
                      _pageController.executeSaveAnnotation('highlight'),
                  onUnderlinePressed: () =>
                      _pageController.executeSaveAnnotation('underline'),
                ),
              Positioned(
                bottom: 16,
                left: 16,
                child: FloatingHorizontalMenu(
                  children: [
                    FloatingActionButton(
                      heroTag: "search_fab",
                      mini: true,
                      onPressed: () => _pageController.toggleSearchBar(true),
                      child: const Icon(Icons.search),
                    ),
                    FloatingActionButton(
                      heroTag: "settings_fab",
                      mini: true,
                      onPressed: () => PdfPageModals.showSettingsModal(
                        context,
                        _pageController,
                      ),
                      child: const Icon(Icons.settings),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () async {
                    final int? targetPage =
                        await PdfPageModals.showPageJumpDialog(
                          context,
                          _pageController.currentPage,
                          _pageController.totalPages,
                        );
                    if (targetPage != null) {
                      _pageController.pdfViewerController.jumpToPage(
                        targetPage,
                      );
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
                          "${_pageController.currentPage} / ${_pageController.totalPages}",
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
              if (_pageController.isAudioPlaying)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: PdfAudioPlayer(fileData: widget.doc.fileData!),
                ),
            ],
          ),
        );
      },
    );
  }
}

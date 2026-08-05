import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as pdf_core;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;

import '../../database/app_database.dart';
import 'pdf_tts_controller.dart';

class PdfPageController extends ChangeNotifier {
  final DocumentData doc;
  final AppDatabase db;
  final void Function(List<AnnotationData> annotations)? onApplyAnnotations;

  final PdfViewerController pdfViewerController = PdfViewerController();
  final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey<SfPdfViewerState>();
  final TextEditingController searchController = TextEditingController();
  final PdfTtsController ttsController = PdfTtsController();

  Timer? _searchDebounce;
  Timer? _saveDebounce;

  int currentPage = 1;
  int totalPages = 0;
  bool showSearchBar = false;
  bool isInitialJumpDone = false;
  bool isCommentModeEnabled = false;
  bool isGeneratingSummary = false;
  bool isReadModeEnabled = false;

  PdfPageLayoutMode pageLayoutMode = PdfPageLayoutMode.continuous;
  PdfScrollDirection scrollDirection = PdfScrollDirection.vertical;

  PdfTextSearchResult? searchResult;
  PdfTextSelectionChangedDetails? currentSelectionDetails;

  List<AnnotationData> allAnnotations = [];
  List<AnnotationData> dbStickyNotes = [];
  List<Map<String, dynamic>> autoSummaryItems = [];

  PdfPageController({
    required this.doc,
    required this.db,
    this.onApplyAnnotations,
  }) {
    loadAllAnnotations();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchResult?.clear();
    _searchDebounce?.cancel();
    _saveDebounce?.cancel();
    pdfViewerController.dispose();
    ttsController.dispose();
    super.dispose();
  }

  void toggleSearchBar(bool show) {
    showSearchBar = show;
    if (!show) {
      searchController.clear();
      searchResult?.clear();
    }
    notifyListeners();
  }

  void toggleCommentMode() {
    isCommentModeEnabled = !isCommentModeEnabled;
    notifyListeners();
  }

  void setReadMode(bool value) {
    isReadModeEnabled = value;
    notifyListeners();
  }

  void setViewLayout({required PdfPageLayoutMode layout, required PdfScrollDirection direction}) {
    isReadModeEnabled = false;
    pageLayoutMode = layout;
    scrollDirection = direction;
    notifyListeners();
  }

  void updateSelection(PdfTextSelectionChangedDetails? details) {
    currentSelectionDetails = details?.selectedText?.trim().isEmpty ?? true ? null : details;
    notifyListeners();
  }

  void updatePage(int newPage) {
    currentPage = newPage;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(
      const Duration(milliseconds: 1500),
      () => saveProgress(newPage),
    );
    notifyListeners();
  }

  void setTotalPages(int count) {
    totalPages = count;
    notifyListeners();
  }

  Future<void> loadAllAnnotations() async {
    try {
      final annotations = await (db.select(
        db.annotation,
      )..where((t) => t.documentId.equals(doc.id))).get();

      onApplyAnnotations?.call(annotations);

      allAnnotations = annotations;
      dbStickyNotes = annotations.where((element) => element.type == 'sticky_note').toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading annotations: $e");
    }
  }

  void onSearchChanged(String text) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (text.isEmpty) {
        searchResult?.clear();
        notifyListeners();
        return;
      }
      searchResult = pdfViewerController.searchText(text);
      notifyListeners();
    });
  }

  Future<void> saveProgress(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page_id_${doc.id}', page);
    await (db.update(db.document)..where((t) => t.id.equals(doc.id))).write(
      DocumentCompanion(
        lastPage: drift.Value(page),
        lastAccess: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> handleInitialJump() async {
    if (isInitialJumpDone) return;
    final prefs = await SharedPreferences.getInstance();
    final int savedPage = prefs.getInt('last_page_id_${doc.id}') ?? doc.lastPage;

    if (savedPage > 1) {
      Future.delayed(
        const Duration(milliseconds: 200),
        () => pdfViewerController.jumpToPage(savedPage),
      );
    }
    isInitialJumpDone = true;
  }

  Future<void> executeSaveAnnotation(String type) async {
    if (currentSelectionDetails?.selectedText == null) return;

    final String selectedText = currentSelectionDetails!.selectedText!;
    List<Map<String, double>> rectsList = [];
    int targetPage = currentPage;

    final List<PdfTextLine>? selectedLines = pdfViewerKey.currentState?.getSelectedTextLines();
    currentSelectionDetails = null;

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

    await db.annotationDao.saveAnnotation(
      AnnotationCompanion(
        documentId: drift.Value(doc.id),
        page: drift.Value(targetPage),
        type: drift.Value(type),
        content: drift.Value(selectedText),
        rectsJson: drift.Value(jsonEncode(rectsList)),
      ),
    );
    pdfViewerController.clearSelection();
    await loadAllAnnotations();
  }

  Future<void> addStickyNote(PdfGestureDetails details, String commentText) async {
    List<Map<String, double>> geometry = [
      {
        'left': details.pagePosition.dx,
        'top': details.pagePosition.dy,
        'width': 30.0,
        'height': 30.0,
      },
    ];

    await db.annotationDao.saveAnnotation(
      AnnotationCompanion(
        documentId: drift.Value(doc.id),
        page: drift.Value(details.pageNumber),
        type: drift.Value('sticky_note'),
        content: drift.Value(commentText),
        rectsJson: drift.Value(jsonEncode(geometry)),
      ),
    );
    await loadAllAnnotations();
  }

  Future<void> deleteStickyNote(AnnotationData note, StickyNoteAnnotation annotation) async {
    await (db.delete(db.annotation)..where((t) => t.id.equals(note.id))).go();
    pdfViewerController.deselectAnnotation(annotation);
    await loadAllAnnotations();
  }

  Future<void> generateAutoSummary() async {
    if (autoSummaryItems.isNotEmpty) return;

    isGeneratingSummary = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final pdf_core.PdfDocument document = pdf_core.PdfDocument(inputBytes: doc.fileData!);
      final pdf_core.PdfTextExtractor extractor = pdf_core.PdfTextExtractor(document);

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
          pageHeightThreshold = pageLines.map((e) => e.bounds.bottom).reduce((a, b) => a > b ? a : b);
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
          bool isStandaloneLine = line.wordCollection.length < 12 && !cleanedText.endsWith('.');

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
      autoSummaryItems = items;
    } catch (e) {
      debugPrint("Error creating auto summary extraction: $e");
    } finally {
      isGeneratingSummary = false;
      notifyListeners();
    }
  }
}
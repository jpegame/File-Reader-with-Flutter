import 'dart:async';
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
  PdfTextSearchResult? _searchResult;
  final TextEditingController _searchController = TextEditingController();
  
  Timer? _debounce;
  int currentPage = 1;
  int totalPages = 0;
  bool _showSearchBar = false;
  bool _isInitialJumpDone = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
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
  }

  Future<void> _saveProgress(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page_id_${widget.doc.id}', page);
    await (widget.db.update(widget.db.document)
          ..where((t) => t.id.equals(widget.doc.id)))
        .write(
      DocumentCompanion(
        lastPage: drift.Value(page),
        lastAccess: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> _handleInitialJump() async {
    if (_isInitialJumpDone) return;

    final prefs = await SharedPreferences.getInstance();
    final int savedPage = prefs.getInt('last_page_id_${widget.doc.id}') ?? widget.doc.lastPage;

    if (savedPage > 1) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _controller.jumpToPage(savedPage);
      });
    }
    _isInitialJumpDone = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doc.name),
        actions: [
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
            controller: _controller,
            currentSearchTextHighlightColor: const Color.fromRGBO(255, 72, 0, 0.35),
            otherSearchTextHighlightColor: const Color.fromRGBO(208, 255, 0, 0.35),
            onDocumentLoaded: (details) {
              setState(() => totalPages = details.document.pages.count);
              _handleInitialJump();
            },
            onPageChanged: (details) {
              setState(() => currentPage = details.newPageNumber);
              _saveProgress(details.newPageNumber);
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
                  onPressed: () => print("Settings clicked"),
                  child: const Icon(Icons.settings),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "$currentPage / $totalPages",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
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
                  hintText: "Find in document...",
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: _prevMatch),
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextMatch),
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
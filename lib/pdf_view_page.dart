import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'floating_horizontal_menu.dart';

class PdfPage extends StatefulWidget {
  final Uint8List pdfBytes;

  const PdfPage({super.key, required this.pdfBytes});

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

  @override
  void initState() {
    super.initState();
    _loadLastPage();
  }

  void _onSearchChanged(String text) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (text.isEmpty) {
        _searchResult?.clear();
        return;
      }

      setState(() {
        _searchResult = _controller.searchText(text);
      });
    });
  }

  void _nextMatch() {
    _searchResult?.nextInstance();
  }

  void _prevMatch() {
    _searchResult?.previousInstance();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchResult?.clear();
  }

  Future<void> _saveLastPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page', page);
  }

  Future<void> _loadLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    final page = prefs.getInt('last_page') ?? 1;

    Future.delayed(const Duration(milliseconds: 500), () {
      _controller.jumpToPage(page);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Viewer"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: _prevMatch,
                ),

                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: _nextMatch,
                ),

                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clearSearch,
                ),
              ],
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          SfPdfViewer.memory(
            widget.pdfBytes,
            controller: _controller,
            currentSearchTextHighlightColor: Color.fromRGBO(255, 72, 0, 0.35),
            otherSearchTextHighlightColor: Color.fromRGBO(208, 255, 0, 0.35),

            onDocumentLoaded: (details) {
              setState(() {
                totalPages = details.document.pages.count;
              });
            },

            onPageChanged: (details) {
              setState(() {
                currentPage = details.newPageNumber;
              });

              _saveLastPage(details.newPageNumber);
            },
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingHorizontalMenu(
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    print("Feature 1");
                  },
                  child: Icon(Icons.search),
                ),
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    print("Feature 2");
                  },
                  child: Icon(Icons.settings),
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
                color: Color.fromRGBO(0, 0, 0, 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$currentPage / $totalPages",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

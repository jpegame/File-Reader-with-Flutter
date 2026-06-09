import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../database/app_database.dart';
import 'read_mode_config.dart';

class PdfReadModeOverlay extends StatefulWidget {
  final List<int> docBytes;
  final int initialPage;
  final int totalPages;
  final List<AnnotationData> annotations;
  final ValueChanged<int> onPageChanged; // Notifies main app on dynamic scrolls
  final VoidCallback onClose;

  const PdfReadModeOverlay({
    super.key,
    required this.docBytes,
    required this.initialPage,
    required this.totalPages,
    required this.annotations,
    required this.onPageChanged,
    required this.onClose,
  });

  @override
  State<PdfReadModeOverlay> createState() => _PdfReadModeOverlayState();
}

class _PdfReadModeOverlayState extends State<PdfReadModeOverlay> {
  final ScrollController _scrollController = ScrollController();
  ReadModeConfig _config = const ReadModeConfig();
  
  final Map<int, List<TextSpan>> _pageCache = <int, List<TextSpan>>{};
  final Map<int, GlobalKey> _pageKeys = <int, GlobalKey>{};
  
  bool _isInitLoading = true;
  late PdfDocument _pdfDocument;

  @override
  void initState() {
    super.initState();
    _initializePdfAndScroll();
  }

  void _initializePdfAndScroll() {
    try {
      _pdfDocument = PdfDocument(inputBytes: widget.docBytes);
      
      // Generate unique structural tracking keys for every single page in the doc
      for (int i = 0; i < widget.totalPages; i++) {
        _pageKeys[i] = GlobalKey();
      }

      setState(() => _isInitLoading = false);

      // Instantly jump to the user's active page coordinate context right after rendering
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToPage(widget.initialPage - 1);
        _scrollController.addListener(_onScrollListener);
      });
    } catch (e) {
      debugPrint("Error opening PDF structural bytes: $e");
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollListener);
    _scrollController.dispose();
    _pdfDocument.dispose();
    super.dispose();
  }

  // Dynamic calculation to identify which page element is currently visible on screen
  void _onScrollListener() {
    for (int i = 0; i < widget.totalPages; i++) {
      final context = _pageKeys[i]?.currentContext;
      if (context != null) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        
        // If the top boundary of a text container spans into view, fire parent sync
        if (position.dy >= 0 && position.dy < MediaQuery.of(context).size.height / 3) {
          widget.onPageChanged(i + 1);
          break;
        }
      }
    }
  }

  void _scrollToPage(int pageIndex) {
    final context = _pageKeys[pageIndex]?.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<TextSpan> _getStyledPageText(int pageIndex) {
    if (_pageCache.containsKey(pageIndex)) {
      return _pageCache[pageIndex]!;
    }

    List<TextSpan> spans = [];
    try {
      final List<TextLine> lines = PdfTextExtractor(_pdfDocument).extractTextLines(
        startPageIndex: pageIndex,
        endPageIndex: pageIndex,
      );

      final pageNum = pageIndex + 1;
      final pageAnnotations = widget.annotations.where((a) => a.page == pageNum).toList();

      for (TextLine line in lines) {
        String lineText = line.text;
        Color textColor = _config.textColor;
        FontWeight weight = FontWeight.normal;
        TextDecoration decoration = TextDecoration.none;

        for (var annotation in pageAnnotations) {
          if (annotation.content != null && lineText.contains(annotation.content!)) {
            if (annotation.type == 'highlight') {
              textColor = _config.backgroundColor == const Color(0xFF121212) 
                  ? Colors.amberAccent 
                  : const Color(0xFFB38F00); 
              weight = FontWeight.bold;
            } else if (annotation.type == 'underline') {
              textColor = Colors.red;
              decoration = TextDecoration.underline;
            } else if (annotation.type == 'note') {
              textColor = Colors.blue;
            }
          }
        }

        spans.add(TextSpan(
          text: "$lineText\n",
          style: TextStyle(
            color: textColor,
            fontWeight: weight,
            decoration: decoration,
            decorationColor: textColor,
          ),
        ));
      }

      if (spans.isEmpty) {
        spans.add(TextSpan(
          text: "Esta página não possui texto extraível.\n",
          style: TextStyle(color: _config.textColor.withOpacity(0.5)),
        ));
      }
    } catch (e) {
      spans.add(TextSpan(text: "Erro ao extrair texto da página: $e\n"));
    }

    _pageCache[pageIndex] = spans;
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _config.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            _buildControlBar(),
            Expanded(
              child: _isInitLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: widget.totalPages,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      itemBuilder: (context, index) {
                        final textSpans = _getStyledPageText(index);
                        return Container(
                          key: _pageKeys[index], // Assigned global mapping keys for element calculations
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Visual separator between pages
                              Text(
                                "--- PÁGINA ${index + 1} ---",
                                style: TextStyle(
                                  color: _config.textColor.withOpacity(0.4),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              RichText(
                                text: TextSpan(
                                  children: textSpans,
                                  style: TextStyle(
                                    fontSize: _config.fontSize,
                                    height: _config.lineSpacing,
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: Colors.black.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: _config.textColor),
            onPressed: widget.onClose,
          ),
          IconButton(
            icon: Icon(Icons.text_decrease, color: _config.textColor),
            onPressed: () => setState(() => _config = _config.copyWith(fontSize: (_config.fontSize - 1).clamp(12.0, 32.0))),
          ),
          IconButton(
            icon: Icon(Icons.text_increase, color: _config.textColor),
            onPressed: () => setState(() => _config = _config.copyWith(fontSize: (_config.fontSize + 1).clamp(12.0, 32.0))),
          ),
          IconButton(
            icon: Icon(Icons.format_line_spacing, color: _config.textColor),
            onPressed: () {
              setState(() {
                double nextSpacing = _config.lineSpacing == 1.2 ? 1.6 : (_config.lineSpacing == 1.6 ? 2.2 : 1.2);
                _config = _config.copyWith(lineSpacing: nextSpacing);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.palette, color: _config.textColor),
            onPressed: () {
              setState(() {
                _pageCache.clear(); 
                if (_config.backgroundColor == const Color(0xFFFBF0D9)) {
                  _config = _config.copyWith(backgroundColor: Colors.white, textColor: Colors.black87);
                } else if (_config.backgroundColor == Colors.white) {
                  _config = _config.copyWith(backgroundColor: const Color(0xFF121212), textColor: Colors.white70);
                } else {
                  _config = _config.copyWith(backgroundColor: const Color(0xFFFBF0D9), textColor: const Color(0xFF5B4636));
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
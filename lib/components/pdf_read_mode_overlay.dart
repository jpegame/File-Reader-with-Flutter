import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../database/app_database.dart';
import 'read_mode_config.dart';

class PdfReadModeOverlay extends StatefulWidget {
  final List<int> docBytes;
  final int initialPage;
  final int totalPages;
  final List<AnnotationData> annotations;
  final ValueChanged<int> onPageChanged;
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

  final Map<int, List<InlineSpan>> _pageCache = <int, List<InlineSpan>>{};
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

      for (int i = 0; i < widget.totalPages; i++) {
        _pageKeys[i] = GlobalKey();
      }

      setState(() => _isInitLoading = false);

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

  void _onScrollListener() {
    for (int i = 0; i < widget.totalPages; i++) {
      final context = _pageKeys[i]?.currentContext;
      if (context != null) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);

        if (position.dy >= 0 &&
            position.dy < MediaQuery.of(context).size.height / 3) {
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

  List<InlineSpan> _getStyledPageText(int pageIndex) {
    if (_pageCache.containsKey(pageIndex)) {
      return _pageCache[pageIndex]!;
    }

    List<InlineSpan> spans = [];
    try {
      final List<TextLine> lines = PdfTextExtractor(
        _pdfDocument,
      ).extractTextLines(startPageIndex: pageIndex, endPageIndex: pageIndex);

      if (lines.isEmpty) {
        _pageCache[pageIndex] = [
          TextSpan(
            text: "Esta página não possui texto extraível.\n",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ];
        return _pageCache[pageIndex]!;
      }

      final pageNum = pageIndex + 1;
      final pageAnnotations = widget.annotations
          .where((a) => a.page == pageNum)
          .toList();

      final bool isDarkMode =
          _config.backgroundColor == const Color(0xFF121212);

      // Structure to hold organized paragraphs
      List<List<TextWord>> paragraphs = [];
      List<TextWord> currentParagraphWords = [];

      double? lastLineY;
      double? lastLineHeight;

      for (int i = 0; i < lines.length; i++) {
        final TextLine currentLine = lines[i];
        final double currentY = currentLine.bounds.top;
        final double currentHeight = currentLine.bounds.height;

        if (lastLineY != null && lastLineHeight != null) {
          double lineGap = currentY - (lastLineY + lastLineHeight);

          // If the gap between lines is significantly wider than standard line heights,
          // or if the current line has a sudden massive indentation change, treat it as a paragraph jump.
          if (lineGap > currentHeight * 0.85 ||
              currentLine.wordCollection.isEmpty) {
            if (currentParagraphWords.isNotEmpty) {
              paragraphs.add(List.from(currentParagraphWords));
              currentParagraphWords.clear();
            }
          }
        }

        currentParagraphWords.addAll(currentLine.wordCollection);
        lastLineY = currentY;
        lastLineHeight = currentHeight;
      }

      // Catch final paragraph block
      if (currentParagraphWords.isNotEmpty) {
        paragraphs.add(currentParagraphWords);
      }

      // Build out the UI RichText representations per Paragraph block
      for (
        var paragraphIndex = 0;
        paragraphIndex < paragraphs.length;
        paragraphIndex++
      ) {
        List<TextWord> words = paragraphs[paragraphIndex];
        List<TextSpan> paragraphSpans = [];

        for (int w = 0; w < words.length; w++) {
          TextWord word = words[w];
          String wordText = word.text;

          // Standardize handling of structural hyphens split across line extractions
          bool endsWithHyphen = wordText.endsWith('-');

          Color textColor = isDarkMode ? Colors.white70 : Colors.black87;
          TextDecoration decoration = TextDecoration.none;
          FontWeight weight = FontWeight.normal;
          FontStyle style = FontStyle.normal;

          if (word.fontStyle.contains(PdfFontStyle.bold)) {
            weight = FontWeight.bold;
          }
          if (word.fontStyle.contains(PdfFontStyle.italic)) {
            style = FontStyle.italic;
          }

          // Annotation checks
          for (var annotation in pageAnnotations) {
            if (annotation.content != null &&
                wordText.contains(annotation.content!)) {
              if (annotation.type == 'highlight') {
                textColor = isDarkMode
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

          // If word was broken naturally by a PDF line break, join it instead of double spacing
          String spacing = endsWithHyphen ? "" : " ";

          paragraphSpans.add(
            TextSpan(
              text: "$wordText$spacing",
              style: TextStyle(
                color: textColor,
                fontWeight: weight,
                fontStyle: style,
                decoration: decoration,
                decorationColor: textColor,
              ),
            ),
          );
        }

        // Add the paragraph to our layout with localized text alignment control via WidgetSpan
        spans.add(
          WidgetSpan(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  children: paragraphSpans,
                  style: TextStyle(
                    fontSize: _config.fontSize,
                    height: _config.lineSpacing,
                    fontFamily: 'serif',
                  ),
                ),
              ),
            ),
          ),
        );
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      itemBuilder: (context, index) {
                        final inlineElements = _getStyledPageText(index);
                        return Container(
                          key: _pageKeys[index],
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Text(
                                    "--- PÁGINA ${index + 1} ---",
                                    style: TextStyle(
                                      color: _config.textColor.withOpacity(0.4),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Use Text.rich to correctly parse our grouped Paragraph WidgetSpans
                              Text.rich(TextSpan(children: inlineElements)),
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
            onPressed: () => setState(() {
              _pageCache.clear(); // Clear cache so styles regenerate
              _config = _config.copyWith(
                fontSize: (_config.fontSize - 1).clamp(12.0, 32.0),
              );
            }),
          ),
          IconButton(
            icon: Icon(Icons.text_increase, color: _config.textColor),
            onPressed: () => setState(() {
              _pageCache.clear(); // Clear cache so styles regenerate
              _config = _config.copyWith(
                fontSize: (_config.fontSize + 1).clamp(12.0, 32.0),
              );
            }),
          ),
          IconButton(
            icon: Icon(Icons.format_line_spacing, color: _config.textColor),
            onPressed: () {
              setState(() {
                _pageCache.clear(); // Clear cache so spacing regenerates
                double nextSpacing = _config.lineSpacing == 1.2
                    ? 1.6
                    : (_config.lineSpacing == 1.6 ? 2.2 : 1.2);
                _config = _config.copyWith(lineSpacing: nextSpacing);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.palette, color: _config.textColor),
            onPressed: () {
              setState(() {
                _pageCache.clear();
                if (_config.backgroundColor == const Color(0xFF121212)) {
                  _config = _config.copyWith(
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                  );
                } else {
                  _config = _config.copyWith(
                    backgroundColor: const Color(0xFF121212),
                    textColor: Colors.white70,
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

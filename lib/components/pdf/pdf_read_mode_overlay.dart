import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../database/app_database.dart';
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

  // Unified global runtime text cache to prevent layout jank across structural configurations
  final Map<int, List<InlineSpan>> _globalPageCache = <int, List<InlineSpan>>{};

  bool _isInitLoading = true;
  late PdfDocument _pdfDocument;
  Timer? _scrollDebounce;

  @override
  void initState() {
    super.initState();
    _initializePdfAndScroll();
  }

  void _initializePdfAndScroll() {
    try {
      _pdfDocument = PdfDocument(inputBytes: widget.docBytes);
      setState(() => _isInitLoading = false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _jumpToPageImmediate(widget.initialPage - 1);
        _scrollController.addListener(_debouncedScrollListener);
      });
    } catch (e) {
      debugPrint("Error opening PDF structural bytes: $e");
    }
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    _scrollController.removeListener(_debouncedScrollListener);
    _scrollController.dispose();
    _pdfDocument.dispose();
    super.dispose();
  }

  // Throttled tracking logic prevents thread lockup during fast swipes
  void _debouncedScrollListener() {
    if (_scrollDebounce?.isActive ?? false) return;

    _scrollDebounce = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;

      // Calculate current approximate viewport index safely via logical estimate bounds
      double currentOffset = _scrollController.offset;
      double maxScroll = _scrollController.position.maxScrollExtent;

      if (maxScroll <= 0) return;

      int estimatedPage = ((currentOffset / maxScroll) * widget.totalPages)
          .round();
      estimatedPage = estimatedPage.clamp(0, widget.totalPages - 1);

      widget.onPageChanged(estimatedPage + 1);
    });
  }

  void _jumpToPageImmediate(int pageIndex) {
    if (!_scrollController.hasClients || widget.totalPages == 0) return;

    // Smooth layout jump positioning proportional approximation
    final double targetRatio = pageIndex / widget.totalPages;
    final double targetOffset =
        _scrollController.position.maxScrollExtent * targetRatio;

    _scrollController.jumpTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
    );
  }

  void _clearCacheAndRefresh() {
    setState(() {
      _globalPageCache.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = _config.backgroundColor == const Color(0xFF121212);

    return Container(
      color: _config.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            _buildControlBar(isDarkMode),
            Expanded(
              child: _isInitLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: widget.totalPages,
                      cacheExtent:
                          1200, // Pre-allocates pipeline processing to eliminate visual pops
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      itemBuilder: (context, index) {
                        return _ReadModePageItem(
                          index: index,
                          pdfDocument: _pdfDocument,
                          config: _config,
                          annotations: widget.annotations,
                          isDarkMode: isDarkMode,
                          cache: _globalPageCache,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: isDarkMode
          ? Colors.white.withOpacity(0.03)
          : Colors.black.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: _config.textColor),
            onPressed: widget.onClose,
          ),
          IconButton(
            icon: Icon(Icons.text_decrease, color: _config.textColor),
            onPressed: () {
              _config = _config.copyWith(
                fontSize: (_config.fontSize - 1).clamp(12.0, 32.0),
              );
              _clearCacheAndRefresh();
            },
          ),
          IconButton(
            icon: Icon(Icons.text_increase, color: _config.textColor),
            onPressed: () {
              _config = _config.copyWith(
                fontSize: (_config.fontSize + 1).clamp(12.0, 32.0),
              );
              _clearCacheAndRefresh();
            },
          ),
          IconButton(
            icon: Icon(Icons.format_line_spacing, color: _config.textColor),
            onPressed: () {
              double nextSpacing = _config.lineSpacing == 1.2
                  ? 1.6
                  : (_config.lineSpacing == 1.6 ? 2.2 : 1.2);
              _config = _config.copyWith(lineSpacing: nextSpacing);
              _clearCacheAndRefresh();
            },
          ),
          IconButton(
            icon: Icon(Icons.palette, color: _config.textColor),
            onPressed: () {
              if (isDarkMode) {
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
              _clearCacheAndRefresh();
            },
          ),
        ],
      ),
    );
  }
}

// Dedicated internal component decouples page extraction pipelines to ensure smooth UI performance
class _ReadModePageItem extends StatelessWidget {
  final int index;
  final PdfDocument pdfDocument;
  final ReadModeConfig config;
  final List<AnnotationData> annotations;
  final bool isDarkMode;
  final Map<int, List<InlineSpan>> cache;

  const _ReadModePageItem({
    required this.index,
    required this.pdfDocument,
    required this.config,
    required this.annotations,
    required this.isDarkMode,
    required this.cache,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "--- PÁGINA ${index + 1} ---",
                style: TextStyle(
                  color: config.textColor.withOpacity(0.3),
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Evaluates layout processing dynamically via async background task frames
          FutureBuilder<List<InlineSpan>>(
            future: _computeSpansAsynchronous(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !cache.containsKey(index)) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                );
              }

              final displaySpans = cache[index] ?? snapshot.data ?? [];
              if (displaySpans.isEmpty) return const SizedBox.shrink();

              return Text.rich(
                TextSpan(children: displaySpans),
                textAlign: TextAlign.justify,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<InlineSpan>> _computeSpansAsynchronous() async {
    if (cache.containsKey(index)) return cache[index]!;

    List<InlineSpan> spans = [];
    try {
      final List<TextLine> lines = PdfTextExtractor(
        pdfDocument,
      ).extractTextLines(startPageIndex: index, endPageIndex: index);

      if (lines.isEmpty) {
        spans = [
          TextSpan(
            text: "Esta página não possui texto extraível.\n",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: config.fontSize,
            ),
          ),
        ];
        cache[index] = spans;
        return spans;
      }

      final pageNum = index + 1;
      final pageAnnotations = annotations
          .where((a) => a.page == pageNum)
          .toList();
      final RegExp numberedListRegex = RegExp(r'^\d+[\.\)\-]\s');
      final RegExp bulletListRegex = RegExp(r'^([•\-\*◦]|▪|►)\s');

      List<List<TextWord>> paragraphs = [];
      List<TextWord> currentParagraphWords = [];
      double? lastLineY;
      double? lastLineHeight;

      for (int i = 0; i < lines.length; i++) {
        final TextLine currentLine = lines[i];
        final double currentY = currentLine.bounds.top;
        final double currentHeight = currentLine.bounds.height;
        final String lineText = currentLine.text.trimLeft();

        bool isNewListElement =
            numberedListRegex.hasMatch(lineText) ||
            bulletListRegex.hasMatch(lineText);

        if (lastLineY != null && lastLineHeight != null) {
          double lineGap = currentY - (lastLineY + lastLineHeight);
          if (lineGap > currentHeight * 0.85 ||
              isNewListElement ||
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

      if (currentParagraphWords.isNotEmpty) {
        paragraphs.add(currentParagraphWords);
      }

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
          bool endsWithHyphen = wordText.endsWith('-');

          Color textColor = isDarkMode ? Colors.white70 : Colors.black87;
          TextDecoration decoration = TextDecoration.none;
          FontWeight weight = FontWeight.normal;
          FontStyle style = FontStyle.normal;

          if (word.fontStyle.contains(PdfFontStyle.bold))
            weight = FontWeight.bold;
          if (word.fontStyle.contains(PdfFontStyle.italic))
            style = FontStyle.italic;

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
              }
            }
          }

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

        String blockText = words.map((w) => w.text).join(" ").trimLeft();
        bool isListBlock =
            numberedListRegex.hasMatch(blockText) ||
            bulletListRegex.hasMatch(blockText);

        spans.add(
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isListBlock ? 6.0 : 14.0,
                left: isListBlock ? 14.0 : 0.0,
              ),
              child: RichText(
                textAlign: isListBlock ? TextAlign.left : TextAlign.justify,
                text: TextSpan(
                  children: paragraphSpans,
                  style: TextStyle(
                    fontSize: config.fontSize,
                    height: config.lineSpacing,
                    fontFamily: 'serif',
                    color: config.textColor,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      spans.add(
        TextSpan(
          text: "Erro ao extrair texto da página: $e\n",
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    cache[index] = spans;
    return spans;
  }
}

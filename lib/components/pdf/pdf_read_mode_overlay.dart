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
  late ReadModeConfig _config;
  bool _isConfigInitialized = false;

  final Map<int, List<InlineSpan>> _globalPageCache = <int, List<InlineSpan>>{};

  bool _isInitLoading = true;
  late PdfDocument _pdfDocument;
  Timer? _scrollDebounce;

  @override
  void initState() {
    super.initState();
    _initializePdfAndScroll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isConfigInitialized) {
      _config = ReadModeConfig.fromContext(context);
      _isConfigInitialized = true;
    }
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

  void _debouncedScrollListener() {
    if (_scrollDebounce?.isActive ?? false) return;

    _scrollDebounce = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;

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
    final bool isDarkMode =
        ThemeData.estimateBrightnessForColor(_config.backgroundColor) ==
        Brightness.dark;

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
                      cacheExtent: 1200,
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
          ? Colors.white.withOpacity(0.05)
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
                  backgroundColor: const Color(0xFFF1F1F1),
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

  String _cleanPdfText(String text) {
    if (text.isEmpty) return text;

    String s = text;

    // 0. Normalização de caracteres especiais e cedilhas Unicode combinantes
    s = s.replaceAll('ı', 'i');
    s = s.replaceAll(RegExp(r'c[\u0327¸]'), 'ç');
    s = s.replaceAll(RegExp(r'C[\u0327¸]'), 'Ç');

    // 1. Cedilha + Til combinados (ex: "Criac , ~ ao" -> "Criação")
    s = s.replaceAll(
      RegExp(r"c\s*[,¸\u0327]\s*[\~˜]\s*ao", caseSensitive: false),
      'ção',
    );
    s = s.replaceAll(
      RegExp(r"c\s*[,¸\u0327]\s*[\~˜]\s*a", caseSensitive: false),
      'çã',
    );
    s = s.replaceAll(
      RegExp(r"c\s*[,¸\u0327]\s*[\~˜]\s*o", caseSensitive: false),
      'çõ',
    );

    // 2. Cedilha simples substituindo c + vírgula/cedilha (ex: "c,a", "c , a" -> "ça")
    s = s.replaceAll(RegExp(r"c\s*[,¸\u0327]\s*a", caseSensitive: false), 'ça');
    s = s.replaceAll(RegExp(r"c\s*[,¸\u0327]\s*e", caseSensitive: false), 'çe');
    s = s.replaceAll(RegExp(r"c\s*[,¸\u0327]\s*i", caseSensitive: false), 'çi');
    s = s.replaceAll(RegExp(r"c\s*[,¸\u0327]\s*o", caseSensitive: false), 'ço');
    s = s.replaceAll(RegExp(r"c\s*[,¸\u0327]\s*u", caseSensitive: false), 'çu');
    s = s.replaceAll(RegExp(r"c\s*[,¸\u0327]\s*", caseSensitive: false), 'ç');

    // 3. Unir 'ç' que tenha ficado separado da palavra (ex: "Fran ç a" -> "França")
    s = s.replaceAllMapped(
      RegExp(r"([a-zA-Zà-úÀ-Ú])\s+ç\s+([a-zA-Zà-úÀ-Ú])"),
      (m) => "${m[1]}ç${m[2]}",
    );
    s = s.replaceAllMapped(
      RegExp(r"([a-zA-Zà-úÀ-Ú])\s+ç([a-zA-Zà-úÀ-Ú])"),
      (m) => "${m[1]}ç${m[2]}",
    );
    s = s.replaceAllMapped(RegExp(r"ç\s+([a-zA-Zà-úÀ-Ú])"), (m) => "ç${m[1]}");

    // 4. Crase isolada (ex: "` a" -> "à")
    s = s.replaceAll(RegExp(r'`\s*a'), 'à');
    s = s.replaceAll(RegExp(r'`\s*A'), 'À');

    // 5. Til (~ / ˜) isolado (ex: "Jo ˜ ao" -> "João")
    s = s.replaceAll(RegExp(r'[\~˜]\s*ao'), 'ão');
    s = s.replaceAll(RegExp(r'[\~˜]\s*a'), 'ã');
    s = s.replaceAll(RegExp(r'[\~˜]\s*o'), 'õ');
    s = s.replaceAll(RegExp(r'[\~˜]\s*AO'), 'ÃO');
    s = s.replaceAll(RegExp(r'[\~˜]\s*A'), 'Ã');
    s = s.replaceAll(RegExp(r'[\~˜]\s*O'), 'Õ');

    // 6. Circunflexo (^ / ˆ) isolado (ex: "Acad ˆ emicos" -> "Acadêmicos")
    s = s.replaceAll(RegExp(r'[\^ˆ]\s*a'), 'â');
    s = s.replaceAll(RegExp(r'[\^ˆ]\s*e'), 'ê');
    s = s.replaceAll(RegExp(r'[\^ˆ]\s*i'), 'î');
    s = s.replaceAll(RegExp(r'[\^ˆ]\s*o'), 'ô');
    s = s.replaceAll(RegExp(r'[\^ˆ]\s*u'), 'û');
    s = s.replaceAll(RegExp(r'[\^ˆ]\s*A'), 'Â');
    s = s.replaceAll(RegExp(r'[\^ˆ]\s*E'), 'Ê');
    s = s.replaceAll(RegExp(r'[\^ˆ]\s*I'), 'Î');
    s = s.replaceAll(RegExp(r'[\^ˆ]\s*O'), 'Ô');
    s = s.replaceAll(RegExp(r'[\^ˆ]\s*U'), 'Û');

    // 7. Agudo (´ / ') isolado (ex: "Jacare ´ i" -> "Jacareí", "Am ´ erica" -> "América")
    s = s.replaceAll(RegExp(r"[\´']\s*a"), 'á');
    s = s.replaceAll(RegExp(r"[\´']\s*e"), 'é');
    s = s.replaceAll(RegExp(r"[\´']\s*i"), 'í');
    s = s.replaceAll(RegExp(r"[\´']\s*o"), 'ó');
    s = s.replaceAll(RegExp(r"[\´']\s*u"), 'ú');
    s = s.replaceAll(RegExp(r"[\´']\s*A"), 'Á');
    s = s.replaceAll(RegExp(r"[\´']\s*E"), 'É');
    s = s.replaceAll(RegExp(r"[\´']\s*I"), 'Í');
    s = s.replaceAll(RegExp(r"[\´']\s*O"), 'Ó');
    s = s.replaceAll(RegExp(r"[\´']\s*U"), 'Ú');

    // Separar palavras em CamelCase grudadas
    s = s.replaceAllMapped(
      RegExp(r'([a-zàáâãéêíóôõúç])([A-ZÀÁÂÃÉÊÍÓÔÕÚÇ])'),
      (m) => '${m[1]} ${m[2]}',
    );

    // Corrigir preposições grudadas (ex: "FogaçadeAlmeida" -> "Fogaça de Almeida")
    s = s.replaceAllMapped(
      RegExp(
        r'([a-zàáâãéêíóôõúç]{2,})(de|da|do|dos|das|em|no|na)([A-ZÀÁÂÃÉÊÍÓÔÕÚÇ])',
      ),
      (m) => '${m[1]} ${m[2]} ${m[3]}',
    );

    // Corrigir maiúsculas isoladas (ex: "V oltado" -> "Voltado")
    s = s.replaceAllMapped(
      RegExp(r'\b([A-Z])\s+([a-zàáâãéêíóôõúç]{2,})\b'),
      (m) => '${m[1]}${m[2]}',
    );

    // Remover espaços antes de pontuações
    s = s.replaceAllMapped(RegExp(r'\s+([,\.])'), (m) => '${m[1]}');

    // Normalizar espaços duplicados
    s = s.replaceAll(RegExp(r' {2,}'), ' ');

    return s.trim();
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

      List<String> rawParagraphs = [];
      StringBuffer currentParagraph = StringBuffer();
      double? lastLineY;
      double? lastLineHeight;

      for (int i = 0; i < lines.length; i++) {
        final TextLine currentLine = lines[i];
        final double currentY = currentLine.bounds.top;
        final double currentHeight = currentLine.bounds.height;
        final String lineText = currentLine.text.trim();

        bool isNewListElement =
            numberedListRegex.hasMatch(lineText) ||
            bulletListRegex.hasMatch(lineText);

        if (lastLineY != null && lastLineHeight != null) {
          double lineGap = currentY - (lastLineY + lastLineHeight);
          if (lineGap > currentHeight * 0.85 ||
              isNewListElement ||
              lineText.isEmpty) {
            if (currentParagraph.isNotEmpty) {
              rawParagraphs.add(currentParagraph.toString());
              currentParagraph.clear();
            }
          }
        }

        if (lineText.isNotEmpty) {
          if (currentParagraph.isNotEmpty) {
            currentParagraph.write(' ');
          }
          currentParagraph.write(lineText);
        }

        lastLineY = currentY;
        lastLineHeight = currentHeight;
      }

      if (currentParagraph.isNotEmpty) {
        rawParagraphs.add(currentParagraph.toString());
      }

      for (int p = 0; p < rawParagraphs.length; p++) {
        String cleanParagraphText = _cleanPdfText(rawParagraphs[p]);
        if (cleanParagraphText.isEmpty) continue;

        List<String> words = cleanParagraphText.split(RegExp(r'\s+'));
        List<TextSpan> paragraphSpans = [];

        for (int w = 0; w < words.length; w++) {
          String wordText = words[w];
          bool endsWithHyphen = wordText.endsWith('-');

          Color textColor = isDarkMode ? Colors.white70 : Colors.black87;
          TextDecoration decoration = TextDecoration.none;
          FontWeight weight = FontWeight.normal;
          FontStyle style = FontStyle.normal;

          for (var annotation in pageAnnotations) {
            if (annotation.content != null &&
                annotation.content!.isNotEmpty &&
                wordText.toLowerCase().contains(
                  annotation.content!.toLowerCase(),
                )) {
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

        bool isListBlock =
            numberedListRegex.hasMatch(cleanParagraphText) ||
            bulletListRegex.hasMatch(cleanParagraphText);

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

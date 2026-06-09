import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../database/app_database.dart';

mixin PdfAnnotationManager<T extends StatefulWidget> on State<T> {
  List<PdfTextLine> parseRectsToTextLines(String rectsJson, int page) {
    final List<dynamic> rects = jsonDecode(rectsJson);
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
          page,
        ),
      );
    }
    return textLines;
  }

  void applyAnnotationsToController({
    required PdfViewerController controller,
    required List<AnnotationData> annotations,
  }) {
    controller.removeAllAnnotations();

    for (var annotation in annotations) {
      try {
        final List<dynamic> rects = jsonDecode(annotation.rectsJson);

        if (annotation.type == 'sticky_note') {
          final Offset position = Offset(
            (rects[0]['left'] as num).toDouble(),
            (rects[0]['top'] as num).toDouble(),
          );

          controller.addAnnotation(StickyNoteAnnotation(
            position: position,
            pageNumber: annotation.page,
            text: annotation.content ?? "",
            icon: PdfStickyNoteIcon.comment,
          ));
          continue;
        }

        final textLines = parseRectsToTextLines(annotation.rectsJson, annotation.page);

        if (textLines.isNotEmpty) {
          if (annotation.type == 'underline') {
            controller.addAnnotation(UnderlineAnnotation(textBoundsCollection: textLines)..color = Colors.red);
          } else if (annotation.type == 'note') {
            controller.addAnnotation(UnderlineAnnotation(textBoundsCollection: textLines)..color = Colors.blue);
          } else {
            controller.addAnnotation(HighlightAnnotation(textBoundsCollection: textLines)
              ..color = Colors.yellow
              ..opacity = 0.5);
          }
        }
      } catch (e) {
        debugPrint("Failed parsing layout geometry: $e");
      }
    }
  }
}
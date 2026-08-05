import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfTextSelectionToolbar extends StatelessWidget {
  final PdfTextSelectionChangedDetails selectionDetails;
  final VoidCallback onHighlightPressed;
  final VoidCallback onUnderlinePressed;

  const PdfTextSelectionToolbar({
    super.key,
    required this.selectionDetails,
    required this.onHighlightPressed,
    required this.onUnderlinePressed,
  });

  @override
  Widget build(BuildContext context) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final Offset localOffset = renderBox != null
        ? renderBox.globalToLocal(selectionDetails.globalSelectedRegion!.topCenter)
        : selectionDetails.globalSelectedRegion!.topCenter;

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
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          width: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.border_color, color: Colors.yellow, size: 20),
                tooltip: "Highlight",
                onPressed: onHighlightPressed,
              ),
              IconButton(
                icon: const Icon(Icons.format_underlined, color: Colors.white, size: 20),
                tooltip: "Underline",
                onPressed: onUnderlinePressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
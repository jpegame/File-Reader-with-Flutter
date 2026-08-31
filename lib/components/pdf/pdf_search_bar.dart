import 'package:flutter/material.dart';

class PdfSearchBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onPrevMatch;
  final VoidCallback onNextMatch;
  final VoidCallback onClose;

  const PdfSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onPrevMatch,
    required this.onNextMatch,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color:
          Theme.of(context).appBarTheme.backgroundColor ?? colorScheme.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: true,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "Procurar palavra",
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  fillColor: colorScheme.surfaceContainerHighest,
                  filled: true,
                  isDense: true,
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: onChanged,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: Colors.white,
              ),
              onPressed: onPrevMatch,
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: Colors.white,
              ),
              onPressed: onNextMatch,
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

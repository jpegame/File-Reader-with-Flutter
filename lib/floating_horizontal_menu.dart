import 'package:flutter/material.dart';

class FloatingHorizontalMenu extends StatefulWidget {
  final List<Widget> children;
  final Duration animationDuration;
  final IconData icon;
  final Object? heroTag;

  const FloatingHorizontalMenu({
    super.key,
    required this.children,
    this.animationDuration = const Duration(milliseconds: 250),
    this.icon = Icons.menu,
    this.heroTag,
  });

  @override
  State<FloatingHorizontalMenu> createState() => _FloatingHorizontalMenuState();
}

class _FloatingHorizontalMenuState extends State<FloatingHorizontalMenu> {
  bool _isOpen = false;

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: widget.heroTag,
          onPressed: _toggleMenu,
          child: Icon(_isOpen ? Icons.close : widget.icon),
        ),

        AnimatedContainer(
          duration: widget.animationDuration,
          curve: Curves.easeInOut,
          width: _isOpen ? (widget.children.length * 48.0) : 0,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.children
                  .map(
                    (child) => Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: child,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

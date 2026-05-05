import 'package:flutter/material.dart';

class FloatingHorizontalMenu extends StatefulWidget {
  final List<Widget> children;
  final Duration animationDuration;
  final IconData icon;

  const FloatingHorizontalMenu({
    super.key,
    required this.children,
    this.animationDuration = const Duration(milliseconds: 250),
    this.icon = Icons.menu,
  });

  @override
  _FloatingHorizontalMenuState createState() => _FloatingHorizontalMenuState();
}

class _FloatingHorizontalMenuState extends State<FloatingHorizontalMenu>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget mainButton() {
      return SizedBox(
        width: 48,
        height: 48,
        child: Material(
          color: Theme.of(context).colorScheme.primary,
          shape: const CircleBorder(),
          elevation: 6,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _toggleMenu,
            child: Icon(widget.icon, color: Colors.white, size: 22),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mainButton(),

        AnimatedContainer(
          duration: widget.animationDuration,
          curve: Curves.easeInOut,
          width: _isOpen ? (widget.children.length * 56.0) : 0,
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

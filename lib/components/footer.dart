import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const Footer({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        NavigationDestination(
          icon: Icon(Icons.edit_document),
          label: "Inserir",
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: "Configurações",
        ),
        NavigationDestination(
          icon: Icon(Icons.warning),
          label: "DEBUG PDF",
        ),
      ],
    );
  }
}
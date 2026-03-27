import 'package:flutter/material.dart';
import 'components/header.dart';
import 'components/footer.dart';
import 'home.dart';
import 'upload_file_page.dart';
import 'config_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Aplicativo de teste",
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),

      home: MainAppPage(onToggleTheme: _toggleTheme),
    );
  }
}

class MainAppPage extends StatefulWidget  {
  final VoidCallback onToggleTheme;

  const MainAppPage({super.key, required this.onToggleTheme});

  @override
  State<MainAppPage> createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      const HomePage(),
      const UploadFilePage(),
      ConfigPage(
        isDarkMode: isDarkMode,
        onThemeChanged: (_) => widget.onToggleTheme(),
      ),
    ];
    return Scaffold(
      appBar: Header(title: "Aplicativo teste", onToggleTheme:  widget.onToggleTheme),
      body: pages[_currentIndex],
      bottomNavigationBar: Footer(currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        }),
    );
  }
}

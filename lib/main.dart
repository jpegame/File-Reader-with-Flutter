import 'package:flutter/material.dart';
import 'components/header.dart';
import 'components/footer.dart';
import 'home.dart';
import 'upload_file_page.dart';
import 'config_page.dart';

void main() {
  runApp(const MainApp());
}

const MaterialColor deepSea = MaterialColor(
  0xFF0ABF91, // base (500)
  <int, Color>{
    50: Color(0xFFEBFEF7),
    100: Color(0xFFD0FBE8),
    200: Color(0xFFA4F6D7),
    300: Color(0xFF6AEBC2),
    400: Color(0xFF2FD8A8),
    500: Color(0xFF0ABF91), // 👈 principal
    600: Color(0xFF009B77),
    700: Color(0xFF008368),
    800: Color(0xFF03624F),
    900: Color(0xFF045042),
  },
);

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0ABF91)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF008368),
          foregroundColor: Colors.white,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: deepSea,
          brightness: Brightness.dark,
        ).copyWith(primary: deepSea[300], secondary: deepSea[200]),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: deepSea[700],
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850], // Fundo do input (tchau, branco!)
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: deepSea[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: deepSea[400]!, width: 2),
          ),
          labelStyle: TextStyle(color: deepSea[100]),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),

      home: MainAppPage(onToggleTheme: _toggleTheme),
    );
  }
}

class MainAppPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const MainAppPage({super.key, required this.onToggleTheme});

  @override
  State<MainAppPage> createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      const HomePage(),
      const UploadFilePage(),
      ConfigPage(
        isDarkMode: isDarkMode,
        onThemeChanged: (_) => widget.onToggleTheme(),
      ),
    ];
    return Scaffold(
      appBar: Header(
        title: "Aplicativo teste",
        onToggleTheme: widget.onToggleTheme,
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: Footer(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

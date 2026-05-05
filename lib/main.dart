import 'package:flutter/material.dart';
import 'components/header.dart';
import 'components/footer.dart';
import 'home.dart';
import 'config_page.dart';
import 'insert_page.dart';
import 'database/app_database.dart';

void main() {
  runApp(const MainApp());
}

const MaterialColor appColorTheme = MaterialColor(
  0xFF3FA851,
  <int, Color>{
    50: Color(0xFFF2FBF3),
    100: Color(0xFFE2F6E5),
    200: Color(0xFFC6ECCC),
    300: Color(0xFF98DDA4),
    400: Color(0xFF64C475),
    500: Color(0xFF3FA851),
    600: Color(0xFF349A46),
    700: Color(0xFF286D35),
    800: Color(0xFF24572E),
    900: Color(0xFF1F4827),
  },
);

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.light;
  late final AppDatabase _database;

  Future<void> _loadThemeSettings() async {
    try {
      final themeConfig = await _database.configDao.getValue('dark_mode');
      if (themeConfig != null) {
        setState(() {
          _themeMode = themeConfig == 'true' 
              ? ThemeMode.dark 
              : ThemeMode.light;
        });
      }
    } catch (e) {
      debugPrint("Error loading theme: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _database = AppDatabase();
    _loadThemeSettings();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

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
      title: "File Reader",
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: appColorTheme[500]!),
        appBarTheme: AppBarTheme(
          backgroundColor: appColorTheme[600]!,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: appColorTheme[100],
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1A14),
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: appColorTheme[400]!,
          onPrimary: Colors.black,
          secondary: appColorTheme[300]!,
          onSecondary: Colors.black,
          surface: const Color(0xFF16241C),
          onSurface: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: appColorTheme[700],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: appColorTheme[900],
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: appColorTheme[500],
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1B2B22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: appColorTheme[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: const Color(0xFF2A3D33)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: appColorTheme[300]!, width: 2),
          ),
          labelStyle: TextStyle(color: appColorTheme[200]),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
      home: MainAppPage(
        onToggleTheme: _toggleTheme, 
        database: _database
      ),
    );
  }
}

class MainAppPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final AppDatabase database;

  const MainAppPage({
    super.key, 
    required this.onToggleTheme, 
    required this.database
  });

  @override
  State<MainAppPage> createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      HomePage(db: widget.database),
      InsertPage(db: widget.database),
      ConfigPage(
        isDarkMode: isDarkMode,
        onThemeChanged: (_) => widget.onToggleTheme(),
        db: widget.database,
      ),
    ];

    return Scaffold(
      appBar: Header(title: "File Reader"),
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
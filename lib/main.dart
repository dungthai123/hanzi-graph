import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_initializer.dart';
import 'providers/data_provider.dart';
import 'providers/search_provider.dart';
import 'providers/graph_provider.dart';
import 'ui/screens/main_screen.dart';

void main() {
  runApp(const HanziGraphApp());
}

class HanziGraphApp extends StatefulWidget {
  const HanziGraphApp({super.key});

  @override
  State<HanziGraphApp> createState() => _HanziGraphAppState();
}

class _HanziGraphAppState extends State<HanziGraphApp> {
  AppInitializer? _appInitializer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final appInitializer = AppInitializer();
      await appInitializer.initialize();
      setState(() {
        _appInitializer = appInitializer;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        title: 'HanziGraph',
        theme: _buildResponsiveTheme(),
        home: Scaffold(
          backgroundColor: const Color(0xFFFCFCFC), // --background-color
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(0xFF6A82FB), // --secondary-inactive-accent-color
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '汉',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'serif',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'HanziGraph',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0x87000000), // --primary-font-color
                  ),
                ),
                SizedBox(height: 16),
                CircularProgressIndicator(color: Color(0xFF6A82FB), strokeWidth: 3),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(fontSize: 16, color: Color(0x87000000), fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return MaterialApp(
        title: 'HanziGraph',
        theme: _buildResponsiveTheme(),
        home: Scaffold(
          backgroundColor: const Color(0xFFFCFCFC),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                const Text('Failed to initialize app', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(fontSize: 14, color: Colors.grey[600]), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _initializeApp();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final appInitializer = _appInitializer!;

    return MultiProvider(
      providers: [
        Provider<DataProvider>(create: (_) => DataProvider(appInitializer.dataService)),
        ChangeNotifierProvider(
          create: (_) {
            final searchProvider = SearchProvider();
            searchProvider.initialize(appInitializer.dataService);
            return searchProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final graphProvider = GraphProvider();
            final dataProvider = context.read<DataProvider>();
            graphProvider.initialize(appInitializer.graphService, appInitializer.dataService, dataProvider);
            return graphProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'HanziGraph',
        theme: _buildResponsiveTheme(),
        home: MainScreen(appInitializer: appInitializer),
      ),
    );
  }

  /// Build responsive theme following HTML/CSS design patterns
  ThemeData _buildResponsiveTheme() {
    return ThemeData(
      useMaterial3: true,

      // Color scheme based on CSS variables
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF6A82FB), // --secondary-inactive-accent-color
        onPrimary: Colors.white,
        secondary: Color(0xFFD56EAF), // --secondary-accent-color
        onSecondary: Colors.white,
        error: Color(0xFFFF635F), // --tone-1-color
        onError: Colors.white, // --primary-font-color
        surface: Color(0xFFF8F8F8), // --header-background-color
        onSurface: Color(0x87000000),
      ),

      // Typography following CSS font patterns
      textTheme: const TextTheme(
        // Headers
        headlineLarge: TextStyle(
          fontSize: 50, // --walkthrough-header-font-size (desktop)
          fontWeight: FontWeight.bold,
          color: Color(0x87000000),
          fontFamily: 'Times, serif', // --header-font-family
        ),
        headlineMedium: TextStyle(
          fontSize: 30, // --primary-header-font-size
          fontWeight: FontWeight.bold,
          color: Color(0x87000000),
        ),
        headlineSmall: TextStyle(
          fontSize: 22, // --tertiary-header-font-size
          fontWeight: FontWeight.w500,
          color: Color(0x87000000),
        ),

        // Body text
        bodyLarge: TextStyle(
          fontSize: 16, // --instructions-font-size
          fontWeight: FontWeight.w300, // --primary-font-weight
          color: Color(0x87000000),
          fontFamily: 'Roboto, Helvetica, Arial, sans-serif', // --primary-font
        ),
        bodyMedium: TextStyle(
          fontSize: 14, // --base-language-font-size
          fontWeight: FontWeight.w300,
          color: Color(0x87000000),
        ),

        // Chinese characters
        displayLarge: TextStyle(
          fontSize: 24, // --target-language-font-size
          fontWeight: FontWeight.w400, // --target-language-font-weight
          color: Color(0x87000000),
        ),
        displayMedium: TextStyle(
          fontSize: 20, // --target-language-secondary-font-size
          fontWeight: FontWeight.w400,
          color: Color(0x87000000),
        ),

        // Search
        titleMedium: TextStyle(
          fontSize: 20, // --search-font-size
          fontWeight: FontWeight.w300,
          color: Color(0x87000000),
        ),
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8F8F8), // --header-background-color
        foregroundColor: Color(0x87000000),
        elevation: 0,
        toolbarHeight: 50, // --primary-header-height
      ),

      // Bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFF8F8F8),
        selectedItemColor: Color(0xFF6A82FB),
        unselectedItemColor: Color(0xFF777777), // --inactive-accent-color
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Input decoration
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFFFFFFF), // --input-background-color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0x33333333)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0x33333333)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF6A82FB), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Card theme
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shadowColor: const Color(0x1A000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6DE200), // --positive-button-color
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFCFCFC),
        foregroundColor: Colors.black,
        elevation: 6,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0x33333333), // --border equivalent
        thickness: 1,
      ),

      // Extensions for responsive breakpoints
      extensions: <ThemeExtension<dynamic>>[
        ResponsiveTheme(
          mobileBreakpoint: 664.0,
          tabletBreakpoint: 1024.0,
          mobileTextScale: 0.9,
          tabletTextScale: 1.0,
          desktopTextScale: 1.1,
        ),
      ],
    );
  }
}

/// Custom theme extension for responsive design
class ResponsiveTheme extends ThemeExtension<ResponsiveTheme> {
  final double mobileBreakpoint;
  final double tabletBreakpoint;
  final double mobileTextScale;
  final double tabletTextScale;
  final double desktopTextScale;

  const ResponsiveTheme({
    required this.mobileBreakpoint,
    required this.tabletBreakpoint,
    required this.mobileTextScale,
    required this.tabletTextScale,
    required this.desktopTextScale,
  });

  @override
  ResponsiveTheme copyWith({
    double? mobileBreakpoint,
    double? tabletBreakpoint,
    double? mobileTextScale,
    double? tabletTextScale,
    double? desktopTextScale,
  }) {
    return ResponsiveTheme(
      mobileBreakpoint: mobileBreakpoint ?? this.mobileBreakpoint,
      tabletBreakpoint: tabletBreakpoint ?? this.tabletBreakpoint,
      mobileTextScale: mobileTextScale ?? this.mobileTextScale,
      tabletTextScale: tabletTextScale ?? this.tabletTextScale,
      desktopTextScale: desktopTextScale ?? this.desktopTextScale,
    );
  }

  @override
  ResponsiveTheme lerp(ThemeExtension<ResponsiveTheme>? other, double t) {
    if (other is! ResponsiveTheme) {
      return this;
    }
    return ResponsiveTheme(
      mobileBreakpoint: mobileBreakpoint,
      tabletBreakpoint: tabletBreakpoint,
      mobileTextScale: mobileTextScale,
      tabletTextScale: tabletTextScale,
      desktopTextScale: desktopTextScale,
    );
  }

  double getTextScale(double screenWidth) {
    if (screenWidth <= mobileBreakpoint) {
      return mobileTextScale;
    } else if (screenWidth <= tabletBreakpoint) {
      return tabletTextScale;
    } else {
      return desktopTextScale;
    }
  }
}

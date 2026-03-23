import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toeic_apps/pages/auth_page.dart';
import 'package:toeic_apps/pages/homepage.dart';
import 'package:toeic_apps/pages/me_page.dart';
import 'package:toeic_apps/pages/mock_test_page.dart';
import 'package:toeic_apps/pages/practice_page.dart';
import 'package:toeic_apps/pages/settings_page.dart';
import 'package:toeic_apps/pages/vocabulary_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Supabase.initialize(
    url: 'https://xnaeiwkbtzpxpghyqpjb.supabase.co',
    anonKey: 'sb_publishable_Jc0A28bEaJnE4YyAFI3PEw_Wz0GPaR2',
  );

  runApp(const MyApp());
}

// ── Design Tokens ────────────────────────────────────────────────────
const kPrimary = Color(0xFF4647D3);
const kPrimaryContainer = Color(0xFF9396FF);
const kSecondary = Color(0xFF006947);
const kSurface = Color(0xFFF4F6FF);
const kSurfaceContainer = Color(0xFFE0E8FC);
const kSurfaceContainerLow = Color(0xFFF0F4FF);
const kSurfaceContainerLowest = Color(0xFFFFFFFF);
const kSurfaceDim = Color(0xFFCAD5EC);
const kOnSurface = Color(0xFF282F3B);
const kOutline = Color(0xFF6E7587);
const kOutlineVariant = Color(0xFFA6ADBC);
// ─────────────────────────────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOEIC Master',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        MePage.routeName: (_) => const MePage(),
        AuthPage.routeName: (_) => const AuthPage(),
        VocabularyPage.routeName: (_) => const VocabularyPage(),
        PracticePage.routeName: (_) => const PracticePage(),
        MockTestPage.routeName: (_) => const MockTestPage(),
        SettingsPage.routeName: (_) => const SettingsPage(),
      },
    );
  }

  ThemeData _buildTheme() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: kPrimary,
      onPrimary: Colors.white,
      primaryContainer: kPrimaryContainer,
      onPrimaryContainer: const Color(0xFF00006E),
      secondary: kSecondary,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFF89F8C7),
      onSecondaryContainer: const Color(0xFF002116),
      tertiary: const Color(0xFF6B5778),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFF2DAFF),
      onTertiaryContainer: const Color(0xFF251432),
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: kSurface,
      onSurface: kOnSurface,
      surfaceContainerHighest: kSurfaceContainer,
      surfaceContainerHigh: const Color(0xFFE8EEFF),
      surfaceContainer: const Color(0xFFECF0FA),
      surfaceContainerLow: kSurfaceContainerLow,
      surfaceContainerLowest: kSurfaceContainerLowest,
      surfaceDim: kSurfaceDim,
      surfaceBright: kSurface,
      outline: kOutline,
      outlineVariant: kOutlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: kOnSurface,
      onInverseSurface: const Color(0xFFF0F0FF),
      inversePrimary: const Color(0xFFBEC2FF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: kSurface,

      appBarTheme: AppBarTheme(
        backgroundColor: kSurface.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: kOnSurface,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: kOnSurface,
          letterSpacing: -0.5,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: kSurfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        margin: EdgeInsets.zero,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurfaceContainerLow,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
        ),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: kOutline,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: kPrimary,
        unselectedItemColor: kOutline,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: kOutlineVariant.withValues(alpha: 0.25),
        space: 0,
        thickness: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: kOnSurface,
        contentTextStyle: const TextStyle(
          color: Color(0xFFF0F0FF),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }
}

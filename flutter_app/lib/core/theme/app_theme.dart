import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Palette ───────────────────────────────────────────────
  static const primary      = Color(0xFF1C3566); // Royal navy
  static const gold         = Color(0xFFC9A84C); // Antique gold
  static const goldLight    = Color(0xFFF5E6B8);
  static const red          = Color(0xFFCF2B2B); // Tricolour red
  static const _primaryDark = Color(0xFF5B8AFF);
  static const surfaceLight = Color(0xFFF7F4EE); // Warm parchment
  static const surfaceDark  = Color(0xFF111828);
  static const cardLight    = Color(0xFFFFFFFF);
  static const cardDark     = Color(0xFF1C2540);

  // ── CEFR colours ──────────────────────────────────────────
  static const cefrColors = {
    'A1': Color(0xFF4CAF50),
    'A2': Color(0xFF8BC34A),
    'B1': Color(0xFFFFC107),
    'B2': Color(0xFFFF9800),
    'C1': Color(0xFFFF5722),
    'C2': Color(0xFF9C27B0),
  };

  static const qualityColors = {
    'again': Color(0xFFE53935),
    'hard':  Color(0xFFFF8F00),
    'good':  Color(0xFF43A047),
    'easy':  Color(0xFF1E88E5),
  };

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme  => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness:  brightness,
      primary:     isDark ? _primaryDark : primary,
      onPrimary:   Colors.white,
      secondary:   gold,
      onSecondary: Colors.white,
      tertiary:    red,
      onTertiary:  Colors.white,
      error:       const Color(0xFFB00020),
      onError:     Colors.white,
      surface:     isDark ? surfaceDark : surfaceLight,
      onSurface:   isDark ? const Color(0xFFEAE8E0) : const Color(0xFF1A1C2C),
    );

    final textTheme = GoogleFonts.latoTextTheme().copyWith(
      displayLarge:   GoogleFonts.playfairDisplay(fontSize: 36, fontWeight: FontWeight.w700, color: isDark ? Colors.white : primary),
      displayMedium:  GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w600, color: isDark ? Colors.white : primary),
      headlineLarge:  GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w600, color: isDark ? Colors.white : primary),
      headlineMedium: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w600, color: isDark ? Colors.white : primary),
      titleLarge:     GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w700),
      titleMedium:    GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall:     GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge:      GoogleFonts.lato(fontSize: 16, height: 1.6),
      bodyMedium:     GoogleFonts.lato(fontSize: 14, height: 1.5),
      bodySmall:      GoogleFonts.lato(fontSize: 12, height: 1.4),
      labelLarge:     GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.8),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme:  colorScheme,
      textTheme:    textTheme,
      scaffoldBackgroundColor: isDark ? surfaceDark : surfaceLight,

      cardTheme: CardTheme(
        color:     isDark ? cardDark : cardLight,
        elevation: isDark ? 0 : 2,
        shadowColor: primary.withAlpha(25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? cardDark : cardLight,
        foregroundColor: isDark ? Colors.white : primary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: primary.withAlpha(20),
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : primary,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? _primaryDark : primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? _primaryDark : primary,
          side: BorderSide(color: isDark ? _primaryDark : primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? cardDark : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFDDD8CE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFDDD8CE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gold, width: 2),
        ),
        labelStyle: GoogleFonts.lato(color: isDark ? Colors.white54 : const Color(0xFF6B6560)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? cardDark : cardLight,
        indicatorColor:  gold.withAlpha(35),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(color: isDark ? gold : primary, size: 22);
          }
          return IconThemeData(color: isDark ? Colors.white38 : const Color(0xFF9E9890), size: 22);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.w700,
                color: isDark ? gold : primary);
          }
          return GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.w500,
              color: isDark ? Colors.white38 : const Color(0xFF9E9890));
        }),
        height: 68,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: isDark ? Colors.white10 : const Color(0xFFEDE9E0),
        selectedColor: isDark ? primary.withAlpha(180) : primary,
        labelStyle: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        side: BorderSide.none,
      ),

      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white10 : const Color(0xFFE8E3D8),
        thickness: 1,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Brand palette ─────────────────────────────────────────
  static const _primary      = Color(0xFF1A5CFF);   // French blue
  static const _primaryDark  = Color(0xFF4C8AFF);
  static const _secondary    = Color(0xFFE8003D);   // Tricolour red
  static const _tertiary     = Color(0xFF00A36C);   // Success green
  static const _surfaceLight = Color(0xFFF6F7FB);
  static const _surfaceDark  = Color(0xFF1A1C2C);
  static const _cardLight    = Color(0xFFFFFFFF);
  static const _cardDark     = Color(0xFF252840);

  // ── CEFR level colours ────────────────────────────────────
  static const cefrColors = {
    'A1': Color(0xFF4CAF50),
    'A2': Color(0xFF8BC34A),
    'B1': Color(0xFFFFC107),
    'B2': Color(0xFFFF9800),
    'C1': Color(0xFFFF5722),
    'C2': Color(0xFF9C27B0),
  };

  // ── Review quality colours ────────────────────────────────
  static const qualityColors = {
    'again': Color(0xFFE53935),
    'hard':  Color(0xFFFF8F00),
    'good':  Color(0xFF43A047),
    'easy':  Color(0xFF1E88E5),
  };

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme  => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness:     brightness,
      primary:        isDark ? _primaryDark : _primary,
      onPrimary:      Colors.white,
      secondary:      _secondary,
      onSecondary:    Colors.white,
      tertiary:       _tertiary,
      onTertiary:     Colors.white,
      error:          const Color(0xFFB00020),
      onError:        Colors.white,
      surface:        isDark ? _surfaceDark : _surfaceLight,
      onSurface:      isDark ? Colors.white : const Color(0xFF1A1C2C),
    );

    final textTheme = GoogleFonts.interTextTheme().copyWith(
      displayLarge:  GoogleFonts.spectral(fontSize: 36, fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.spectral(fontSize: 28, fontWeight: FontWeight.w600),
      headlineMedium:GoogleFonts.spectral(fontSize: 22, fontWeight: FontWeight.w600),
      titleLarge:    GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium:   GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge:     GoogleFonts.inter(fontSize: 16),
      bodyMedium:    GoogleFonts.inter(fontSize: 14),
      labelLarge:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600,
                       letterSpacing: 0.5),
    );

    return ThemeData(
      useMaterial3:  true,
      colorScheme:   colorScheme,
      textTheme:     textTheme,
      scaffoldBackgroundColor: isDark ? _surfaceDark : _surfaceLight,

      // Cards
      cardTheme: CardTheme(
        color:     isDark ? _cardDark : _cardLight,
        elevation: 0,
        shape:     RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? _cardDark : _cardLight,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1A1C2C),
        elevation:       0,
        centerTitle:     true,
        titleTextStyle:  GoogleFonts.inter(
          fontSize:   18,
          fontWeight: FontWeight.w600,
          color:      isDark ? Colors.white : const Color(0xFF1A1C2C),
        ),
      ),

      // Filled button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize:  const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled:      true,
        fillColor:   isDark ? _cardDark : Colors.white,
        border:      OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: _primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // BottomNav
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? _cardDark : _cardLight,
        indicatorColor:  (isDark ? _primaryDark : _primary).withAlpha(30),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? Colors.white10 : Colors.black.withAlpha(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: GoogleFonts.inter(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }
}

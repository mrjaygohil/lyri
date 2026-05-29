import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Palette
  static const Color darkBg = Color(0xFF0F172A); // Slate 900
  static const Color darkCardBg = Color(0xFF1E293B); // Slate 800
  static const Color darkPrimary = Color(0xFF6366F1); // Indigo 500
  static const Color darkSecondary = Color(0xFF8B5CF6); // Violet 500
  static const Color darkAccent = Color(0xFF10B981); // Emerald 500
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkBorder = Color(0xFF334155); // Slate 700

  // Light Palette
  static const Color lightBg = Color(0xFFF8FAFC); // Slate 50
  static const Color lightCardBg = Colors.white;
  static const Color lightPrimary = Color(0xFF4F46E5); // Indigo 600
  static const Color lightSecondary = Color(0xFF7C3AED); // Violet 600
  static const Color lightAccent = Color(0xFF059669); // Emerald 600
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200

  // Theme Modes
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCardBg,
      dividerColor: darkBorder,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        surface: darkCardBg,
        background: darkBg,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onBackground: darkTextPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: GoogleFonts.inter(color: darkTextPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: darkTextSecondary, fontSize: 14),
        labelLarge: GoogleFonts.inter(color: darkTextPrimary, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCardBg,
        elevation: 0,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(color: darkTextPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardBg,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: lightPrimary,
      scaffoldBackgroundColor: lightBg,
      cardColor: lightCardBg,
      dividerColor: lightBorder,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        surface: lightCardBg,
        background: lightBg,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onBackground: lightTextPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        bodyLarge: GoogleFonts.inter(color: lightTextPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: lightTextSecondary, fontSize: 14),
        labelLarge: GoogleFonts.inter(color: lightTextPrimary, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightCardBg,
        elevation: 0,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(color: lightTextPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCardBg,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
    );
  }

  // Premium Glassmorphism & Custom Gradient Utilities
  static BoxDecoration glassDecoration({
    required BuildContext context,
    double opacity = 0.6,
    double blur = 15.0,
    BorderRadius? borderRadius,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: (isDark ? darkCardBg : Colors.white).withOpacity(opacity),
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(
        color: (isDark ? darkBorder : lightBorder).withOpacity(0.4),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static LinearGradient primaryGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark 
          ? [darkPrimary, darkSecondary] 
          : [lightPrimary, lightSecondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

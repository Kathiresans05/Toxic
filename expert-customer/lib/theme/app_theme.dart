import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ultra-Premium Colors (Warm Amber Yellow Gold, Emerald Green, Neon Pink)
  static const Color primary = Color(0xFFFFB800);   // Warm Amber Gold
  static const Color secondary = Color(0xFF10B981); // Vibrant Emerald Green
  static const Color accent = Color(0xFFEC4899);    // Neon Pink Highlight

  // Royal Purple Gradient Palette (Connecto / ConnectaX Premium)
  static const List<Color> royalPurpleGradient = [
    Color(0xFF1A0B2E),
    Color(0xFF3B1578),
    Color(0xFF5B21B6),
  ];

  // Dark Theme Colors (Deep Slate Luxury Black: #0F172A)
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCardColor = Color(0xFF1E293B);
  static const Color darkCardBorder = Color(0xFF334155);

  // Light Theme Colors (Ultra-Clean Modern Slate: #F8FAFC)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCardColor = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Legacy Fallbacks
  static const Color background = darkBackground;
  static const Color cardColor = darkCardColor;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primary,
      cardColor: darkCardColor,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: darkCardColor,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: primary,
      cardColor: lightCardColor,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: lightCardColor,
        onSurface: lightTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(color: lightTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

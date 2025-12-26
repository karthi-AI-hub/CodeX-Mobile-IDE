import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CodeXColors {
  static const Color background = Color(0xFF1E1E1E);
  static const Color sidebar = Color(0xFF252526);
  static const Color header = Color(0xFF252526);
  static const Color accentBlue = Color(0xFF007ACC);
  static const Color text = Color(0xFFD4D4D4);
  static const Color strings = Color(0xFFCE9178);
  static const Color keywords = Color(0xFF569CD6);
  static const Color border = Color(0xFF333333);
  static const Color cardBg = Color(0xFF2D2D2D);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: CodeXColors.accentBlue,
      scaffoldBackgroundColor: CodeXColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: CodeXColors.header,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: CodeXColors.text),
      ),
      colorScheme: const ColorScheme.dark(
        primary: CodeXColors.accentBlue,
        surface: CodeXColors.sidebar,
        background: CodeXColors.background,
        onPrimary: Colors.white,
        onSurface: CodeXColors.text,
        onBackground: CodeXColors.text,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        bodyMedium: const TextStyle(color: CodeXColors.text),
        titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: CodeXColors.cardBg,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: CodeXColors.sidebar,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        contentTextStyle: GoogleFonts.outfit(color: CodeXColors.text),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CodeXColors.accentBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

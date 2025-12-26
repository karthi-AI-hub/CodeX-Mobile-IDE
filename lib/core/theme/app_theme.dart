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
      appBarTheme: const AppBarTheme(
        backgroundColor: CodeXColors.header,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: CodeXColors.text,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: CodeXColors.text),
      ),
      colorScheme: const ColorScheme.dark(
        primary: CodeXColors.accentBlue,
        surface: CodeXColors.sidebar,
        background: CodeXColors.background,
        onPrimary: Colors.white,
        onSurface: CodeXColors.text,
        onBackground: CodeXColors.text,
      ),
      textTheme: GoogleFonts.firaCodeTextTheme().copyWith(
        bodyMedium: const TextStyle(color: CodeXColors.text),
      ),
      cardTheme: CardThemeData(
        color: CodeXColors.cardBg,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: CodeXColors.border, width: 0.5),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: CodeXColors.sidebar,
        titleTextStyle: TextStyle(color: CodeXColors.text, fontSize: 18),
        contentTextStyle: TextStyle(color: CodeXColors.text),
      ),
    );
  }
}

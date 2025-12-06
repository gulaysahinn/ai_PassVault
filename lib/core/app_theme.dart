import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color primary = Color(0xFFBB86FC);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color error = Color(0xFFCF6679);

  static final textTheme =
      GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);

  static final darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    cardColor: surface,
    textTheme: textTheme,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
    ),
  );
}

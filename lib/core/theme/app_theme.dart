import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Bảng màu (Color Palette)
  static const Color woodBackground = Color(0xFF2C1810);
  static const Color woodBorder = Color(0xFF3D2317);
  static const Color woodHighlight = Color(0xFF5C3D2E);
  
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color goldDim = Color(0xFF8B7355);
  
  static const Color parchment = Color(0xFFF3E5AB); // Màu giấy da
  static const Color parchmentDark = Color(0xFFD1BFAe);
  
  static const Color bloodRed = Color(0xFF8B0000);
  static const Color textDark = Color(0xFF1A0F08);

  // Text Styles
  static TextStyle get titleStyle => GoogleFonts.rye(
    color: goldAccent,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
  );

  static TextStyle get subtitleStyle => GoogleFonts.sancreek(
    color: goldDim,
    fontSize: 14,
    letterSpacing: 1,
  );

  static TextStyle get cardTitleStyle => GoogleFonts.rye(
    color: textDark,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get normalText => GoogleFonts.robotoSlab(
    color: Colors.white70,
    fontSize: 12,
  );

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: woodBackground,
    primaryColor: goldAccent,
    textTheme: GoogleFonts.robotoSlabTextTheme(ThemeData.dark().textTheme),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: goldAccent,
        foregroundColor: textDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

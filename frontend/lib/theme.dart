import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

/// Poppins: bold for titles, normal for text and description (via google_fonts).
class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      fontFamily: GoogleFonts.poppins().fontFamily,
      appBarTheme: AppBarTheme(
        color: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextColor),
        titleTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: kTextColor,
          fontSize: 18,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kTextColor),
        displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kTextColor),
        displaySmall: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kTextColor),
        headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kTextColor),
        headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kTextColor),
        headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kTextColor),
        titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kTextColor),
        titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kTextColor),
        titleSmall: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: kTextColor),
        bodyLarge: GoogleFonts.poppins(fontWeight: FontWeight.normal, color: kTextColor),
        bodyMedium: GoogleFonts.poppins(fontWeight: FontWeight.normal, color: kTextColor),
        bodySmall: GoogleFonts.poppins(fontWeight: FontWeight.normal, color: kTextColor),
        labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.normal, color: kTextColor),
        labelMedium: GoogleFonts.poppins(fontWeight: FontWeight.normal, color: kTextColor),
        labelSmall: GoogleFonts.poppins(fontWeight: FontWeight.normal, color: kTextColor),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
        enabledBorder: outlineInputBorder,
        focusedBorder: outlineInputBorder,
        border: outlineInputBorder,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
    );
  }
}

const OutlineInputBorder outlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(28)),
  borderSide: BorderSide(color: kTextColor),
  gapPadding: 10,
);

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => GoogleFonts.plusJakartaSansTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 32,
            height: 1.3,
          ),
          displayMedium: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            height: 1.3,
          ),
          headlineLarge: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            height: 1.3,
          ),
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 1.4,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            height: 1.4,
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            height: 1.4,
          ),
          titleSmall: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.4,
          ),
          bodyLarge: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.5,
          ),
          bodySmall: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 13,
            height: 1.4,
          ),
          labelLarge: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.2,
          ),
          labelSmall: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
            height: 1.2,
          ),
        ),
      );
}

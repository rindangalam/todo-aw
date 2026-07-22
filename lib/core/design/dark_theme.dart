import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

class DarkTheme {
  DarkTheme._();

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: ColorTokens.primary,
        scaffoldBackgroundColor: ColorTokens.darkBackground,
        textTheme: AppTypography.textTheme,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
          backgroundColor: ColorTokens.darkBackground,
          foregroundColor: Color(0xFFE5E7EB),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: ColorTokens.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 2,
          backgroundColor: ColorTokens.primary,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ColorTokens.darkCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.sm),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.sm),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.sm),
            borderSide: const BorderSide(color: ColorTokens.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm + 2,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          elevation: 0,
          backgroundColor: ColorTokens.darkSurface,
          selectedItemColor: ColorTokens.primary,
          unselectedItemColor: Color(0xFF6B7280),
          type: BottomNavigationBarType.fixed,
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          backgroundColor: ColorTokens.darkSurface,
          indicatorColor: ColorTokens.primary.withOpacity(0.15),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: ColorTokens.primary,
              );
            }
            return const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Color(0xFF6B7280),
            );
          }),
        ),
        checkboxTheme: CheckboxThemeData(
          shape: const CircleBorder(),
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return ColorTokens.primary;
            }
            return Colors.transparent;
          }),
          side: const BorderSide(color: Color(0xFF4B5563), width: 2),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF1F2937),
          thickness: 1,
          space: 0,
        ),
        chipTheme: ChipThemeData(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.sm),
          ),
        ),
      );
}

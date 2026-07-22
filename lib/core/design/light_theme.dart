import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

class LightTheme {
  LightTheme._();

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: ColorTokens.primary,
        scaffoldBackgroundColor: ColorTokens.background,
        textTheme: AppTypography.textTheme,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
          backgroundColor: ColorTokens.background,
          foregroundColor: Color(0xFF1F2937),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: ColorTokens.surface,
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
          fillColor: ColorTokens.background,
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
          backgroundColor: ColorTokens.surface,
          selectedItemColor: ColorTokens.primary,
          unselectedItemColor: Color(0xFF9CA3AF),
          type: BottomNavigationBarType.fixed,
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          backgroundColor: ColorTokens.surface,
          indicatorColor: ColorTokens.primary.withOpacity(0.12),
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
              color: Color(0xFF9CA3AF),
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
          side: const BorderSide(color: Color(0xFFD1D5DB), width: 2),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFF1F5F9),
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

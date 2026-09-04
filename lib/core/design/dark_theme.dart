import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';
import 'typography.dart';

class DarkTheme {
  DarkTheme._();

  static ThemeData theme({Color accent = const Color(0xFF0EA5E9)}) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: accent,
        scaffoldBackgroundColor: ColorTokens.darkBackground,
        textTheme: AppTypography.textTheme,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
          backgroundColor: ColorTokens.darkBackground,
          foregroundColor: Color(0xFFE5E7EB),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: ColorTokens.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 2,
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
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
            borderSide: BorderSide(color: accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm + 2,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          elevation: 0,
          backgroundColor: ColorTokens.darkSurface,
          selectedItemColor: accent,
          unselectedItemColor: const Color(0xFF6B7280),
          type: BottomNavigationBarType.fixed,
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          backgroundColor: ColorTokens.darkSurface,
          indicatorColor: accent.withOpacity(0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: accent,
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
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return accent;
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
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm, vertical: Spacing.xxs),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.sm),
          ),
        ),
      );
}

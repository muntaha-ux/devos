import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Central theme definition for DevOS.
/// DevOS is a strictly single-theme (Light Only) application.
class AppTheme {
  AppTheme._();

  /// Primary single theme for the DevOS workspace.
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.figmaBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.figmaBlue,
        onPrimary: Colors.white,
        secondary: AppColors.figmaCodeBadge,
        onSecondary: Colors.white,
        surface: AppColors.figmaMetricCard,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.accentRose,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.spaceGrotesk(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
            headlineMedium: GoogleFonts.spaceGrotesk(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
            titleLarge: GoogleFonts.inter(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            titleMedium: GoogleFonts.inter(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            bodyLarge: GoogleFonts.inter(
              color: AppColors.textPrimaryLight,
              fontSize: 14,
            ),
            bodyMedium: GoogleFonts.inter(
              color: AppColors.textSecondaryLight,
              fontSize: 13,
            ),
            labelSmall: GoogleFonts.jetBrainsMono(
              color: AppColors.figmaTextRed,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
      cardTheme: CardThemeData(
        color: AppColors.figmaMetricCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF333333), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.figmaBackground,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.figmaBottomNav,
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xFFF3C7D4),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  /// Alias for backward compatibility with existing tests and callers.
  static ThemeData get lightTheme => theme;
}

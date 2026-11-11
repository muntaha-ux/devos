import 'package:flutter/material.dart';

/// Centralized Design System Palette for DevOS
/// Supports both Figma Studio Light mode and DevOS Obsidian Dark mode
class AppColors {
  AppColors._();

  // ===================== FIGMA LIGHT PALETTE =====================
  static const Color figmaBackground = Color(0xFFD6BDBD);
  static const Color figmaBottomNav = Color(0xFF8F0030);
  static const Color figmaNavActive = Color(0xFF650022);
  static const Color figmaBlue = Color(0xFF1E56FF);
  static const Color figmaCardDark = Color(0xFF222222);

  // Screen 1: Dashboard
  static const Color figmaUrgentCard = Color(0xFFCECECE);
  static const Color figmaMetricCard = Color(0xFFF3F3F3);
  static const Color figmaTextRed = Color(
    0xFFB91C1C,
  ); // Accessible high-contrast crimson
  static const Color figmaSubmitBtn = Color(
    0xFF2D2D2D,
  ); // High contrast interactive button
  static const Color figmaCodeBadge = Color(0xFF0EA358);
  static const Color figmaLavenderCard = Color(0xFFE4DBEA);
  static const Color figmaPink = Color(0xFFF06292);

  // Screen 2: Courses & Syllabus
  static const Color figmaMaroonText = Color(0xFF7A0C16);
  static const Color figmaPurpleCard = Color(0xFF7C3AED); // Modern violet
  static const Color figmaGreenTopic = Color(0xFF2E805F);
  static const Color figmaOliveTopic = Color(0xFF737C3E);

  // Screen 3: Skills
  static const Color figmaForestBanner = Color(0xFF2E6316);
  static const Color figmaPlusBtn = Color(0xFFE8C4C4);
  static const Color figmaCyanCard = Color(
    0xFF0284C7,
  ); // High contrast sky blue
  static const Color figmaGreenSubtopic = Color(0xFF16A34A);
  static const Color figmaRedSubtopic = Color(0xFFDC2626);
  static const Color figmaAddBtn = Color(0xFF1B1B1B);

  // Screen 4: Projects
  static const Color figmaDarkPurpleBanner = Color(0xFF2E1065);
  static const Color figmaOrangeCard = Color(0xFFEA580C); // Warm amber orange
  static const Color figmaPipelineGreen = Color(0xFF3F5A1F);
  static const Color figmaSprintPurple = Color(0xFF6B21A8);
  static const Color figmaSprintRust = Color(0xFF9A3412);
  static const Color figmaSprintSlate = Color(0xFF475569);

  // ===================== OBSIDIAN DARK PALETTE =====================
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color cardDark = Color(0xFF21262D);
  static const Color cardBorderDark = Color(0xFF30363D);

  // General theme palette
  static const Color backgroundLight = Color(0xFFD6BDBD);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF3F3F3);
  static const Color cardBorderLight = Color(0xFF333333);

  // Accents & Indicators
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF10B981);
  static const Color accentViolet = Color(0xFF8B5CF6);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRose = Color(0xFFE11D48);
  static const Color accentBlue = Color(0xFF3B82F6);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF0F6FC);
  static const Color textSecondaryDark = Color(0xFF8B949E);
  static const Color textMutedDark = Color(0xFF6E7681);

  static const Color textPrimaryLight = Color(0xFF181818);
  static const Color textSecondaryLight = Color(0xFF333333);
  static const Color textMutedLight = Color(0xFF666666);

  // Status Badges
  static const Color priorityLow = Color(0xFF10B981);
  static const Color priorityMedium = Color(0xFF3B82F6);
  static const Color priorityHigh = Color(0xFFF59E0B);
  static const Color priorityUrgent = Color(0xFFEF4444);

  // ===================== ADAPTIVE THEME HELPERS =====================
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color background(BuildContext context) {
    return isDark(context) ? backgroundDark : figmaBackground;
  }

  static Color card(BuildContext context) {
    return isDark(context) ? cardDark : cardLight;
  }

  static Color cardBorder(BuildContext context) {
    return isDark(context) ? cardBorderDark : cardBorderLight;
  }

  static Color textPrimary(BuildContext context) {
    return isDark(context) ? textPrimaryDark : textPrimaryLight;
  }

  static Color textSecondary(BuildContext context) {
    return isDark(context) ? textSecondaryDark : textSecondaryLight;
  }

  static Color textHeading(BuildContext context) {
    return isDark(context) ? const Color(0xFFF472B6) : figmaMaroonText;
  }

  static Color bannerBackground(BuildContext context, Color lightColor) {
    return isDark(context) ? cardDark : lightColor;
  }
}

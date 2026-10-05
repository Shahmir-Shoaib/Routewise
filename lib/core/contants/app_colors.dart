import 'package:flutter/material.dart';

class AppColors {
  // RouteWise Premium Color Palette
  // Primary: Dark Charcoal Blue
  static const Color primary = Color(0xFF2C3E50);
  static const Color primaryDark = Color(0xFF1F2B39);
  static const Color primaryLight = Color(0xFF3D4F63);

  // Secondary: Fuel-Efficiency Green
  static const Color secondary = Color(0xFF27AE60);
  static const Color secondaryDark = Color(0xFF1E8449);
  static const Color secondaryLight = Color(0xFF3CB371);

  // Accent: Route Amber
  static const Color accent = Color(0xFFF39C12);
  static const Color accentDark = Color(0xFFC67C0F);
  static const Color accentLight = Color(0xFFF5B041);

  // Backgrounds & Surfaces
  static const Color backgroundLight = Color(0xFFF4F6F9);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDarkPrimary = Color(0xFFEBF4F9);
  static const Color textDarkSecondary = Color(0xFF94A3B8);

  // Alert & Status Colors
  static const Color danger = Color(0xFFE74C3C);
  static const Color dangerLight = Color(0xFFF5B7B1);
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF2C3E50);

  // Gradients
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientSuccess = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientRoute = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient gradientPrimaryGlass = LinearGradient(
    colors: [
      primary.withOpacity(0.1),
      secondary.withOpacity(0.1),
      accent.withOpacity(0.05),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Opacity helpers
  static Color getPrimaryWithOpacity(double opacity) =>
      primary.withOpacity(opacity);
  static Color getSecondaryWithOpacity(double opacity) =>
      secondary.withOpacity(opacity);
  static Color getAccentWithOpacity(double opacity) =>
      accent.withOpacity(opacity);
}

import 'package:flutter/material.dart';

/// Responsive breakpoints for different device types
class ResponsiveBreakpoints {
  static const double mobileMax = 600;
  static const double tabletMax = 1200;
  static const double desktopMin = 1200;
}

/// Helper class for responsive design
class ResponsiveHelper {
  /// Check if device is mobile (width <= 600)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= ResponsiveBreakpoints.mobileMax;
  }

  /// Check if device is tablet (600 < width <= 1200)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > ResponsiveBreakpoints.mobileMax &&
        width <= ResponsiveBreakpoints.tabletMax;
  }

  /// Check if device is desktop (width > 1200)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > ResponsiveBreakpoints.tabletMax;
  }

  /// Get responsive width - max width constraint for content
  static double getMaxWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200;
    } else if (isTablet(context)) {
      return 768;
    }
    return double.infinity;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 32);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    }
    return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
  }

  /// Get responsive font sizes
  static double getHeadlineLargeSize(BuildContext context) {
    if (isDesktop(context)) return 36;
    if (isTablet(context)) return 32;
    return 28;
  }

  static double getHeadlineMediumSize(BuildContext context) {
    if (isDesktop(context)) return 28;
    if (isTablet(context)) return 24;
    return 22;
  }

  static double getBodyLargeSize(BuildContext context) {
    if (isDesktop(context)) return 18;
    if (isTablet(context)) return 16;
    return 14;
  }

  /// Get responsive grid columns
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  /// Check if should use sidebar layout (desktop)
  static bool useSidebarLayout(BuildContext context) {
    return isDesktop(context) || isTablet(context);
  }

  /// Check if app is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get screen size
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Get text scale factor (for accessibility)
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }
}

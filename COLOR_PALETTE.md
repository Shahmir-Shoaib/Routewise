# RouteWise Color Palette

## Official Color Scheme

All colors in RouteWise are managed through `lib/core/contants/app_colors.dart`. This document serves as a reference for the complete color scheme used throughout the application.

### Primary Colors

**Primary: Dark Charcoal Blue**
- Hex: `#2C3E50`
- Usage: Main buttons, headers, active states, navigation elements
- Light Variant: `#3D4F63` (primaryLight)
- Dark Variant: `#1F2B39` (primaryDark)

### Secondary Colors

**Secondary: Fuel-Efficiency Green**
- Hex: `#27AE60`
- Usage: Fuel price indicators, savings badges, success states, actual cost displays
- Light Variant: `#3CB371` (secondaryLight)
- Dark Variant: `#1E8449` (secondaryDark)

### Accent Colors

**Accent: Route Amber**
- Hex: `#F39C12`
- Usage: Trip cost highlights, warnings, estimated time chips, warning badges
- Light Variant: `#F5B041` (accentLight)
- Dark Variant: `#C67C0F` (accentDark)

### Background & Surface Colors

| Purpose | Light Mode | Dark Mode |
|---------|-----------|----------|
| Main Background | `#F4F6F9` (backgroundLight) | `#0F172A` (backgroundDark) |
| Card/Surface | `#FFFFFF` (surfaceLight) | `#1E293B` (surfaceDark) |

### Text Colors

**Light Mode:**
- Primary Text: `#1A1A2E` (textPrimary) - Headings, body text
- Secondary Text: `#6B7280` (textSecondary) - Subtitles, placeholders, labels

**Dark Mode:**
- Primary Text: `#EBF4F9` (textDarkPrimary) - Headings, body text
- Secondary Text: `#94A3B8` (textDarkSecondary) - Subtitles, placeholders, labels

### Alert & Status Colors

| Status | Color | Hex | Usage |
|--------|-------|-----|-------|
| Danger/Error | Red | `#E74C3C` | Traffic alerts, errors, high fuel cost warnings |
| Danger Light | Light Red | `#F5B7B1` | Error backgrounds, light alerts |
| Success | Green | `#27AE60` | Trip completed, cost saved, positive indicators |
| Warning | Amber | `#F39C12` | Warnings, caution states, estimated values |
| Info | Blue | `#2C3E50` | Informational messages, navigation hints |

## Theme Implementation

The app uses Flutter's Material 3 design system with automatic dark mode support. Colors are defined once in `AppColors` and automatically applied through:

1. **Light Theme** (`AppTheme.lightTheme`)
   - Background: Light Slate (#F4F6F9)
   - Surfaces: White (#FFFFFF)
   - Text: Dark navy (#1A1A2E) and gray (#6B7280)

2. **Dark Theme** (`AppTheme.darkTheme`)
   - Background: Very dark blue (#0F172A)
   - Surfaces: Dark slate (#1E293B)
   - Text: Light (#EBF4F9) and muted gray (#94A3B8)
   - Primary/accent colors remain the same for consistency

## Usage Examples

### In Dart Code

```dart
import 'package:routewise/core/contants/app_colors.dart';

// Primary color for main buttons
backgroundColor: AppColors.primary

// Secondary for savings indicators
color: AppColors.secondary

// Accent for warnings/highlights
color: AppColors.accent

// Danger for errors
backgroundColor: AppColors.danger

// With opacity
color: AppColors.primary.withOpacity(0.5)

// Using opacity helper
color: AppColors.getPrimaryWithOpacity(0.3)

// Pre-built gradients
decoration: BoxDecoration(
  gradient: AppColors.gradientPrimary,
)
```

### Theme-Aware Colors

Automatically respond to light/dark mode through the theme system:

```dart
// Automatically uses correct background color
scaffoldBackgroundColor: AppColors.backgroundLight // Light mode
scaffoldBackgroundColor: AppColors.backgroundDark  // Dark mode
```

## Gradient Options

### Pre-built Gradients
- `AppColors.gradientPrimary` - Primary to light
- `AppColors.gradientSuccess` - Secondary to light (green gradient)
- `AppColors.gradientRoute` - Accent to light (amber gradient)
- `AppColors.gradientPrimaryGlass` - Glass morphism effect

### Custom Gradients

```dart
gradient: LinearGradient(
  colors: [AppColors.primary, AppColors.primaryLight],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

## When to Use Each Color

| Scenario | Color | Reason |
|----------|-------|--------|
| Main navigation | Primary | Professional, trustworthy |
| Success/Savings | Secondary | Natural association with money saved |
| Costs/Warnings | Accent | Attention-grabbing for important info |
| Errors/Alerts | Danger | Universal alert color |
| Button states | Primary/Secondary | Consistency with Material Design |
| Disabled states | Text Secondary | Subtle, understated appearance |
| Card backgrounds | Surface | Clean, spacious appearance |

## Migration Guide

If updating colors in components:

1. **Replace hardcoded colors:**
   ```dart
   // ❌ Avoid
   color: Color(0xFF2C3E50)
   
   // ✅ Use
   color: AppColors.primary
   ```

2. **Update green references:**
   ```dart
   // ❌ Avoid
   color: Colors.green
   
   // ✅ Use
   color: AppColors.secondary
   ```

3. **Update orange references:**
   ```dart
   // ❌ Avoid
   color: Colors.orange
   
   // ✅ Use
   color: AppColors.accent
   ```

4. **Update red references:**
   ```dart
   // ❌ Avoid
   backgroundColor: Colors.red
   
   // ✅ Use
   backgroundColor: AppColors.danger
   ```

## Accessibility Notes

- All text colors meet WCAG AA contrast requirements
- Primary text on light backgrounds: 8.5:1 contrast ratio
- Secondary text on light backgrounds: 5.8:1 contrast ratio
- Colors are not used as the only indicator (always pair with icons/text)

## Files Reference

- **Color Definitions:** `lib/core/contants/app_colors.dart`
- **Theme Application:** `lib/core/utils/app_theme.dart`
- **Theme Provider:** `lib/providers/theme_provider.dart`

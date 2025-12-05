import 'package:flutter/material.dart';

/// Shared dashboard styling and color constants
class DashboardTheme {
  // Color palettes for each tier
  static const generalColors = ColorPalette(
    primary: Color(0xFF2E7D32), // Forest green
    accent: Color(0xFF66BB6A),
    light: Color(0xFFC8E6C9),
    gradient1: Color(0xFF1B5E20),
    gradient2: Color(0xFF4CAF50),
  );

  static const affiliateColors = ColorPalette(
    primary: Color(0xFF1565C0), // Deep blue
    accent: Color(0xFF42A5F5),
    light: Color(0xFFC5D9F1),
    gradient1: Color(0xFF0D47A1),
    gradient2: Color(0xFF1976D2),
  );

  // Alias for backwards compatibility
  static const allianceColors = affiliateColors;

  static const associateColors = ColorPalette(
    primary: Color(0xFFFFB300), // Rich gold
    accent: Color(0xFFFFC107),
    light: Color(0xFFFFF3E0),
    gradient1: Color(0xFFF57F17),
    gradient2: Color(0xFFFFB300),
  );

  // Spacing
  static const double gridSpacing = 16;
  static const double cardPadding = 16;
  static const double borderRadius = 16;
}

class ColorPalette {
  final Color primary;
  final Color accent;
  final Color light;
  final Color gradient1;
  final Color gradient2;

  const ColorPalette({
    required this.primary,
    required this.accent,
    required this.light,
    required this.gradient1,
    required this.gradient2,
  });
}

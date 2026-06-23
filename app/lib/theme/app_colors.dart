import 'package:flutter/material.dart';

/// Warm-paper / ink palette — the stoic aesthetic of the web app.
class AppColors {
  AppColors._();

  // Ink (text + chrome)
  static const Color ink = Color(0xFF1F1D1A);
  static const Color inkSoft = Color(0xFF3B3833);
  static const Color inkMute = Color(0xFF7A7268);

  // Paper (backgrounds)
  static const Color paper = Color(0xFFFAF6EF);
  static const Color paperWarm = Color(0xFFF4EDE0);
  static const Color paperCard = Color(0xFFFFFDF7);

  // Accent
  static const Color accent = Color(0xFFB9532E);
  static const Color accentSoft = Color(0xFFD97A55);

  // Highlight
  static const Color gold = Color(0xFFC8A14A);
  static const Color sage = Color(0xFF6B8A6A);

  // Pro
  static const Color proGold = Color(0xFFB8924A);
  static const Color proGoldSoft = Color(0xFFEBD8A8);

  // Theme colors (used by category icons/pills, mirrors the web)
  static const Map<String, Color> themeColors = {
    'dichotomy-of-control': Color(0xFF5B7C99),
    'virtue':               Color(0xFF7B68A6),
    'memento-mori':         Color(0xFF4A4A4A),
    'discipline-action':    Color(0xFFC8553D),
    'perspective':          Color(0xFF6B9080),
    'resilience':           Color(0xFF8B6F47),
    'mindfulness':          Color(0xFFA4907C),
    'amor-fati':            Color(0xFF5C8D89),
  };

  static Color forTheme(String? slug) {
    if (slug == null) return inkSoft;
    return themeColors[slug] ?? inkSoft;
  }
}

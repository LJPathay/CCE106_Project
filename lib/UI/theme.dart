import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF0F172A); // Dark Blue/Slate
  static const Color secondary = Color(0xFF4F46E5); // Indigo Accent
  static const Color accent = Color(0xFFFFFFFF); // White Text
  static const Color textSecondary = Color(0xFF9CA3AF); // Light Gray Text

  // ✅ Add this
  static const Color surfaceLight = Color(0xFFF3F4F6); // Light Grey Input BG

  // Typography
  static TextStyle heading = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: accent,
  );

  static TextStyle subheading = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: accent,
  );

  static TextStyle body = const TextStyle(fontSize: 14, color: accent);

  // Card Gradient
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Soft Shadow
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}

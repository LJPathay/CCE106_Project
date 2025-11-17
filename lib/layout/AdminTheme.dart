import 'package:flutter/material.dart';

class AdminTheme {
  // Palette
  static const Color primary = Color(0xFF343A40); // Business dark gray
  static const Color secondary = Color(0xFF2779BD); // Muted blue
  static const Color accent = Color(0xFFFFFFFF); // White
  static const Color danger = Color(0xFFD9534F); // Status red
  static const Color success = Color(0xFF5CB85C); // Status green
  static const Color textSecondary = Color(0xFF6C757D); // Subtle gray text

  static const Color surfaceLight = Color(0xFFF8F9FA); // Card/table bg

  // Typography
  static TextStyle heading = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primary,
  );

  static TextStyle subheading = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primary,
  );

  static TextStyle body = const TextStyle(fontSize: 14, color: primary);

  // Button Style
  static ButtonStyle flatButton = TextButton.styleFrom(
    foregroundColor: accent,
    backgroundColor: secondary,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  );

  // Card style
  static BoxDecoration card = BoxDecoration(
    color: surfaceLight,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.07),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Table style
  static TextStyle tableHeading = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: secondary,
  );
}


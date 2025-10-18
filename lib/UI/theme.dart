import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._(); // Prevent instantiation

  // === Core Palette (Professional) ===
  static const Color primary = Color(
    0xFF202A44,
  ); // Main background: deep blue-gray
  static const Color secondary = Color(
    0xFF293659,
  ); // Slightly lighter for gradients and secondary sections
  static const Color accent = Color(
    0xFF48B993,
  ); // Mint accent (for FABs, buttons, highlights)
  static const Color highlight = Color(
    0xFFFCF3A8,
  ); // Pastel yellow highlight for warning/status, not large surfaces

  // === States ===
  static const Color positive = Color(0xFF00A86B); // Green for gains/success
  static const Color negative = Color(0xFFD7263D); // Red for losses/warnings

  // === Surfaces ===
  static const Color surfaceLight = Color(
    0xFF37476A,
  ); // Card, input box, slightly lighter than background
  static const Color surfaceDark = Color(
    0xFF25304B,
  ); // Containers or deeply nested cards

  // === Text ===
  static const Color textPrimary = Color(
    0xFFFFFFFF,
  ); // White text for best readability
  static const Color textSecondary = Color(
    0xFFB2C0DA,
  ); // Light muted blue for supporting text
  static const Color textAccent = accent;

  // === Gradients ===
  static const LinearGradient mainGradient = LinearGradient(
    colors: [secondary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceLight, surfaceDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glowGradient = LinearGradient(
    colors: [
      Color(0x4048B993), // Soft mint (accent) glow
      Color(0x00FCF3A8), // Transparent highlight
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // === Shadows ===
  static final List<BoxShadow> neonShadow = [
    BoxShadow(
      color: accent.withOpacity(0.18),
      blurRadius: 14,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  // === Typography ===
  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 0.2,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: textPrimary,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: textSecondary,
  );

  static const TextStyle cardValuePositive = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: positive,
  );

  static const TextStyle cardValueNegative = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: negative,
  );

  // === Button Styles ===
  static ButtonStyle neonButton = ElevatedButton.styleFrom(
    backgroundColor: accent,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    elevation: 6,
    shadowColor: accent.withOpacity(0.25),
  );
}

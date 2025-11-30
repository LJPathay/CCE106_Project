import 'package:flutter/material.dart';

class AppTheme {
  // Basic palette
  static const Color primary = Color(0xFF0F172A); // Dark Blue/Slate (default)
  static const Color secondary = Color(0xFF4F46E5); // Indigo Accent (default)
  static const Color accent = Color(0xFFFFFFFF); // White Text
  static const Color textSecondary = Color(0xFF9CA3AF); // Light Gray Text

  // Instagram palette
  static const Color instagramYellow = Color(0xFFFCAF45);
  static const Color instagramOrange = Color(0xFFF58529);
  static const Color instagramPink = Color(0xFFDD2A7B);
  static const Color instagramPurple = Color(0xFF8134AF);
  static const Color instagramBlue = Color(0xFF515BD4);

  static const Color instagramAccent = instagramPink; // Hot pink accent

  static const List<Color> instagramGradientColors = [
    instagramYellow,
    instagramOrange,
    instagramPink,
    instagramPurple,
    instagramBlue,
  ];

  // Instagram-style gradient (for header/rings)
  static const LinearGradient instagramGradient = LinearGradient(
    colors: instagramGradientColors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light surface color
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

  // Card Gradient (legacy)
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
  // Standardized Palette
  static const Color primaryPink = Color(0xFFD81B60);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Helper Methods

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: softShadow,
          ),
          child: const CircularProgressIndicator(color: primaryPink),
        ),
      ),
    );
  }

  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    Color confirmColor = primaryPink,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: subheading.copyWith(color: Colors.black87)),
        content: Text(content, style: body.copyWith(color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

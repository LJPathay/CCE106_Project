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
  // Helpers
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        backgroundColor: danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const CircularProgressIndicator(color: secondary),
        ),
      ),
    );
  }

  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title, style: subheading),
        content: Text(content, style: body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
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

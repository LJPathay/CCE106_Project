import 'package:flutter/material.dart';
import 'theme.dart';

class InputField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool isPassword;
  final TextEditingController? controller; // <-- Add this

  const InputField({
    super.key,
    required this.icon,
    required this.hint,
    required this.isPassword,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPassword,
      controller: controller, // <-- Wire up controller here
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.surfaceLight,
        prefixIcon: Icon(icon, color: AppTheme.accent),
        hintText: hint,
        hintStyle: AppTheme.body.copyWith(color: AppTheme.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppTheme.accent.withOpacity(0.28)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppTheme.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
      style: AppTheme.body,
    );
  }
}

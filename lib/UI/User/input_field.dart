import 'package:flutter/material.dart';
import '../../layout/theme.dart';

class InputField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;

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
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.surfaceLight,
        prefixIcon: Icon(icon, color: AppTheme.secondary),
        hintText: hint,
        hintStyle: AppTheme.body.copyWith(color: AppTheme.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppTheme.secondary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppTheme.secondary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
      style: const TextStyle(color: Colors.black87, fontSize: 15),
    );
  }
}

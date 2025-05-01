// lib/components/my_textfield.dart
import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool obscureText;

  const MyTextfield({
    super.key,
    this.controller,
    this.hintText = '',
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: colors.onSurfaceVariant),
          filled: true,
          fillColor: colors.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colors.primaryContainer),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colors.primary),
          ),
        ),
      ),
    );
  }
}
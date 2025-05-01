import 'package:flutter/material.dart';

class SquareTitle extends StatelessWidget {
  final String imagePath;
  final double size;

  const SquareTitle({
    super.key,
    required this.imagePath,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,                     // fondo gris/azul suave
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primaryContainer), // borde azul pastel
      ),
      child: Image.asset(
        imagePath,
        width: size,
        height: size,
      ),
    );
  }
}

// lib/components/my_button.dart

import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final VoidCallback? onTap;
  final String text;

  const MyButton({
    Key? key,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          margin: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            color: _isHovered ? colors.primary : colors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? colors.primary : colors.primaryContainer,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                color: _isHovered ? colors.onPrimary : colors.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

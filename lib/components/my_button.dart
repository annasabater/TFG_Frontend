// my_button.dart (simplificado)
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color? color;
  final Color? textColor;
  final double? borderRadius;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;

  const MyButton({
    Key? key,
    required this.onTap,
    required this.text,
    this.color,
    this.textColor,
    this.borderRadius,
    this.height,
    this.fontSize,
    this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 20),
          ),
          elevation: 6,
          shadowColor: Colors.black45,
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: fontSize ?? 18,
            fontWeight: fontWeight ?? FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

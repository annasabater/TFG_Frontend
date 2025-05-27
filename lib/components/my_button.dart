// my_button.dart 
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
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 25),
          ),
          elevation: 4,
          shadowColor: Colors.black38,
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize ?? 18,
            fontWeight: fontWeight ?? FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

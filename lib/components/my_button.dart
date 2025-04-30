import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final Function()? onTap;

  const MyButton({super.key, required this.onTap});

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(25),
          margin: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.deepPurple[100] : Colors.deepPurple[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? Colors.deepPurple[300]! : Colors.deepPurple[100]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              "Sign In",
              style: TextStyle(
                color: _isHovered ? Colors.deepPurple[500] : Colors.deepPurple[300],
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
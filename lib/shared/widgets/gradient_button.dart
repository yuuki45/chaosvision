import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Gradient gradient;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.gradient,
    this.width,
    this.height,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onPressed,
            child: Padding(
              padding: padding,
              child: Center(
                child: Text(
                  text,
                  style: textStyle ??
                      Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
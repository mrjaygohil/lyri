import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final Gradient? gradient;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.textColor,
    this.width,
    this.height = 48.0,
    this.borderRadius = 10.0,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultButtonColor = color ?? theme.primaryColor;
    final defaultTextColor = textColor ?? (isOutlined ? defaultButtonColor : Colors.white);

    final buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: defaultTextColor,
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: defaultTextColor),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: defaultTextColor,
          ),
        ),
      ],
    );

    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: defaultButtonColor,
            side: BorderSide(color: defaultButtonColor, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: buttonContent,
        ),
      );
    }

    // Gradient or Solid Button
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );

    final actualGradient = gradient ?? (color == null ? AppTheme.primaryGradient(context) : null);

    if (actualGradient != null && onPressed != null && !isLoading) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: actualGradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: (actualGradient.colors.first).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: buttonShape,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: buttonContent,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: defaultButtonColor,
          disabledBackgroundColor: defaultButtonColor.withOpacity(0.6),
          shape: buttonShape,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: buttonContent,
      ),
    );
  }
}

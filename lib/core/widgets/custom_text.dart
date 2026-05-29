import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool isSecondary;
  final bool useOutfit;

  const CustomText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.isSecondary = false,
    this.useOutfit = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultColor = color ??
        (isSecondary
            ? (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)
            : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary));

    final baseStyle = useOutfit
        ? GoogleFonts.outfit(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: defaultColor,
          )
        : GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: defaultColor,
          );

    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: baseStyle,
    );
  }
}

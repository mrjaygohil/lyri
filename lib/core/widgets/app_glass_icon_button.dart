import 'package:flutter/material.dart';
import 'app_animated_button.dart';

/// AppGlassIconButton renders a translucent glass pill action button with:
/// - Tinted glass fill (opacity: 0.14)
/// - Specular highlight border (opacity: 0.35)
/// - Ambient glow shadow
/// - Hardware-accelerated hover and press scale animations via AppAnimatedButton
class AppGlassIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;

  const AppGlassIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.tooltip,
    this.size = 34.0,
    this.iconSize = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget btn = AppAnimatedButton(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.16),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: btn,
      );
    }
    return btn;
  }
}

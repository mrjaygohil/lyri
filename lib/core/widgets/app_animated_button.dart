import 'package:flutter/material.dart';

/// AppAnimatedButton wraps any child widget (button, icon, card, tile) with:
/// - Interactive hover scale-up and subtle glow shadow
/// - Tactile press scale-down feedback
/// - Smooth 60fps hardware-accelerated animations
class AppAnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double hoverScale;
  final double pressScale;
  final Duration duration;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? hoverShadow;
  final Color? hoverColor;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;

  const AppAnimatedButton({
    super.key,
    required this.child,
    this.onTap,
    this.hoverScale = 1.035,
    this.pressScale = 0.95,
    this.duration = const Duration(milliseconds: 180),
    this.borderRadius,
    this.hoverShadow,
    this.hoverColor,
    this.tooltip,
    this.padding,
  });

  @override
  State<AppAnimatedButton> createState() => _AppAnimatedButtonState();
}

class _AppAnimatedButtonState extends State<AppAnimatedButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    double scale = 1.0;
    if (_isPressed) {
      scale = widget.pressScale;
    } else if (_isHovered) {
      scale = widget.hoverScale;
    }

    Widget result = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: widget.duration,
            curve: Curves.easeOutCubic,
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              color: _isHovered ? widget.hoverColor : null,
              boxShadow: _isHovered ? widget.hoverShadow : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      result = Tooltip(
        message: widget.tooltip!,
        child: result,
      );
    }

    return result;
  }
}

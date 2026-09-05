import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../theme/app_colors.dart';

/// AppGlassContainer provides an authentic iOS-style frosted glass effect
/// with high blur, ambient translucent gradients, specular border highlights,
/// and smooth hover / press micro-animations.
class AppGlassContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final LinearGradient? linearGradient;
  final LinearGradient? borderGradient;
  final AlignmentGeometry alignment;
  final VoidCallback? onTap;
  final bool animateHover;
  final bool animateEntrance;
  final Duration animationDuration;

  const AppGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.blur = 20,
    this.borderWidth = 1.2,
    this.padding,
    this.margin,
    this.linearGradient,
    this.borderGradient,
    this.alignment = Alignment.center,
    this.onTap,
    this.animateHover = true,
    this.animateEntrance = true,
    this.animationDuration = const Duration(milliseconds: 220),
  });

  @override
  State<AppGlassContainer> createState() => _AppGlassContainerState();
}

class _AppGlassContainerState extends State<AppGlassContainer> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _canAnimateHover => widget.animateHover && widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool isCurrentlyHovered = _canAnimateHover && _isHovered;

    final LinearGradient defaultGradient = widget.linearGradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E293B).withValues(alpha: isCurrentlyHovered ? 0.55 : 0.45),
                  const Color(0xFF0F172A).withValues(alpha: isCurrentlyHovered ? 0.35 : 0.25),
                ]
              : [
                  Colors.white.withValues(alpha: isCurrentlyHovered ? 0.82 : 0.72),
                  Colors.white.withValues(alpha: isCurrentlyHovered ? 0.52 : 0.42),
                ],
        );

    final LinearGradient defaultBorderGradient = widget.borderGradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: isCurrentlyHovered ? 0.50 : 0.35),
                  Colors.white.withValues(alpha: isCurrentlyHovered ? 0.15 : 0.08),
                ]
              : [
                  Colors.white.withValues(alpha: isCurrentlyHovered ? 0.95 : 0.85),
                  AppColors.primaryIndigo.withValues(alpha: isCurrentlyHovered ? 0.35 : 0.20),
                ],
        );

    Widget glassContent;

    if (widget.width != null && widget.height != null) {
      glassContent = GlassmorphicContainer(
        width: widget.width!,
        height: widget.height!,
        borderRadius: widget.borderRadius,
        blur: widget.blur,
        alignment: widget.alignment,
        border: isCurrentlyHovered ? widget.borderWidth + 0.5 : widget.borderWidth,
        linearGradient: defaultGradient,
        borderGradient: defaultBorderGradient,
        child: widget.padding != null ? Padding(padding: widget.padding!, child: widget.child) : widget.child,
      );
    } else {
      // Dynamic sizing using ClipRRect + BackdropFilter + Translucent Border
      glassContent = ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            alignment: widget.alignment,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: defaultGradient,
              border: Border.all(
                width: isCurrentlyHovered ? widget.borderWidth + 0.5 : widget.borderWidth,
                color: isDark
                    ? Colors.white.withValues(alpha: isCurrentlyHovered ? 0.35 : 0.22)
                    : AppColors.primaryIndigo.withValues(alpha: isCurrentlyHovered ? 0.35 : 0.20),
              ),
            ),
            child: widget.child,
          ),
        ),
      );
    }

    // Apply interactive hover & press transform animation
    double scale = 1.0;
    if (_canAnimateHover && _isPressed) {
      scale = 0.97;
    } else if (_canAnimateHover && _isHovered) {
      scale = 1.015;
    }

    Widget interactiveWidget = MouseRegion(
      onEnter: (_) {
        if (_canAnimateHover) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (_canAnimateHover) {
          setState(() => _isHovered = false);
        }
      },
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: (_) {
          if (widget.onTap != null) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (widget.onTap != null) setState(() => _isPressed = false);
        },
        onTapCancel: () {
          if (widget.onTap != null) setState(() => _isPressed = false);
        },
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: widget.animationDuration,
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: widget.animationDuration,
            curve: Curves.easeOutCubic,
            margin: widget.margin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: isCurrentlyHovered
                  ? [
                      BoxShadow(
                        color: (isDark ? AppColors.primaryIndigo : Colors.indigo).withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: glassContent,
          ),
        ),
      ),
    );

    // Optional entrance fade-in & slide-up animation
    if (widget.animateEntrance) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 16),
              child: child,
            ),
          );
        },
        child: interactiveWidget,
      );
    }

    return interactiveWidget;
  }
}

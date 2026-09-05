import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Dark Palette (Rich, Obsidian & Slate) ---
  static const Color darkBackground = Color(0xFF090D16);      // Deep obsidian dark slate
  static const Color darkCard = Color(0xFF151C2C);            // Dark surface card
  static const Color darkCardHover = Color(0xFF1E293B);       // Dark surface hover state
  static const Color darkHeader = Color(0xFF0F172A);          // Top header / sidebar surface
  static const Color darkTextPrimary = Color(0xFFF8FAFC);     // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8);   // Slate 400
  static const Color darkTextMuted = Color(0xFF64748B);       // Slate 500
  static const Color darkBorder = Color(0xFF1E293B);          // Subtle dark border
  static const Color darkBorderHighlight = Color(0xFF334155); // Highlighted dark border

  // --- Light Palette (Clean, Crisp & Bright) ---
  static const Color lightBackground = Color(0xFFF8FAFC);     // Crisp Slate 50
  static const Color lightCard = Colors.white;                // Pure white card
  static const Color lightCardHover = Color(0xFFF1F5F9);      // Light surface hover state
  static const Color lightHeader = Colors.white;              // Top header / sidebar surface
  static const Color lightTextPrimary = Color(0xFF0F172A);    // Dark Slate 900
  static const Color lightTextSecondary = Color(0xFF475569);  // Slate 600
  static const Color lightTextMuted = Color(0xFF94A3B8);      // Slate 400
  static const Color lightBorder = Color(0xFFE2E8F0);         // Subtle light border
  static const Color lightBorderHighlight = Color(0xFFCBD5E1);

  // --- Brand Accents & Gradients ---
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color secondaryViolet = Color(0xFF8B5CF6);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentPurple = Color(0xFFA855F7);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentSky = Color(0xFF38BDF8);

  // --- Metric Gradient Pairs ---
  static const List<Color> songsGradient = [Color(0xFF6366F1), Color(0xFF8B5CF6)];
  static const List<Color> categoriesGradient = [Color(0xFF10B981), Color(0xFF059669)];
  static const List<Color> tagsGradient = [Color(0xFFF59E0B), Color(0xFFD97706)];
  static const List<Color> raagsGradient = [Color(0xFFA855F7), Color(0xFFD946EF)];
  static const List<Color> usersGradient = [Color(0xFFF43F5E), Color(0xFFE11D48)];

  // --- Context Helper Getters ---
  static Color getBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBackground : lightBackground;

  static Color getCard(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;

  static Color getCardHover(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCardHover : lightCardHover;

  static Color getHeader(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkHeader : lightHeader;

  static Color getTextPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;

  static Color getTextSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;

  static Color getBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : lightBorder;
}

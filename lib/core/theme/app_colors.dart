import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color background = Color(0xFF0D0B14);
  static const Color surface = Color(0xFF161222);
  static const Color surfaceElevated = Color(0xFF1E1830);
  static const Color textPrimary = Color(0xFFF5F3FF);
  static const Color textSecondary = Color(0xFFB8B4C8);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentBlue = Color(0xFF6366F1);
  static const Color glow = Color(0x66A855F7);

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentPurple, accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

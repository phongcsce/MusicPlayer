import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F3FB),
      colorScheme: ColorScheme.light(
        surface: Colors.white,
        primary: AppColors.accentPurple,
        secondary: AppColors.accentBlue,
        onPrimary: Colors.white,
        onSurface: const Color(0xFF1C1530),
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFF1C1530),
        displayColor: const Color(0xFF1C1530),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1C1530),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1C1530)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
      ),
    );
  }

  static ThemeData dark({bool useDarkBackground = true}) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor:
          useDarkBackground ? AppColors.background : AppColors.surface,
      colorScheme: ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.accentPurple,
        secondary: AppColors.accentBlue,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0x22FFFFFF)),
    );
  }
}

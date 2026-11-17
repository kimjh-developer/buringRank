import 'package:flutter/material.dart';
import 'package:burning_rank_app/core/theme/app_colors.dart';
import 'package:burning_rank_app/core/theme/app_text_styles.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primaryRed,

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.h1,
      displayMedium: AppTextStyles.h2,
      displaySmall: AppTextStyles.h3,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.button,
    ),

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryRed,
      secondary: AppColors.accentPurple,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.white,
      onError: AppColors.white,
    ),

    // App Bar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.h2,
    ),

    // Card Theme
    // Card Theme
    // cardTheme: CardTheme(
    //   color: AppColors.surface,
    //   elevation: 0,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(16),
    //   ),
    // ),
  );
}

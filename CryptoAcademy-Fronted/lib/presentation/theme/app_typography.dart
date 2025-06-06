import 'package:flutter/material.dart';
import 'app_colors.dart';


class AppTypography {
  // --- Estilos de texto para tema claro ---

  static const TextStyle displayLargeLight = TextStyle(
    fontFamily: 'Lato',
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: AppColors.textPrimaryLight, // Color de texto principal para tema claro
  );

  static const TextStyle displayMediumLight = TextStyle(
    fontFamily: 'Lato',
    fontSize: 45,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle displaySmallLight = TextStyle(
    fontFamily: 'Lato',
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle headlineLargeLight = TextStyle(
    fontFamily: 'Lato',
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle headlineMediumLight = TextStyle(
    fontFamily: 'Lato',
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle headlineSmallLight = TextStyle(
    fontFamily: 'Lato',
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle titleLargeLight = TextStyle(
    fontFamily: 'Lato',
    fontSize: 22,
    fontWeight: FontWeight.w500, // Medium para títulos
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle titleMediumLight = TextStyle(
    fontFamily: 'Lato',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle titleSmallLight = TextStyle(
    fontFamily: 'Lato',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle labelLargeLight = TextStyle(
    fontFamily: 'Lato',
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium para etiquetas
    letterSpacing: 0.1,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle labelMediumLight = TextStyle(
    fontFamily: 'Lato',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondaryLight, // Color secundario para etiquetas más pequeñas
  );

  static const TextStyle labelSmallLight = TextStyle(
    fontFamily: 'Lato',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondaryLight,
  );

  static const TextStyle bodyLargeLight = TextStyle(
    fontFamily: 'Lato',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle bodyMediumLight = TextStyle(
    fontFamily: 'Lato',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle bodySmallLight = TextStyle(
    fontFamily: 'Lato',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.textSecondaryLight, // Color secundario para texto de cuerpo más pequeño
  );

  // --- Estilos de Texto para tema oscuro ---
  // Similares a los de tema claro, pero con los colores de texto para tema oscuro.

  static final TextStyle displayLargeDark = displayLargeLight.copyWith(color: AppColors.textPrimaryDark);
  static final TextStyle displayMediumDark = displayMediumLight.copyWith(color: AppColors.textPrimaryDark);
  static final TextStyle displaySmallDark = displaySmallLight.copyWith(color: AppColors.textPrimaryDark);

  static final TextStyle headlineLargeDark = headlineLargeLight.copyWith(color: AppColors.textPrimaryDark);
  static final TextStyle headlineMediumDark = headlineMediumLight.copyWith(color: AppColors.textPrimaryDark);
  static final TextStyle headlineSmallDark = headlineSmallLight.copyWith(color: AppColors.textPrimaryDark);

  static final TextStyle titleLargeDark = titleLargeLight.copyWith(color: AppColors.textPrimaryDark);
  static final TextStyle titleMediumDark = titleMediumLight.copyWith(color: AppColors.textPrimaryDark);
  static final TextStyle titleSmallDark = titleSmallLight.copyWith(color: AppColors.textPrimaryDark);

  static final TextStyle labelLargeDark = labelLargeLight.copyWith(color: AppColors.textPrimaryDark);
  static final TextStyle labelMediumDark = labelMediumLight.copyWith(color: AppColors.textSecondaryDark);
  static final TextStyle labelSmallDark = labelSmallLight.copyWith(color: AppColors.textSecondaryDark);

  static final TextStyle bodyLargeDark = bodyLargeLight.copyWith(color: AppColors.textPrimaryDark);
  static final TextStyle bodyMediumDark = bodyMediumLight.copyWith(color: AppColors.textPrimaryDark);
  static final TextStyle bodySmallDark = bodySmallLight.copyWith(color: AppColors.textSecondaryDark);


  // TextTheme para tema claro
  static TextTheme get lightTextTheme => TextTheme(
        displayLarge: displayLargeLight,
        displayMedium: displayMediumLight,
        displaySmall: displaySmallLight,
        headlineLarge: headlineLargeLight,
        headlineMedium: headlineMediumLight,
        headlineSmall: headlineSmallLight,
        titleLarge: titleLargeLight,
        titleMedium: titleMediumLight,
        titleSmall: titleSmallLight,
        labelLarge: labelLargeLight,
        labelMedium: labelMediumLight,
        labelSmall: labelSmallLight,
        bodyLarge: bodyLargeLight,
        bodyMedium: bodyMediumLight,
        bodySmall: bodySmallLight,
      );

  // TextTheme para tema oscuro
  static TextTheme get darkTextTheme => TextTheme(
        displayLarge: displayLargeDark,
        displayMedium: displayMediumDark,
        displaySmall: displaySmallDark,
        headlineLarge: headlineLargeDark,
        headlineMedium: headlineMediumDark,
        headlineSmall: headlineSmallDark,
        titleLarge: titleLargeDark,
        titleMedium: titleMediumDark,
        titleSmall: titleSmallDark,
        labelLarge: labelLargeDark,
        labelMedium: labelMediumDark,
        labelSmall: labelSmallDark,
        bodyLarge: bodyLargeDark,
        bodyMedium: bodyMediumDark,
        bodySmall: bodySmallDark,
      );

  AppTypography._();
}

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

// Clase para definir los temas de la aplicación (claro y oscuro).
class AppTheme {
  // --- Tema claro ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true, // Habilitar Material 3
      brightness: Brightness.light, // Indicar que es un tema claro

      // Esquema de colores principal
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryLight, // Color primario principal
        onPrimary: Colors.white, // Color del texto/iconos sobre el color primario
        secondary: AppColors.accentBlue, // Color secundario
        onSecondary: Colors.white, // Color del texto/iconos sobre el color secundario
        error: AppColors.errorRed, // Color para errores
        onError: Colors.white, // Color del texto sobre el fondo general
        surface: Colors.white, // Color de las superficies
        onSurface: AppColors.textPrimaryLight, // Color del texto sobre las superficies
        
      ),

      // Tipografía
      textTheme: AppTypography.lightTextTheme,
      // Tema para appBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 4.0,
        titleTextStyle: AppTypography.titleLargeLight.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGreen,
          foregroundColor: Colors.white, // Color del texto del botón
          textStyle: AppTypography.labelLargeLight.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 2.0,
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2.0),
        ),
        labelStyle: AppTypography.bodyMediumLight.copyWith(color: AppColors.textSecondaryLight),
        hintStyle: AppTypography.bodyMediumLight.copyWith(color: AppColors.textSecondaryLight.withOpacity(0.7)),
      ),

      // Tema para tarjetas
      cardTheme: CardThemeData(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Bordes más redondeados para tarjetas
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        color: Colors.white, // Color de fondo de la tarjeta en tema claro
      ),
    );
  }

  // --- Tema oscuro ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // Indicar que es un tema oscuro

      // Esquema de colores principal
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.textPrimaryDark,
        secondary: AppColors.accentBlue,
        onSecondary: Colors.white,
        error: AppColors.errorRed,
        onError: Colors.black,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
      ),

      // Tipografía
      textTheme: AppTypography.darkTextTheme,

      // Tema para appBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        titleTextStyle: AppTypography.titleLargeDark.copyWith(color: AppColors.textPrimaryDark),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      ),

      // Tema para botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGreen,
          foregroundColor: Colors.white,
          textStyle: AppTypography.labelLargeDark.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 2.0,
        ),
      ),

      // Tema para campos de texto
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.borderDark.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 2.0), // Usar un color de acento para el foco
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2.0),
        ),
        labelStyle: AppTypography.bodyMediumDark.copyWith(color: AppColors.textSecondaryDark),
        hintStyle: AppTypography.bodyMediumDark.copyWith(color: AppColors.textSecondaryDark.withOpacity(0.7)),
      ),
      
      // Tema para tarjetas
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      ),
    );
  }

  AppTheme._();
}

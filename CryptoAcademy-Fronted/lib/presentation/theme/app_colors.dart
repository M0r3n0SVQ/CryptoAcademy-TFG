import 'package:flutter/material.dart';

class AppColors {
  // --- Colores primarios ---
  static const Color primaryDark = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFF3F51B5); 
  
  static const Color accentGreen = Color(0xFF4CAF50); // Verde para acciones positivas (Compra, Ganancias)
  static const Color accentBlue = Color(0xFF2196F3);  // Azul brillante para acentos o información
  
  // --- Colores secundarios / de alerta ---
  static const Color errorRed = Color(0xFFF44336);   // Rojo para errores o acciones negativas (Venta, Pérdidas)
  static const Color warningOrange = Color(0xFFFF9800); // Naranja para advertencias
  static const Color successGreen = Color(0xFF4CAF50); // Verde para mensajes de éxito

  // --- Colores de fondo ---
  static const Color backgroundLight = Color(0xFFF5F5F5); // Gris muy claro para fondos en tema claro
  static const Color backgroundDark = Color(0xFF121212);  // Gris muy oscuro para fondos en tema oscuro
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surface = Color(0xFFFFFFFF);


  // --- Colores de Texto ---
  // Para tema claro
  static const Color textPrimaryLight = Color(0xFF212121); // Negro/Gris oscuro para texto principal sobre fondos claros
  static const Color textSecondaryLight = Color(0xFF757575); // Gris para texto secundario sobre fondos claros
  
  // Para tema oscuro
  static const Color textPrimaryDark = Color(0xFFFFFFFF);   // Blanco para texto principal sobre fondos oscuros
  static const Color textSecondaryDark = Color(0xFFB0B0B0); // Gris claro para texto secundario sobre fondos oscuros

  // --- Colores de gráficos
  static const Color chartLineUp = Color(0xFF4CAF50);   // Verde para líneas de gráfico ascendentes
  static const Color chartLineDown = Color(0xFFF44336); // Rojo para líneas de gráfico descendentes

  // --- Otros colores útiles ---
  static const Color border = Color(0xFFE0E0E0); // Gris claro para bordes o divisores en tema claro
  static const Color borderDark = Color(0xFF3A3A3A); // Gris para bordes en tema oscuro
  static const Color iconLight = Color(0xFF757575); // Color para iconos en tema claro
  static const Color iconDark = Color(0xFFB0B0B0);  // Color para iconos en tema oscuro

  AppColors._(); 
}

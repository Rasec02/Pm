import 'package:flutter/material.dart';

import '../../domain/enums/estado_orden.dart';

/// Colores y tema visual de App Tu Solution.
class AppColors {
  const AppColors._();

  static const Color primario = Color(0xFF00897B);
  static const Color primarioOscuro = Color(0xFF00695C);
  static const Color acento = Color(0xFFFFA000);
  static const Color superficie = Color(0xFFF5F7F7);
  static const Color error = Color(0xFFC62828);
  static const Color exito = Color(0xFF2E7D32);

  /// Color asociado a cada estado de la orden.
  static Color estadoColor(EstadoOrden estado) {
    switch (estado) {
      case EstadoOrden.recibida:
        return const Color(0xFF1976D2);
      case EstadoOrden.enReparacion:
        return const Color(0xFFEF6C00);
      case EstadoOrden.lista:
        return const Color(0xFF2E7D32);
      case EstadoOrden.entregada:
        return const Color(0xFF546E7A);
      case EstadoOrden.cancelada:
        return const Color(0xFFC62828);
    }
  }
}

/// Tema Material 3 de la aplicación.
class AppTheme {
  const AppTheme._();

  static ThemeData get claro {
    final esquema = ColorScheme.fromSeed(
      seedColor: AppColors.primario,
      primary: AppColors.primario,
      secondary: AppColors.acento,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: AppColors.superficie,
      appBarTheme: AppBarThemeData(
        backgroundColor: AppColors.primario,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primario,
        foregroundColor: Colors.white,
      ),
      dividerTheme: const DividerThemeData(space: 1, thickness: 1),
    );
  }
}

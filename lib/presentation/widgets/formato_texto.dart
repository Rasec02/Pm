import 'package:flutter/services.dart';

/// Formateadores de entrada usados por los formularios.
class Formateadores {
  const Formateadores._();

  /// Solo dígitos (cantidades, existencias y umbral de stock bajo).
  static final List<TextInputFormatter> enteros = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
  ];

  /// Dígitos y separador decimal para precios escritos con coma o punto.
  static final List<TextInputFormatter> decimales = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
  ];
}

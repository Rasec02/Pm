import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/enums/estado_orden.dart';

/// Etiqueta de color con el estado de una orden.
class EstadoBadge extends StatelessWidget {
  const EstadoBadge({super.key, required this.estado, this.compacto = false});

  final EstadoOrden estado;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.estadoColor(estado);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compacto ? 8 : 10,
        vertical: compacto ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        estado.etiqueta,
        style: TextStyle(
          color: color,
          fontSize: compacto ? 11 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

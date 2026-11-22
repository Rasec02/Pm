import 'package:flutter/material.dart';

import '../../domain/enums/estado_orden.dart';

/// Selector de estado de orden usado en los filtros.
class SelectorEstado extends StatelessWidget {
  const SelectorEstado({
    super.key,
    required this.seleccionado,
    required this.onCambiar,
  });

  final EstadoOrden? seleccionado;
  final ValueChanged<EstadoOrden?> onCambiar;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Todos'),
              selected: seleccionado == null,
              onSelected: (_) => onCambiar(null),
            ),
          ),
          for (final estado
              in EstadoOrden.values.where((estado) => estado.esAbierta))
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(estado.etiqueta),
                selected: seleccionado == estado,
                onSelected: (_) => onCambiar(estado),
              ),
            ),
        ],
      ),
    );
  }
}

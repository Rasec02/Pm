import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/catalogos_providers.dart';

/// Selector de técnico usado en filtros y formularios.
class SelectorTecnico extends ConsumerWidget {
  const SelectorTecnico({
    super.key,
    required this.seleccionado,
    required this.onCambiar,
    this.etiquetaTodos = 'Todos los técnicos',
  });

  final int? seleccionado;
  final ValueChanged<int?> onCambiar;
  final String etiquetaTodos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tecnicosAsync = ref.watch(tecnicosProvider);
    return tecnicosAsync.when(
      loading: () => const InputDecorator(
        decoration: InputDecoration(labelText: 'Técnico'),
        child: Text('Cargando técnicos...'),
      ),
      error: (error, _) => InputDecorator(
        decoration: const InputDecoration(labelText: 'Técnico'),
        child: Text('Error al cargar técnicos: $error'),
      ),
      data: (tecnicos) {
        return DropdownButtonFormField<int?>(
          key: ValueKey<int?>(seleccionado),
          initialValue: seleccionado,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Técnico'),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text(etiquetaTodos),
            ),
            for (final tecnico in tecnicos)
              DropdownMenuItem<int?>(
                value: tecnico.id,
                child: Text(tecnico.nombre),
              ),
          ],
          onChanged: onCambiar,
        );
      },
    );
  }
}

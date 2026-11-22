import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/carga_trabajo.dart';
import '../providers/repository_providers.dart';

/// Carga de trabajo por técnico: cuántas órdenes abiertas tiene cada uno.
///
/// Es un `StreamProvider` sobre la consulta reactiva de Drift, de modo que la
/// pantalla se actualiza sola cuando una orden se toma, se entrega o se
/// cancela. El total general y la suma se calculan aquí, no en el widget.
final cargaTrabajoProvider = StreamProvider<CargaTrabajoResumen>((ref) {
  return ref.watch(ordenRepositoryProvider).watchCargaTrabajo().map(
        (cargas) => CargaTrabajoResumen(cargas: cargas),
      );
});

/// Resumen de la carga del taller.
class CargaTrabajoResumen {
  const CargaTrabajoResumen({required this.cargas});

  final List<CargaTrabajo> cargas;

  /// Total de órdenes abiertas asignadas a algún técnico.
  int get totalOrdenes {
    var total = 0;
    for (final carga in cargas) {
      total += carga.total;
    }
    return total;
  }

  /// Técnico con más órdenes abiertas (o `null` si todos están libres).
  CargaTrabajo? get masCargado {
    CargaTrabajo? resultado;
    for (final carga in cargas) {
      if (resultado == null || carga.total > resultado.total) {
        resultado = carga;
      }
    }
    if (resultado == null || resultado.total == 0) return null;
    return resultado;
  }
}

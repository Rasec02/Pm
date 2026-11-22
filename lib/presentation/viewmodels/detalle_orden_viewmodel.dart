import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/detalle_orden.dart';
import '../providers/repository_providers.dart';

/// Detalle reactivo de una orden concreta.
///
/// Se recalcula automáticamente cuando cambian la orden, sus trabajos o sus
/// repuestos, así el costo total siempre está al día.
final detalleOrdenProvider =
    StreamProvider.family<DetalleOrden?, int>((ref, ordenId) {
  return ref.watch(ordenRepositoryProvider).watchDetalle(ordenId);
});

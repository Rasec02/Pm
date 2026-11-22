import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/historial_item.dart';
import '../providers/usecase_providers.dart';

/// Historial de reparaciones de un equipo.
final historialEquipoProvider =
    FutureProvider.family<List<HistorialEquipoItem>, int>((ref, equipoId) {
  return ref.watch(historialPorEquipoUseCaseProvider).ejecutar(equipoId);
});

/// Historial de reparaciones de un cliente.
final historialClienteProvider =
    FutureProvider.family<List<HistorialClienteItem>, int>((ref, clienteId) {
  return ref.watch(historialPorClienteUseCaseProvider).ejecutar(clienteId);
});

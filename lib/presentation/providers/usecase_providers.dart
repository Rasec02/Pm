import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/historial_usecases.dart';
import '../../domain/usecases/inventario_usecases.dart';
import '../../domain/usecases/ordenes_usecases.dart';
import 'repository_providers.dart';

/// Casos de uso de órdenes.
final recibirEquipoUseCaseProvider = Provider<RecibirEquipoUseCase>((ref) {
  return RecibirEquipoUseCase(ref.watch(ordenRepositoryProvider));
});

final tomarOrdenUseCaseProvider = Provider<TomarOrdenUseCase>((ref) {
  return TomarOrdenUseCase(ref.watch(ordenRepositoryProvider));
});

final cambiarEstadoOrdenUseCaseProvider =
    Provider<CambiarEstadoOrdenUseCase>((ref) {
  return CambiarEstadoOrdenUseCase(ref.watch(ordenRepositoryProvider));
});

final agregarTrabajoUseCaseProvider = Provider<AgregarTrabajoUseCase>((ref) {
  return AgregarTrabajoUseCase(ref.watch(ordenRepositoryProvider));
});

final agregarRepuestoUseCaseProvider = Provider<AgregarRepuestoUseCase>((ref) {
  return AgregarRepuestoUseCase(ref.watch(ordenRepositoryProvider));
});

/// Casos de uso de inventario.
final guardarRepuestoUseCaseProvider = Provider<GuardarRepuestoUseCase>((ref) {
  return GuardarRepuestoUseCase(ref.watch(repuestoRepositoryProvider));
});

final ajustarExistenciasUseCaseProvider =
    Provider<AjustarExistenciasUseCase>((ref) {
  return AjustarExistenciasUseCase(ref.watch(repuestoRepositoryProvider));
});

/// Casos de uso de historial.
final historialPorEquipoUseCaseProvider =
    Provider<HistorialPorEquipoUseCase>((ref) {
  return HistorialPorEquipoUseCase(ref.watch(ordenRepositoryProvider));
});

final historialPorClienteUseCaseProvider =
    Provider<HistorialPorClienteUseCase>((ref) {
  return HistorialPorClienteUseCase(ref.watch(ordenRepositoryProvider));
});

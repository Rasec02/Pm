import '../entities/historial_item.dart';
import '../repositories/orden_repository.dart';

/// Historial de reparaciones de un equipo (equipos que vuelven al taller).
class HistorialPorEquipoUseCase {
  const HistorialPorEquipoUseCase(this._repositorio);

  final OrdenRepository _repositorio;

  Future<List<HistorialEquipoItem>> ejecutar(int equipoId) {
    return _repositorio.historialPorEquipo(equipoId);
  }
}

/// Historial de reparaciones de un cliente, con todos sus equipos.
class HistorialPorClienteUseCase {
  const HistorialPorClienteUseCase(this._repositorio);

  final OrdenRepository _repositorio;

  Future<List<HistorialClienteItem>> ejecutar(int clienteId) {
    return _repositorio.historialPorCliente(clienteId);
  }
}

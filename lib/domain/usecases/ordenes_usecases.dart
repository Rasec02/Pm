import '../enums/estado_orden.dart';
import '../repositories/orden_repository.dart';

/// Casos de uso de órdenes de reparación.
///
/// Son envoltorios finos sobre el repositorio: concentran las reglas de
/// negocio que la interfaz no debe conocer y permiten probarlas aisladas.
class RecibirEquipoUseCase {
  const RecibirEquipoUseCase(this._repositorio);

  final OrdenRepository _repositorio;

  Future<int> ejecutar({
    required int equipoId,
    required String fallaReportada,
  }) {
    return _repositorio.crear(
      equipoId: equipoId,
      fallaReportada: fallaReportada,
    );
  }
}

/// Toma una orden: asigna el responsable y la pasa a `en_reparacion`.
///
/// La unicidad del responsable la garantiza el DAO con una actualización
/// condicional atómica.
class TomarOrdenUseCase {
  const TomarOrdenUseCase(this._repositorio);

  final OrdenRepository _repositorio;

  Future<void> ejecutar({required int ordenId, required int tecnicoId}) {
    return _repositorio.tomar(ordenId: ordenId, tecnicoId: tecnicoId);
  }
}

/// Cambia el estado respetando el flujo
/// recibida -> en_reparacion -> lista -> entregada (y cancelada).
class CambiarEstadoOrdenUseCase {
  const CambiarEstadoOrdenUseCase(this._repositorio);

  final OrdenRepository _repositorio;

  Future<void> ejecutar({
    required int ordenId,
    required EstadoOrden destino,
  }) {
    return _repositorio.cambiarEstado(ordenId: ordenId, destino: destino);
  }
}

/// Registra mano de obra en una orden abierta.
class AgregarTrabajoUseCase {
  const AgregarTrabajoUseCase(this._repositorio);

  final OrdenRepository _repositorio;

  Future<void> ejecutar({
    required int ordenId,
    required String descripcion,
    required double costoManoObra,
  }) {
    return _repositorio.agregarTrabajo(
      ordenId: ordenId,
      descripcion: descripcion,
      costoManoObra: costoManoObra,
    );
  }
}

/// Registra el uso de un repuesto y descuenta stock de forma atómica.
class AgregarRepuestoUseCase {
  const AgregarRepuestoUseCase(this._repositorio);

  final OrdenRepository _repositorio;

  Future<void> ejecutar({
    required int ordenId,
    required int repuestoId,
    required int cantidad,
  }) {
    return _repositorio.agregarRepuesto(
      ordenId: ordenId,
      repuestoId: repuestoId,
      cantidad: cantidad,
    );
  }
}

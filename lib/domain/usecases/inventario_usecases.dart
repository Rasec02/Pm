import '../repositories/repuesto_repository.dart';

/// Alta o edición de un repuesto con validación de código único.
class GuardarRepuestoUseCase {
  const GuardarRepuestoUseCase(this._repositorio);

  final RepuestoRepository _repositorio;

  Future<void> crear({
    required String codigo,
    required String nombre,
    required double precio,
    required int existencias,
  }) {
    return _repositorio.crear(
      codigo: codigo,
      nombre: nombre,
      precio: precio,
      existencias: existencias,
    );
  }

  Future<void> actualizar({
    required int id,
    required String codigo,
    required String nombre,
    required double precio,
    required int existencias,
  }) {
    return _repositorio.actualizar(
      id: id,
      codigo: codigo,
      nombre: nombre,
      precio: precio,
      existencias: existencias,
    );
  }
}

/// Entrada o salida manual de existencias (por ejemplo, compra de stock).
class AjustarExistenciasUseCase {
  const AjustarExistenciasUseCase(this._repositorio);

  final RepuestoRepository _repositorio;

  Future<void> ejecutar({required int repuestoId, required int delta}) {
    return _repositorio.ajustarExistencias(id: repuestoId, delta: delta);
  }
}

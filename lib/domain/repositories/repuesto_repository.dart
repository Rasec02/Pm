import '../entities/repuesto.dart';

/// Contrato de acceso al inventario de repuestos.
abstract class RepuestoRepository {
  Stream<List<Repuesto>> watchTodos();

  /// Repuestos con existencias en o por debajo del [umbral].
  Stream<List<Repuesto>> watchStockBajo(int umbral);

  Future<List<Repuesto>> todos();

  Future<Repuesto?> porId(int id);

  Future<int> crear({
    required String codigo,
    required String nombre,
    required double precio,
    required int existencias,
  });

  Future<void> actualizar({
    required int id,
    required String codigo,
    required String nombre,
    required double precio,
    required int existencias,
  });

  Future<void> ajustarExistencias({required int id, required int delta});

  Future<void> eliminar(int id);
}

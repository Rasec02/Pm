import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/repuestos.dart';

part 'repuestos_dao.g.dart';

/// Acceso a datos del inventario de repuestos.
@DriftAccessor(tables: [Repuestos])
class RepuestosDao extends DatabaseAccessor<AppDatabase>
    with _$RepuestosDaoMixin {
  RepuestosDao(super.attachedDatabase);

  Stream<List<RepuestoRow>> watchTodos() {
    final query = select(repuestos)
      ..orderBy([(t) => OrderingTerm.asc(t.nombre)]);
    return query.watch();
  }

  Future<List<RepuestoRow>> todos() {
    final query = select(repuestos)
      ..orderBy([(t) => OrderingTerm.asc(t.nombre)]);
    return query.get();
  }

  /// Repuestos con existencias en o por debajo del [umbral], incluidos los
  /// agotados (existencias = 0).
  Stream<List<RepuestoRow>> watchStockBajo(int umbral) {
    final query = select(repuestos)
      ..where((t) => t.existencias.isSmallerOrEqualValue(umbral))
      ..orderBy([(t) => OrderingTerm.asc(t.existencias)]);
    return query.watch();
  }

  Future<RepuestoRow?> porId(int id) {
    return (select(repuestos)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<RepuestoRow?> porCodigo(String codigo) {
    return (select(repuestos)..where((t) => t.codigo.equals(codigo)))
        .getSingleOrNull();
  }

  Future<int> insertar({
    required String codigo,
    required String nombre,
    required double precio,
    required int existencias,
  }) {
    return into(repuestos).insert(
      RepuestosCompanion.insert(
        codigo: codigo,
        nombre: nombre,
        precio: precio,
        existencias: Value(existencias),
      ),
    );
  }

  Future<bool> actualizar(RepuestoRow repuesto) {
    return update(repuestos).replace(repuesto);
  }

  Future<int> eliminar(int id) {
    return (delete(repuestos)..where((t) => t.id.equals(id))).go();
  }
}

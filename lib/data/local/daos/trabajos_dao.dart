import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/trabajos_realizados.dart';

part 'trabajos_dao.g.dart';

/// Acceso a datos de trabajos de mano de obra.
@DriftAccessor(tables: [TrabajosRealizados])
class TrabajosDao extends DatabaseAccessor<AppDatabase>
    with _$TrabajosDaoMixin {
  TrabajosDao(super.attachedDatabase);

  /// Trabajos de una orden, del más antiguo al más reciente.
  Stream<List<TrabajoRow>> watchPorOrden(int ordenId) {
    final query = select(trabajosRealizados)
      ..where((t) => t.ordenId.equals(ordenId))
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);
    return query.watch();
  }

  Future<List<TrabajoRow>> porOrden(int ordenId) {
    final query = select(trabajosRealizados)
      ..where((t) => t.ordenId.equals(ordenId))
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);
    return query.get();
  }

  Future<int> insertar({
    required int ordenId,
    required String descripcion,
    required double costoManoObra,
  }) {
    return into(trabajosRealizados).insert(
      TrabajosRealizadosCompanion.insert(
        ordenId: ordenId,
        descripcion: descripcion,
        costoManoObra: costoManoObra,
      ),
    );
  }

  Future<int> eliminar(int id) {
    return (delete(trabajosRealizados)..where((t) => t.id.equals(id))).go();
  }

  /// Suma de mano de obra de una orden, calculada por SQLite.
  Future<double> totalManoObra(int ordenId) async {
    final fila = await customSelect(
      'SELECT COALESCE(SUM(costo_mano_obra), 0.0) AS total '
      'FROM trabajos_realizados WHERE orden_id = ?',
      variables: [Variable.withInt(ordenId)],
      readsFrom: {trabajosRealizados},
    ).getSingle();
    return fila.read<double>('total');
  }
}

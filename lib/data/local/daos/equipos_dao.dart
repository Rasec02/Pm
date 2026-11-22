import 'package:drift/drift.dart';

import '../../models/equipo_con_cliente.dart';
import '../app_database.dart';
import '../tables/clientes.dart';
import '../tables/equipos.dart';

part 'equipos_dao.g.dart';

/// Acceso a datos de equipos.
@DriftAccessor(tables: [Equipos, Clientes])
class EquiposDao extends DatabaseAccessor<AppDatabase> with _$EquiposDaoMixin {
  EquiposDao(super.attachedDatabase);

  List<EquipoConCliente> _mapear(List<TypedResult> filas) {
    return filas
        .map(
          (fila) => EquipoConCliente(
            equipo: fila.readTable(equipos),
            cliente: fila.readTable(clientes),
          ),
        )
        .toList();
  }

  /// Todos los equipos con su dueño, del más reciente al más antiguo.
  Stream<List<EquipoConCliente>> watchTodos() {
    final query = select(equipos).join([
      innerJoin(clientes, clientes.id.equalsExp(equipos.clienteId)),
    ])
      ..orderBy([OrderingTerm.desc(equipos.id)]);
    return query.watch().map(_mapear);
  }

  /// Equipos de un dueño concreto.
  Stream<List<EquipoConCliente>> watchPorCliente(int clienteId) {
    final query = select(equipos).join([
      innerJoin(clientes, clientes.id.equalsExp(equipos.clienteId)),
    ])
      ..where(equipos.clienteId.equals(clienteId))
      ..orderBy([OrderingTerm.desc(equipos.id)]);
    return query.watch().map(_mapear);
  }

  Future<List<EquipoConCliente>> porCliente(int clienteId) {
    final query = select(equipos).join([
      innerJoin(clientes, clientes.id.equalsExp(equipos.clienteId)),
    ])
      ..where(equipos.clienteId.equals(clienteId))
      ..orderBy([OrderingTerm.desc(equipos.id)]);
    return query.get().then(_mapear);
  }

  Future<EquipoRow?> porId(int id) {
    return (select(equipos)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertar({
    required String tipo,
    required String marca,
    required String modelo,
    required String numeroSerie,
    required int clienteId,
  }) {
    return into(equipos).insert(
      EquiposCompanion.insert(
        tipo: tipo,
        marca: marca,
        modelo: modelo,
        numeroSerie: numeroSerie,
        clienteId: clienteId,
      ),
    );
  }

  Future<int> eliminar(int id) {
    return (delete(equipos)..where((t) => t.id.equals(id))).go();
  }
}

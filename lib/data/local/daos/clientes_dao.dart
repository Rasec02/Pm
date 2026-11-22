import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/clientes.dart';

part 'clientes_dao.g.dart';

/// Acceso a datos de clientes / dueños.
@DriftAccessor(tables: [Clientes])
class ClientesDao extends DatabaseAccessor<AppDatabase>
    with _$ClientesDaoMixin {
  ClientesDao(super.attachedDatabase);

  /// Todos los clientes ordenados por nombre.
  Stream<List<ClienteRow>> watchTodos() {
    final query = select(clientes)
      ..orderBy([(t) => OrderingTerm.asc(t.nombre)]);
    return query.watch();
  }

  Future<List<ClienteRow>> todos() {
    final query = select(clientes)
      ..orderBy([(t) => OrderingTerm.asc(t.nombre)]);
    return query.get();
  }

  Future<ClienteRow?> porId(int id) {
    return (select(clientes)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertar({required String nombre, required String telefono}) {
    return into(clientes).insert(
      ClientesCompanion.insert(nombre: nombre, telefono: telefono),
    );
  }

  Future<bool> actualizar(ClienteRow cliente) {
    return update(clientes).replace(cliente);
  }

  Future<int> eliminar(int id) {
    return (delete(clientes)..where((t) => t.id.equals(id))).go();
  }
}

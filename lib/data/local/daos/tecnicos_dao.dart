import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tecnicos.dart';

part 'tecnicos_dao.g.dart';

/// Acceso a datos de técnicos (los 3 fijos creados por el seed).
@DriftAccessor(tables: [Tecnicos])
class TecnicosDao extends DatabaseAccessor<AppDatabase>
    with _$TecnicosDaoMixin {
  TecnicosDao(super.attachedDatabase);

  Stream<List<TecnicoRow>> watchTodos() {
    final query = select(tecnicos)
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);
    return query.watch();
  }

  Future<List<TecnicoRow>> todos() {
    final query = select(tecnicos)
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);
    return query.get();
  }

  Future<TecnicoRow?> porId(int id) {
    return (select(tecnicos)..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}

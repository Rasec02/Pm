import '../../domain/entities/tecnico.dart';
import '../../domain/repositories/tecnico_repository.dart';
import '../local/app_database.dart';
import 'mappers.dart';

/// Implementación de [TecnicoRepository] sobre Drift.
class TecnicoRepositoryImpl implements TecnicoRepository {
  TecnicoRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Tecnico>> watchTodos() {
    return _db.tecnicosDao.watchTodos().map(
          (filas) => filas.map((fila) => fila.aDominio()).toList(),
        );
  }

}

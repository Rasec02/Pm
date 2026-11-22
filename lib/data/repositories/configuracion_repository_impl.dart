import '../../domain/repositories/configuracion_repository.dart';
import '../local/app_database.dart';

/// Implementación de [ConfiguracionRepository] sobre Drift.
class ConfiguracionRepositoryImpl implements ConfiguracionRepository {
  ConfiguracionRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<int> watchUmbralStockBajo() {
    return _db.configuracionDao.watchUmbralStockBajo();
  }

  @override
  Future<int> umbralStockBajo() {
    return _db.configuracionDao.umbralStockBajo();
  }

  @override
  Future<void> guardarUmbralStockBajo(int umbral) {
    return _db.configuracionDao.guardarUmbralStockBajo(umbral);
  }
}

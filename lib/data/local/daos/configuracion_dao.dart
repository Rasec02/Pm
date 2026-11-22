import 'package:drift/drift.dart';

import '../../../domain/constants.dart';
import '../app_database.dart';
import '../tables/configuracion.dart';

part 'configuracion_dao.g.dart';

/// Acceso a datos de configuración clave/valor.
@DriftAccessor(tables: [Configuracion])
class ConfiguracionDao extends DatabaseAccessor<AppDatabase>
    with _$ConfiguracionDaoMixin {
  ConfiguracionDao(super.attachedDatabase);

  Stream<String?> watchValor(String clave) {
    final query = select(configuracion)..where((t) => t.clave.equals(clave));
    return query.watchSingleOrNull().map((fila) => fila?.valor);
  }

  Future<String?> valor(String clave) async {
    final fila = await (select(configuracion)
          ..where((t) => t.clave.equals(clave)))
        .getSingleOrNull();
    return fila?.valor;
  }

  Future<void> guardar(String clave, String valor) async {
    await into(configuracion).insertOnConflictUpdate(
      ConfiguracionCompanion.insert(clave: clave, valor: valor),
    );
  }

  /// Umbral de stock bajo configurado por el usuario.
  Stream<int> watchUmbralStockBajo() {
    return watchValor(ConfiguracionKeys.umbralStockBajo).map(_aEntero);
  }

  Future<int> umbralStockBajo() async {
    return _aEntero(await valor(ConfiguracionKeys.umbralStockBajo));
  }

  Future<void> guardarUmbralStockBajo(int umbral) {
    return guardar(ConfiguracionKeys.umbralStockBajo, '$umbral');
  }

  int _aEntero(String? valor) {
    final numero = int.tryParse(valor ?? '');
    if (numero == null || numero < 0) {
      return ConfiguracionKeys.umbralStockBajoPorDefecto;
    }
    return numero;
  }
}

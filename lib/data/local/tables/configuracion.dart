import 'package:drift/drift.dart';

/// Configuración sencilla clave/valor (por ejemplo el umbral de stock bajo).
@DataClassName('ConfiguracionRow')
class Configuracion extends Table {
  TextColumn get clave => text()();

  TextColumn get valor => text()();

  @override
  Set<Column> get primaryKey => {clave};
}

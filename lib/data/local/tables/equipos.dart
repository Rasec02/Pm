import 'package:drift/drift.dart';

import 'clientes.dart';

/// Tabla de equipos. El tipo se guarda como texto con el nombre del enum
/// (`celular`, `tablet`, `laptop`).
@DataClassName('EquipoRow')
class Equipos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get tipo => text()();

  TextColumn get marca => text()();

  TextColumn get modelo => text()();

  TextColumn get numeroSerie => text()();

  IntColumn get clienteId => integer().references(Clientes, #id)();

  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();
}

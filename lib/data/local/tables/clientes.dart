import 'package:drift/drift.dart';

/// Tabla de clientes / dueños de equipos.
@DataClassName('ClienteRow')
class Clientes extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nombre => text()();

  TextColumn get telefono => text()();

  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();
}

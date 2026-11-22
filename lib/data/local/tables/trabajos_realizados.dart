import 'package:drift/drift.dart';

import 'ordenes.dart';

/// Trabajos de mano de obra realizados en una orden.
@DataClassName('TrabajoRow')
class TrabajosRealizados extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get ordenId => integer().references(Ordenes, #id)();

  TextColumn get descripcion => text()();

  RealColumn get costoManoObra => real()();

  DateTimeColumn get fechaRegistro =>
      dateTime().withDefault(currentDateAndTime)();
}

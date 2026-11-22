import 'package:drift/drift.dart';

import 'ordenes.dart';
import 'repuestos.dart';

/// Repuestos usados en una orden.
///
/// `precioUnitario` se guarda como copia del precio al momento del uso para
/// que el costo histórico no cambie si luego se actualiza el inventario.
@DataClassName('UsoRepuestoRow')
class UsosRepuesto extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get ordenId => integer().references(Ordenes, #id)();

  IntColumn get repuestoId => integer().references(Repuestos, #id)();

  IntColumn get cantidad => integer()();

  RealColumn get precioUnitario => real()();

  DateTimeColumn get fechaRegistro =>
      dateTime().withDefault(currentDateAndTime)();
}

import 'package:drift/drift.dart';

/// Inventario de repuestos. `codigo` es único.
@DataClassName('RepuestoRow')
class Repuestos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get codigo => text().unique()();

  TextColumn get nombre => text()();

  RealColumn get precio => real()();

  IntColumn get existencias => integer().withDefault(const Constant(0))();
}

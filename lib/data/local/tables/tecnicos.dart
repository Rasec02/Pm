import 'package:drift/drift.dart';

/// Tabla de técnicos del taller (3 fijos creados por el seed inicial).
@DataClassName('TecnicoRow')
class Tecnicos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nombre => text()();
}

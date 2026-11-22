import 'package:drift/drift.dart';

import 'equipos.dart';
import 'tecnicos.dart';

/// Tabla de órdenes de reparación.
///
/// - `estado` guarda el nombre del enum [EstadoOrden] como texto.
/// - `tecnicoId` es nullable hasta que un técnico toma la orden.
/// - `fechaEntrega` solo se llena al pasar a `entregada`.
@DataClassName('OrdenRow')
class Ordenes extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get equipoId => integer().references(Equipos, #id)();

  IntColumn get tecnicoId => integer().nullable().references(Tecnicos, #id)();

  TextColumn get fallaReportada => text()();

  TextColumn get estado => text().withDefault(const Constant('recibida'))();

  DateTimeColumn get fechaRecepcion =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get fechaEntrega => dateTime().nullable()();
}

import 'package:drift/drift.dart';

import '../../models/uso_repuesto_con_repuesto.dart';
import '../app_database.dart';
import '../tables/repuestos.dart';
import '../tables/usos_repuesto.dart';

part 'usos_repuesto_dao.g.dart';

/// Acceso a datos de repuestos usados en órdenes.
///
/// Registrar un uso descuenta existencias en una transacción atómica y valida
/// que haya stock suficiente.
@DriftAccessor(tables: [UsosRepuesto, Repuestos])
class UsosRepuestoDao extends DatabaseAccessor<AppDatabase>
    with _$UsosRepuestoDaoMixin {
  UsosRepuestoDao(super.attachedDatabase);

  List<UsoRepuestoConRepuesto> _mapear(List<TypedResult> filas) {
    return filas
        .map(
          (fila) => UsoRepuestoConRepuesto(
            uso: fila.readTable(usosRepuesto),
            repuesto: fila.readTable(repuestos),
          ),
        )
        .toList();
  }

  Stream<List<UsoRepuestoConRepuesto>> watchPorOrden(int ordenId) {
    final query = select(usosRepuesto).join([
      innerJoin(repuestos, repuestos.id.equalsExp(usosRepuesto.repuestoId)),
    ])
      ..where(usosRepuesto.ordenId.equals(ordenId))
      ..orderBy([OrderingTerm.asc(usosRepuesto.id)]);
    return query.watch().map(_mapear);
  }

  Future<List<UsoRepuestoConRepuesto>> porOrden(int ordenId) {
    final query = select(usosRepuesto).join([
      innerJoin(repuestos, repuestos.id.equalsExp(usosRepuesto.repuestoId)),
    ])
      ..where(usosRepuesto.ordenId.equals(ordenId))
      ..orderBy([OrderingTerm.asc(usosRepuesto.id)]);
    return query.get().then(_mapear);
  }

  /// Registra el uso de [cantidad] unidades de un repuesto en una orden.
  ///
  /// Todo ocurre en una sola transacción:
  /// 1. Se lee el repuesto y se valida que exista y que el stock alcance.
  /// 2. Se descuenta el stock con `UPDATE ... WHERE existencias >= cantidad`,
  ///    de modo que la validación y el descuento son atómicos.
  /// 3. Se inserta el uso guardando el precio unitario del momento.
  ///
  /// Lanza [StockInsuficienteError] o [RepuestoNoExisteError] si no se puede.
  Future<void> registrarUso({
    required int ordenId,
    required int repuestoId,
    required int cantidad,
    required double precioUnitario,
  }) async {
    if (cantidad <= 0) {
      throw CantidadInvalidaError();
    }
    await transaction(() async {
      final repuesto = await (select(repuestos)
            ..where((t) => t.id.equals(repuestoId)))
          .getSingleOrNull();
      if (repuesto == null) {
        throw RepuestoNoExisteError(repuestoId);
      }

      final filasAfectadas = await customUpdate(
        'UPDATE repuestos SET existencias = existencias - ? '
        'WHERE id = ? AND existencias >= ?',
        variables: [
          Variable.withInt(cantidad),
          Variable.withInt(repuestoId),
          Variable.withInt(cantidad),
        ],
        updates: {repuestos},
        updateKind: UpdateKind.update,
      );

      if (filasAfectadas == 0) {
        throw StockInsuficienteError(
          repuestoId: repuestoId,
          nombre: repuesto.nombre,
          disponible: repuesto.existencias,
          solicitado: cantidad,
        );
      }

      await into(usosRepuesto).insert(
        UsosRepuestoCompanion.insert(
          ordenId: ordenId,
          repuestoId: repuestoId,
          cantidad: cantidad,
          precioUnitario: precioUnitario,
        ),
      );
    });
  }

  /// Devuelve al inventario las existencias de un uso y elimina el registro.
  /// Se usa si el técnico se equivoca al cargar un repuesto.
  Future<void> eliminarUso(int usoId) async {
    await transaction(() async {
      final uso = await (select(usosRepuesto)
            ..where((t) => t.id.equals(usoId)))
          .getSingleOrNull();
      if (uso == null) return;

      await customUpdate(
        'UPDATE repuestos SET existencias = existencias + ? WHERE id = ?',
        variables: [
          Variable.withInt(uso.cantidad),
          Variable.withInt(uso.repuestoId),
        ],
        updates: {repuestos},
        updateKind: UpdateKind.update,
      );
      await (delete(usosRepuesto)..where((t) => t.id.equals(usoId))).go();
    });
  }

  /// Indica si el repuesto ya está referenciado por alguna orden.
  Future<bool> repuestoEstaEnUso(int repuestoId) async {
    final fila = await customSelect(
      'SELECT COUNT(*) AS total FROM usos_repuesto WHERE repuesto_id = ?',
      variables: [Variable.withInt(repuestoId)],
      readsFrom: {usosRepuesto},
    ).getSingle();
    return fila.read<int>('total') > 0;
  }

  /// Suma de (cantidad x precio unitario) de los repuestos de una orden.
  Future<double> totalRepuestos(int ordenId) async {
    final fila = await customSelect(
      'SELECT COALESCE(SUM(cantidad * precio_unitario), 0.0) AS total '
      'FROM usos_repuesto WHERE orden_id = ?',
      variables: [Variable.withInt(ordenId)],
      readsFrom: {usosRepuesto},
    ).getSingle();
    return fila.read<double>('total');
  }
}

/// Error interno: stock insuficiente al registrar un uso.
class StockInsuficienteError implements Exception {
  StockInsuficienteError({
    required this.repuestoId,
    required this.nombre,
    required this.disponible,
    required this.solicitado,
  });

  final int repuestoId;
  final String nombre;
  final int disponible;
  final int solicitado;
}

/// Error interno: el repuesto no existe.
class RepuestoNoExisteError implements Exception {
  RepuestoNoExisteError(this.repuestoId);

  final int repuestoId;
}

/// Error interno: cantidad inválida.
class CantidadInvalidaError implements Exception {}

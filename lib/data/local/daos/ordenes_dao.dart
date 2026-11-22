import 'package:drift/drift.dart';

import '../../../domain/enums/estado_orden.dart';
import '../../models/orden_con_detalle.dart';
import '../app_database.dart';
import '../tables/clientes.dart';
import '../tables/equipos.dart';
import '../tables/ordenes.dart';
import '../tables/tecnicos.dart';

part 'ordenes_dao.g.dart';

/// Acceso a datos de órdenes de reparación.
@DriftAccessor(tables: [Ordenes, Equipos, Clientes, Tecnicos])
class OrdenesDao extends DatabaseAccessor<AppDatabase>
    with _$OrdenesDaoMixin {
  OrdenesDao(super.attachedDatabase);

  List<OrdenConDetalle> _mapear(List<TypedResult> filas) {
    return filas
        .map(
          (fila) => OrdenConDetalle(
            orden: fila.readTable(ordenes),
            equipo: fila.readTable(equipos),
            cliente: fila.readTable(clientes),
            tecnico: fila.readTableOrNull(tecnicos),
          ),
        )
        .toList();
  }

  /// Todas las órdenes, de la más reciente a la más antigua.
  Stream<List<OrdenConDetalle>> watchTodas() {
    final query = select(ordenes).join([
      innerJoin(equipos, equipos.id.equalsExp(ordenes.equipoId)),
      innerJoin(clientes, clientes.id.equalsExp(equipos.clienteId)),
      leftOuterJoin(tecnicos, tecnicos.id.equalsExp(ordenes.tecnicoId)),
    ])
      ..orderBy([OrderingTerm.desc(ordenes.id)]);
    return query.watch().map(_mapear);
  }

  /// Órdenes abiertas (recibida, en reparación o lista) con filtros
  /// opcionales por estado y por técnico responsable.
  Stream<List<OrdenConDetalle>> watchAbiertas({
    EstadoOrden? estado,
    int? tecnicoId,
  }) {
    final query = select(ordenes).join([
      innerJoin(equipos, equipos.id.equalsExp(ordenes.equipoId)),
      innerJoin(clientes, clientes.id.equalsExp(equipos.clienteId)),
      leftOuterJoin(tecnicos, tecnicos.id.equalsExp(ordenes.tecnicoId)),
    ]);
    Expression<bool> filtro = ordenes.estado.isIn([
      EstadoOrden.recibida.name,
      EstadoOrden.enReparacion.name,
      EstadoOrden.lista.name,
    ]);
    if (estado != null) {
      filtro = filtro & ordenes.estado.equals(estado.name);
    }
    if (tecnicoId != null) {
      filtro = filtro & ordenes.tecnicoId.equals(tecnicoId);
    }
    query
      ..where(filtro)
      ..orderBy([OrderingTerm.desc(ordenes.id)]);
    return query.watch().map(_mapear);
  }

  /// Orden concreta con equipo, dueño y responsable.
  Stream<OrdenConDetalle?> watchPorId(int id) {
    final query = select(ordenes).join([
      innerJoin(equipos, equipos.id.equalsExp(ordenes.equipoId)),
      innerJoin(clientes, clientes.id.equalsExp(equipos.clienteId)),
      leftOuterJoin(tecnicos, tecnicos.id.equalsExp(ordenes.tecnicoId)),
    ])
      ..where(ordenes.id.equals(id));
    return query.watch().map((filas) {
      if (filas.isEmpty) return null;
      return _mapear(filas).first;
    });
  }

  Future<List<OrdenConDetalle>> porEquipo(int equipoId) {
    final query = select(ordenes).join([
      innerJoin(equipos, equipos.id.equalsExp(ordenes.equipoId)),
      innerJoin(clientes, clientes.id.equalsExp(equipos.clienteId)),
      leftOuterJoin(tecnicos, tecnicos.id.equalsExp(ordenes.tecnicoId)),
    ])
      ..where(ordenes.equipoId.equals(equipoId))
      ..orderBy([OrderingTerm.desc(ordenes.id)]);
    return query.get().then(_mapear);
  }

  Future<OrdenConDetalle?> porId(int id) async {
    final query = select(ordenes).join([
      innerJoin(equipos, equipos.id.equalsExp(ordenes.equipoId)),
      innerJoin(clientes, clientes.id.equalsExp(equipos.clienteId)),
      leftOuterJoin(tecnicos, tecnicos.id.equalsExp(ordenes.tecnicoId)),
    ])
      ..where(ordenes.id.equals(id));
    final filas = await query.get();
    if (filas.isEmpty) return null;
    return _mapear(filas).first;
  }

  /// Cantidad de órdenes de un equipo. Se usa para impedir eliminar equipos
  /// con historial.
  Future<int> contarPorEquipo(int equipoId) async {
    final fila = await customSelect(
      'SELECT COUNT(*) AS total FROM ordenes WHERE equipo_id = ?',
      variables: [Variable.withInt(equipoId)],
      readsFrom: {ordenes},
    ).getSingle();
    return fila.read<int>('total');
  }

  Future<OrdenRow?> filaPorId(int id) {
    return (select(ordenes)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Crea una orden en estado `recibida` y sin responsable.
  Future<int> insertar({
    required int equipoId,
    required String fallaReportada,
  }) {
    return into(ordenes).insert(
      OrdenesCompanion.insert(
        equipoId: equipoId,
        fallaReportada: fallaReportada,
        estado: Value(EstadoOrden.recibida.name),
      ),
    );
  }

  /// Toma la orden de forma atómica.
  ///
  /// La condición `tecnico_id IS NULL AND estado = 'recibida'` dentro de la
  /// misma sentencia garantiza que dos técnicos no puedan tomarla a la vez:
  /// solo la primera actualización afecta una fila. Si no afecta ninguna fila,
  /// se lanza `OrdenYaTomadaError`, que el repositorio traduce a
  /// `OrdenYaTomadaException` con el técnico actual.
  Future<void> tomar({
    required int ordenId,
    required int tecnicoId,
  }) async {
    await transaction(() async {
      final filasAfectadas = await (update(ordenes)
            ..where(
              (t) =>
                  t.id.equals(ordenId) &
                  t.tecnicoId.isNull() &
                  t.estado.equals(EstadoOrden.recibida.name),
            ))
          .write(
        OrdenesCompanion(
          tecnicoId: Value(tecnicoId),
          estado: Value(EstadoOrden.enReparacion.name),
        ),
      );
      if (filasAfectadas == 0) {
        throw OrdenYaTomadaError(ordenId);
      }
    });
  }

  /// Cambia el estado de una orden validando el flujo permitido.
  Future<void> cambiarEstado({
    required int ordenId,
    required EstadoOrden destino,
  }) async {
    await transaction(() async {
      final actual = await filaPorId(ordenId);
      if (actual == null) {
        throw OrdenNoExisteError(ordenId);
      }
      final estadoActual = EstadoOrden.desdeNombre(actual.estado);
      if (!estadoActual.puedeCambiarA(destino)) {
        throw TransicionEstadoError(estadoActual, destino);
      }
      await (update(ordenes)..where((t) => t.id.equals(ordenId))).write(
        OrdenesCompanion(
          estado: Value(destino.name),
          fechaEntrega: destino == EstadoOrden.entregada
              ? Value(DateTime.now())
              : const Value.absent(),
        ),
      );
    });
  }
}

/// Error interno del DAO: la orden ya fue tomada por otro técnico.
class OrdenYaTomadaError implements Exception {
  OrdenYaTomadaError(this.ordenId);

  final int ordenId;
}

/// Error interno del DAO: la orden no existe.
class OrdenNoExisteError implements Exception {
  OrdenNoExisteError(this.ordenId);

  final int ordenId;
}

/// Error interno del DAO: transición de estado no permitida.
class TransicionEstadoError implements Exception {
  TransicionEstadoError(this.actual, this.destino);

  final EstadoOrden actual;
  final EstadoOrden destino;
}

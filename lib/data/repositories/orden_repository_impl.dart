import 'dart:async';

import '../../domain/entities/carga_trabajo.dart';
import '../../domain/entities/costo_orden.dart';
import '../../domain/entities/detalle_orden.dart';
import '../../domain/entities/historial_item.dart';
import '../../domain/entities/orden.dart';
import '../../domain/entities/tecnico.dart';
import '../../domain/enums/estado_orden.dart';
import '../../domain/enums/tipo_equipo.dart';
import '../../domain/exceptions/app_exceptions.dart';
import '../../domain/repositories/orden_repository.dart';
import '../local/app_database.dart';
import '../local/daos/ordenes_dao.dart';
import '../local/daos/usos_repuesto_dao.dart';
import '../models/orden_con_detalle.dart';
import '../models/uso_repuesto_con_repuesto.dart';
import 'mappers.dart';

/// Implementación de [OrdenRepository] sobre Drift.
///
/// Frente al requisito de estado con `Notifier`/`AsyncNotifier` se usan
/// `StreamProvider` de Riverpod sobre consultas reactivas de Drift: el stream
/// es la fuente de verdad y los ViewModels exponen las acciones.
class OrdenRepositoryImpl implements OrdenRepository {
  OrdenRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Orden>> watchAbiertas({EstadoOrden? estado, int? tecnicoId}) {
    return _db.ordenesDao
        .watchAbiertas(estado: estado, tecnicoId: tecnicoId)
        .map((filas) => filas.map((fila) => fila.aDominio()).toList());
  }

  @override
  Stream<List<Orden>> watchTodas() {
    return _db.ordenesDao
        .watchTodas()
        .map((filas) => filas.map((fila) => fila.aDominio()).toList());
  }

  @override
  Future<DetalleOrden?> detalle(int ordenId) async {
    final fila = await _db.ordenesDao.porId(ordenId);
    if (fila == null) return null;
    final trabajos = await _db.trabajosDao.porOrden(ordenId);
    final usos = await _db.usosRepuestoDao.porOrden(ordenId);
    final manoObra = await _db.trabajosDao.totalManoObra(ordenId);
    final repuestos = await _db.usosRepuestoDao.totalRepuestos(ordenId);
    return DetalleOrden(
      orden: fila.aDominio(),
      trabajos: trabajos.map((trabajo) => trabajo.aDominio()).toList(),
      repuestosUsados: usos.map((uso) => uso.aDominio()).toList(),
      costo: CostoOrden(manoObra: manoObra, repuestos: repuestos),
    );
  }

  @override
  Stream<DetalleOrden?> watchDetalle(int ordenId) {
    final controlador = StreamController<DetalleOrden?>();
    Orden? ordenActual;
    var trabajosActuales = <TrabajoRow>[];
    var usosActuales = <UsoRepuestoConRepuesto>[];
    var ordenRecibida = false;
    var suscripciones = <StreamSubscription<dynamic>>[];

    void emitir() {
      if (!ordenRecibida) return;
      final orden = ordenActual;
      if (orden == null) {
        controlador.add(null);
        return;
      }
      final manoObra = trabajosActuales.fold<double>(
        0,
        (total, trabajo) => total + trabajo.costoManoObra,
      );
      final repuestos = usosActuales.fold<double>(
        0,
        (total, uso) => total + uso.uso.cantidad * uso.uso.precioUnitario,
      );
      controlador.add(
        DetalleOrden(
          orden: orden,
          trabajos:
              trabajosActuales.map((trabajo) => trabajo.aDominio()).toList(),
          repuestosUsados:
              usosActuales.map((uso) => uso.aDominio()).toList(),
          costo: CostoOrden(manoObra: manoObra, repuestos: repuestos),
        ),
      );
    }

    controlador
      ..onListen = () {
        suscripciones = [
          _db.ordenesDao.watchPorId(ordenId).listen((fila) {
            ordenRecibida = true;
            ordenActual = fila?.aDominio();
            emitir();
          }),
          _db.trabajosDao.watchPorOrden(ordenId).listen((filas) {
            trabajosActuales = filas;
            emitir();
          }),
          _db.usosRepuestoDao.watchPorOrden(ordenId).listen((filas) {
            usosActuales = filas;
            emitir();
          }),
        ];
      }
      ..onCancel = () async {
        for (final suscripcion in suscripciones) {
          await suscripcion.cancel();
        }
        suscripciones = [];
      };

    return controlador.stream;
  }

  @override
  Future<int> crear({
    required int equipoId,
    required String fallaReportada,
  }) async {
    if (fallaReportada.trim().isEmpty) {
      throw ValidacionException('La falla reportada es obligatoria.');
    }
    return _db.ordenesDao.insertar(
      equipoId: equipoId,
      fallaReportada: fallaReportada.trim(),
    );
  }

  @override
  Future<void> tomar({required int ordenId, required int tecnicoId}) async {
    final tecnico = await _db.tecnicosDao.porId(tecnicoId);
    if (tecnico == null) {
      throw TecnicoNoEncontradoException(tecnicoId);
    }
    try {
      await _db.ordenesDao.tomar(ordenId: ordenId, tecnicoId: tecnicoId);
    } on OrdenYaTomadaError {
      final actual = await _db.ordenesDao.porId(ordenId);
      if (actual == null) {
        throw OrdenNoEncontradaException(ordenId);
      }
      throw OrdenYaTomadaException(
        ordenId: ordenId,
        tecnicoId: actual.tecnico?.id ?? 0,
      );
    } on OrdenNoExisteError {
      throw OrdenNoEncontradaException(ordenId);
    }
  }

  @override
  Future<void> cambiarEstado({
    required int ordenId,
    required EstadoOrden destino,
  }) async {
    try {
      await _db.ordenesDao.cambiarEstado(ordenId: ordenId, destino: destino);
    } on OrdenNoExisteError {
      throw OrdenNoEncontradaException(ordenId);
    } on TransicionEstadoError catch (error) {
      throw TransicionInvalidaException(
        actual: error.actual,
        destino: error.destino,
      );
    }
  }

  @override
  Future<void> agregarTrabajo({
    required int ordenId,
    required String descripcion,
    required double costoManoObra,
  }) async {
    final orden = await _db.ordenesDao.filaPorId(ordenId);
    if (orden == null) {
      throw OrdenNoEncontradaException(ordenId);
    }
    if (EstadoOrden.desdeNombre(orden.estado).estaCerrada) {
      throw ValidacionException(
        'No se pueden agregar trabajos a una orden cerrada.',
      );
    }
    if (descripcion.trim().isEmpty) {
      throw ValidacionException('Describe el trabajo realizado.');
    }
    if (costoManoObra < 0) {
      throw ValidacionException(
        'El costo de mano de obra no puede ser negativo.',
      );
    }
    await _db.trabajosDao.insertar(
      ordenId: ordenId,
      descripcion: descripcion.trim(),
      costoManoObra: costoManoObra,
    );
  }

  @override
  Future<void> eliminarTrabajo(int trabajoId) async {
    await _db.trabajosDao.eliminar(trabajoId);
  }

  @override
  Future<void> agregarRepuesto({
    required int ordenId,
    required int repuestoId,
    required int cantidad,
  }) async {
    final orden = await _db.ordenesDao.filaPorId(ordenId);
    if (orden == null) {
      throw OrdenNoEncontradaException(ordenId);
    }
    if (EstadoOrden.desdeNombre(orden.estado).estaCerrada) {
      throw ValidacionException(
        'No se pueden agregar repuestos a una orden cerrada.',
      );
    }
    if (cantidad <= 0) {
      throw ValidacionException('La cantidad debe ser mayor que cero.');
    }
    final repuesto = await _db.repuestosDao.porId(repuestoId);
    if (repuesto == null) {
      throw RepuestoNoEncontradoException(repuestoId);
    }
    try {
      await _db.usosRepuestoDao.registrarUso(
        ordenId: ordenId,
        repuestoId: repuestoId,
        cantidad: cantidad,
        precioUnitario: repuesto.precio,
      );
    } on StockInsuficienteError catch (error) {
      throw StockInsuficienteException(
        nombreRepuesto: error.nombre,
        disponible: error.disponible,
        solicitado: error.solicitado,
      );
    } on RepuestoNoExisteError {
      throw RepuestoNoEncontradoException(repuestoId);
    } on CantidadInvalidaError {
      throw ValidacionException('La cantidad debe ser mayor que cero.');
    }
  }

  @override
  Future<void> eliminarUsoRepuesto(int usoId) async {
    await _db.usosRepuestoDao.eliminarUso(usoId);
  }

  @override
  Stream<List<CargaTrabajo>> watchCargaTrabajo() {
    final controlador = StreamController<List<CargaTrabajo>>();
    var tecnicos = <TecnicoRow>[];
    var ordenes = <OrdenConDetalle>[];
    var tecnicosListos = false;
    var ordenesListas = false;
    var suscripciones = <StreamSubscription<dynamic>>[];

    void emitir() {
      if (!tecnicosListos || !ordenesListas) return;
      final resultado = <CargaTrabajo>[];
      for (final tecnico in tecnicos) {
        final abiertas = <Orden>[];
        for (final fila in ordenes) {
          if (fila.orden.tecnicoId != tecnico.id) continue;
          if (!EstadoOrden.desdeNombre(fila.orden.estado).esAbierta) continue;
          abiertas.add(fila.aDominio());
        }
        resultado.add(
          CargaTrabajo(
            tecnico: Tecnico(id: tecnico.id, nombre: tecnico.nombre),
            ordenesAbiertas: abiertas,
          ),
        );
      }
      controlador.add(resultado);
    }

    controlador
      ..onListen = () {
        suscripciones = [
          _db.tecnicosDao.watchTodos().listen((filas) {
            tecnicos = filas;
            tecnicosListos = true;
            emitir();
          }),
          _db.ordenesDao.watchTodas().listen((filas) {
            ordenes = filas;
            ordenesListas = true;
            emitir();
          }),
        ];
      }
      ..onCancel = () async {
        for (final suscripcion in suscripciones) {
          await suscripcion.cancel();
        }
        suscripciones = [];
      };

    return controlador.stream;
  }

  @override
  Future<List<HistorialEquipoItem>> historialPorEquipo(int equipoId) async {
    final filas = await _db.ordenesDao.porEquipo(equipoId);
    final resultado = <HistorialEquipoItem>[];
    for (final fila in filas) {
      final manoObra = await _db.trabajosDao.totalManoObra(fila.orden.id);
      final repuestos =
          await _db.usosRepuestoDao.totalRepuestos(fila.orden.id);
      final usos = await _db.usosRepuestoDao.porOrden(fila.orden.id);
      var cantidadRepuestos = 0;
      for (final uso in usos) {
        cantidadRepuestos += uso.uso.cantidad;
      }
      resultado.add(
        HistorialEquipoItem(
          ordenId: fila.orden.id,
          fallaReportada: fila.orden.fallaReportada,
          estado: EstadoOrden.desdeNombre(fila.orden.estado),
          fechaRecepcion: fila.orden.fechaRecepcion,
          fechaEntrega: fila.orden.fechaEntrega,
          tecnicoNombre: fila.tecnico?.nombre,
          costoTotal: manoObra + repuestos,
          repuestosUsados: cantidadRepuestos,
        ),
      );
    }
    return resultado;
  }

  @override
  Future<List<HistorialClienteItem>> historialPorCliente(
    int clienteId,
  ) async {
    final equipos = await _db.equiposDao.porCliente(clienteId);
    final resultado = <HistorialClienteItem>[];
    for (final equipo in equipos) {
      final filas = await _db.ordenesDao.porEquipo(equipo.equipo.id);
      for (final fila in filas) {
        final manoObra = await _db.trabajosDao.totalManoObra(fila.orden.id);
        final repuestos =
            await _db.usosRepuestoDao.totalRepuestos(fila.orden.id);
        resultado.add(
          HistorialClienteItem(
            ordenId: fila.orden.id,
            equipoDescripcion:
                '${TipoEquipo.desdeNombre(equipo.equipo.tipo).etiqueta} '
                '${equipo.equipo.marca} ${equipo.equipo.modelo}',
            numeroSerie: equipo.equipo.numeroSerie,
            fallaReportada: fila.orden.fallaReportada,
            estado: EstadoOrden.desdeNombre(fila.orden.estado),
            fechaRecepcion: fila.orden.fechaRecepcion,
            fechaEntrega: fila.orden.fechaEntrega,
            costoTotal: manoObra + repuestos,
          ),
        );
      }
    }
    resultado.sort((a, b) => b.fechaRecepcion.compareTo(a.fechaRecepcion));
    return resultado;
  }
}

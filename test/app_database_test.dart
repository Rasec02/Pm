import 'package:app_tu_solution/data/local/app_database.dart';
import 'package:app_tu_solution/data/repositories/cliente_repository_impl.dart';
import 'package:app_tu_solution/data/repositories/equipo_repository_impl.dart';
import 'package:app_tu_solution/data/repositories/orden_repository_impl.dart';
import 'package:app_tu_solution/data/repositories/repuesto_repository_impl.dart';
import 'package:app_tu_solution/domain/enums/estado_orden.dart';
import 'package:app_tu_solution/domain/enums/tipo_equipo.dart';
import 'package:app_tu_solution/domain/exceptions/app_exceptions.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ClienteRepositoryImpl clientes;
  late EquipoRepositoryImpl equipos;
  late OrdenRepositoryImpl ordenes;
  late RepuestoRepositoryImpl repuestos;

  setUp(() {
    db = AppDatabase.paraPruebas(NativeDatabase.memory());
    clientes = ClienteRepositoryImpl(db);
    equipos = EquipoRepositoryImpl(db);
    ordenes = OrdenRepositoryImpl(db);
    repuestos = RepuestoRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> prepararOrden() async {
    final clienteId = await clientes.crear(
      nombre: 'Dueño de prueba',
      telefono: '8888-0000',
    );
    final equipoId = await equipos.crear(
      tipo: TipoEquipo.celular,
      marca: 'Samsung',
      modelo: 'A51',
      numeroSerie: 'SN-001',
      clienteId: clienteId,
    );
    return ordenes.crear(
      equipoId: equipoId,
      fallaReportada: 'No enciende',
    );
  }

  test('el seed crea 3 técnicos y repuestos de ejemplo', () async {
    final tecnicos = await db.tecnicosDao.todos();
    expect(tecnicos.length, 3);

    final inventario = await repuestos.todos();
    expect(inventario, isNotEmpty);
    expect(
      inventario.any((repuesto) => repuesto.codigo == 'PAN-IP11'),
      isTrue,
    );
  });

  test('tomar una orden asigna responsable y cambia a en reparación',
      () async {
    final ordenId = await prepararOrden();
    final tecnico = (await db.tecnicosDao.todos()).first;

    await ordenes.tomar(ordenId: ordenId, tecnicoId: tecnico.id);

    final detalle = await ordenes.detalle(ordenId);
    expect(detalle, isNotNull);
    expect(detalle!.orden.estado, EstadoOrden.enReparacion);
    expect(detalle.orden.tecnicoId, tecnico.id);
  });

  test('una orden no puede ser tomada dos veces', () async {
    final ordenId = await prepararOrden();
    final tecnicos = await db.tecnicosDao.todos();

    await ordenes.tomar(ordenId: ordenId, tecnicoId: tecnicos[0].id);

    await expectLater(
      ordenes.tomar(ordenId: ordenId, tecnicoId: tecnicos[1].id),
      throwsA(isA<OrdenYaTomadaException>()),
    );
  });

  test('agregar repuesto descuenta stock y calcula el costo total', () async {
    final ordenId = await prepararOrden();
    final tecnico = (await db.tecnicosDao.todos()).first;
    await ordenes.tomar(ordenId: ordenId, tecnicoId: tecnico.id);

    final repuesto = (await repuestos.todos())
        .firstWhere((item) => item.codigo == 'PAN-IP11');

    await ordenes.agregarTrabajo(
      ordenId: ordenId,
      descripcion: 'Cambio de pantalla',
      costoManoObra: 30,
    );
    await ordenes.agregarRepuesto(
      ordenId: ordenId,
      repuestoId: repuesto.id,
      cantidad: 2,
    );

    final detalle = await ordenes.detalle(ordenId);
    final actualizado = await repuestos.porId(repuesto.id);

    expect(actualizado!.existencias, repuesto.existencias - 2);
    expect(detalle!.costo.manoObra, 30);
    expect(detalle.costo.repuestos, repuesto.precio * 2);
    expect(detalle.costo.total, 30 + repuesto.precio * 2);
  });

  test('no se puede usar más stock del disponible', () async {
    final ordenId = await prepararOrden();
    final tecnico = (await db.tecnicosDao.todos()).first;
    await ordenes.tomar(ordenId: ordenId, tecnicoId: tecnico.id);

    final agotado = (await repuestos.todos())
        .firstWhere((item) => item.codigo == 'PEG-ADHESIVO');
    expect(agotado.existencias, 0);

    await expectLater(
      ordenes.agregarRepuesto(
        ordenId: ordenId,
        repuestoId: agotado.id,
        cantidad: 1,
      ),
      throwsA(isA<StockInsuficienteException>()),
    );
  });

  test('flujo de estados y fecha de entrega al entregar', () async {
    final ordenId = await prepararOrden();
    final tecnico = (await db.tecnicosDao.todos()).first;
    await ordenes.tomar(ordenId: ordenId, tecnicoId: tecnico.id);

    await ordenes.cambiarEstado(
      ordenId: ordenId,
      destino: EstadoOrden.lista,
    );
    await ordenes.cambiarEstado(
      ordenId: ordenId,
      destino: EstadoOrden.entregada,
    );

    final detalle = await ordenes.detalle(ordenId);
    expect(detalle!.orden.estado, EstadoOrden.entregada);
    expect(detalle.orden.fechaEntrega, isNotNull);
  });

  test('no se permite saltar de recibida a entregada', () async {
    final ordenId = await prepararOrden();
    await expectLater(
      ordenes.cambiarEstado(
        ordenId: ordenId,
        destino: EstadoOrden.entregada,
      ),
      throwsA(isA<TransicionInvalidaException>()),
    );
  });

  test('el historial por equipo y por cliente devuelve las órdenes',
      () async {
    final ordenId = await prepararOrden();
    final orden = (await ordenes.detalle(ordenId))!.orden;

    final porEquipo = await ordenes.historialPorEquipo(orden.equipoId);
    final porCliente = await ordenes.historialPorCliente(orden.clienteId);

    expect(porEquipo.length, 1);
    expect(porEquipo.first.ordenId, ordenId);
    expect(porCliente.length, 1);
    expect(porCliente.first.ordenId, ordenId);
  });

  test('el umbral de stock bajo se puede configurar y filtrar', () async {
    final umbralInicial = await db.configuracionDao.umbralStockBajo();
    expect(umbralInicial, 3);

    await db.configuracionDao.guardarUmbralStockBajo(10);
    final bajos = await repuestos.watchStockBajo(10).first;
    expect(bajos, isNotEmpty);

    await db.configuracionDao.guardarUmbralStockBajo(0);
    final agotados = await repuestos.watchStockBajo(0).first;
    expect(
      agotados.every((repuesto) => repuesto.existencias <= 0),
      isTrue,
    );
  });

  test('devolver un repuesto regresa el stock al inventario', () async {
    final ordenId = await prepararOrden();
    final tecnico = (await db.tecnicosDao.todos()).first;
    await ordenes.tomar(ordenId: ordenId, tecnicoId: tecnico.id);

    final repuesto = (await repuestos.todos())
        .firstWhere((item) => item.codigo == 'DIS-SSD-480');
    await ordenes.agregarRepuesto(
      ordenId: ordenId,
      repuestoId: repuesto.id,
      cantidad: 3,
    );
    var detalle = await ordenes.detalle(ordenId);
    expect(detalle!.repuestosUsados, hasLength(1));
    expect(detalle.costo.repuestos, repuesto.precio * 3);

    await ordenes.eliminarUsoRepuesto(detalle.repuestosUsados.first.id);

    detalle = await ordenes.detalle(ordenId);
    final actualizado = await repuestos.porId(repuesto.id);
    expect(detalle!.repuestosUsados, isEmpty);
    expect(detalle.costo.repuestos, 0);
    expect(actualizado!.existencias, repuesto.existencias);
  });

  test('la carga de trabajo sólo cuenta órdenes abiertas del técnico',
      () async {
    final tecnico = (await db.tecnicosDao.todos()).first;
    final ordenId = await prepararOrden();
    await ordenes.tomar(ordenId: ordenId, tecnicoId: tecnico.id);

    var cargas = await ordenes.watchCargaTrabajo().first;
    var propia = cargas.firstWhere((carga) => carga.tecnico.id == tecnico.id);
    expect(propia.total, 1);
    expect(propia.enReparacion, 1);

    await ordenes.cambiarEstado(ordenId: ordenId, destino: EstadoOrden.lista);
    await ordenes.cambiarEstado(
      ordenId: ordenId,
      destino: EstadoOrden.entregada,
    );

    cargas = await ordenes.watchCargaTrabajo().first;
    propia = cargas.firstWhere((carga) => carga.tecnico.id == tecnico.id);
    expect(propia.total, 0);
  });
}

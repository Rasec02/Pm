import '../entities/carga_trabajo.dart';
import '../entities/detalle_orden.dart';
import '../entities/historial_item.dart';
import '../entities/orden.dart';
import '../enums/estado_orden.dart';

/// Contrato de acceso a órdenes de reparación y su historial.
abstract class OrdenRepository {
  /// Órdenes abiertas con filtros opcionales por estado y por técnico.
  Stream<List<Orden>> watchAbiertas({EstadoOrden? estado, int? tecnicoId});

  /// Todas las órdenes (abiertas y cerradas).
  Stream<List<Orden>> watchTodas();

  /// Detalle completo de una orden (trabajos, repuestos y costo total).
  Future<DetalleOrden?> detalle(int ordenId);

  /// Detalle reactivo: se recalcula al cambiar la orden, sus trabajos o sus
  /// repuestos.
  Stream<DetalleOrden?> watchDetalle(int ordenId);

  Future<int> crear({required int equipoId, required String fallaReportada});

  /// Asigna el técnico responsable y pasa la orden a `enReparacion`.
  Future<void> tomar({required int ordenId, required int tecnicoId});

  Future<void> cambiarEstado({
    required int ordenId,
    required EstadoOrden destino,
  });

  Future<void> agregarTrabajo({
    required int ordenId,
    required String descripcion,
    required double costoManoObra,
  });

  Future<void> eliminarTrabajo(int trabajoId);

  /// Descuenta stock y registra el repuesto usado, todo en una transacción.
  Future<void> agregarRepuesto({
    required int ordenId,
    required int repuestoId,
    required int cantidad,
  });

  Future<void> eliminarUsoRepuesto(int usoId);

  /// Carga de trabajo (órdenes abiertas) por técnico.
  Stream<List<CargaTrabajo>> watchCargaTrabajo();

  Future<List<HistorialEquipoItem>> historialPorEquipo(int equipoId);

  Future<List<HistorialClienteItem>> historialPorCliente(int clienteId);
}

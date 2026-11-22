import '../enums/estado_orden.dart';

/// Elemento del historial de reparaciones de un equipo.
class HistorialEquipoItem {
  const HistorialEquipoItem({
    required this.ordenId,
    required this.fallaReportada,
    required this.estado,
    required this.fechaRecepcion,
    required this.fechaEntrega,
    required this.tecnicoNombre,
    required this.costoTotal,
    required this.repuestosUsados,
  });

  final int ordenId;
  final String fallaReportada;
  final EstadoOrden estado;
  final DateTime fechaRecepcion;
  final DateTime? fechaEntrega;
  final String? tecnicoNombre;
  final double costoTotal;
  final int repuestosUsados;
}

/// Elemento del historial de reparaciones de un cliente.
class HistorialClienteItem {
  const HistorialClienteItem({
    required this.ordenId,
    required this.equipoDescripcion,
    required this.numeroSerie,
    required this.fallaReportada,
    required this.estado,
    required this.fechaRecepcion,
    required this.fechaEntrega,
    required this.costoTotal,
  });

  final int ordenId;
  final String equipoDescripcion;
  final String numeroSerie;
  final String fallaReportada;
  final EstadoOrden estado;
  final DateTime fechaRecepcion;
  final DateTime? fechaEntrega;
  final double costoTotal;
}

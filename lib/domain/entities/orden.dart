import '../enums/estado_orden.dart';

/// Orden de reparación con los datos de equipo, dueño y responsable ya
/// resueltos para mostrarlos en pantalla sin consultas adicionales.
class Orden {
  const Orden({
    required this.id,
    required this.equipoId,
    required this.fallaReportada,
    required this.estado,
    required this.fechaRecepcion,
    required this.fechaEntrega,
    required this.tipoEquipo,
    required this.marca,
    required this.modelo,
    required this.numeroSerie,
    required this.clienteId,
    required this.clienteNombre,
    required this.clienteTelefono,
    required this.tecnicoId,
    required this.tecnicoNombre,
  });

  final int id;
  final int equipoId;
  final String fallaReportada;
  final EstadoOrden estado;
  final DateTime fechaRecepcion;
  final DateTime? fechaEntrega;

  // Datos del equipo.
  final String tipoEquipo;
  final String marca;
  final String modelo;
  final String numeroSerie;

  // Datos del dueño.
  final int clienteId;
  final String clienteNombre;
  final String clienteTelefono;

  // Responsable (null mientras nadie la haya tomado).
  final int? tecnicoId;
  final String? tecnicoNombre;

  bool get tieneResponsable => tecnicoId != null;

  bool get estaAbierta => estado.esAbierta;

  String get descripcionEquipo => '$tipoEquipo $marca $modelo';

  String get responsableTexto => tecnicoNombre ?? 'Sin asignar';
}

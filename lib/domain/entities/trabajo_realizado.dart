/// Trabajo de mano de obra registrado en una orden.
class TrabajoRealizado {
  const TrabajoRealizado({
    required this.id,
    required this.ordenId,
    required this.descripcion,
    required this.costoManoObra,
    required this.fechaRegistro,
  });

  final int id;
  final int ordenId;
  final String descripcion;
  final double costoManoObra;
  final DateTime fechaRegistro;
}

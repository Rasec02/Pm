import '../local/app_database.dart';

/// Resultado de unir una orden con su equipo, su dueño y su técnico.
///
/// Es un modelo de la capa de datos: el repositorio lo convierte en la
/// entidad de dominio `Orden`.
class OrdenConDetalle {
  const OrdenConDetalle({
    required this.orden,
    required this.equipo,
    required this.cliente,
    required this.tecnico,
  });

  final OrdenRow orden;
  final EquipoRow equipo;
  final ClienteRow cliente;
  final TecnicoRow? tecnico;
}

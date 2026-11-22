import '../enums/tipo_equipo.dart';

/// Equipo recibido en el taller (celular, tablet o laptop).
class Equipo {
  const Equipo({
    required this.id,
    required this.tipo,
    required this.marca,
    required this.modelo,
    required this.numeroSerie,
    required this.clienteId,
  });

  final int id;
  final TipoEquipo tipo;
  final String marca;
  final String modelo;
  final String numeroSerie;
  final int clienteId;

  /// Descripción corta usada en listas y tarjetas.
  String get descripcion => '${tipo.etiqueta} $marca $modelo';
}

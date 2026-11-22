import '../enums/estado_orden.dart';
import 'orden.dart';
import 'tecnico.dart';

/// Carga de trabajo de un técnico: sus órdenes abiertas asignadas.
class CargaTrabajo {
  const CargaTrabajo({
    required this.tecnico,
    required this.ordenesAbiertas,
  });

  final Tecnico tecnico;
  final List<Orden> ordenesAbiertas;

  int get total => ordenesAbiertas.length;

  int get enReparacion => ordenesAbiertas
      .where((orden) => orden.estado == EstadoOrden.enReparacion)
      .length;

  int get listas => ordenesAbiertas
      .where((orden) => orden.estado == EstadoOrden.lista)
      .length;
}

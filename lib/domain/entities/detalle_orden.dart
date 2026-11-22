import 'costo_orden.dart';
import 'orden.dart';
import 'trabajo_realizado.dart';
import 'uso_repuesto.dart';

/// Todo lo que se muestra en la pantalla de detalle de una orden.
class DetalleOrden {
  const DetalleOrden({
    required this.orden,
    required this.trabajos,
    required this.repuestosUsados,
    required this.costo,
  });

  final Orden orden;
  final List<TrabajoRealizado> trabajos;
  final List<UsoRepuesto> repuestosUsados;
  final CostoOrden costo;
}

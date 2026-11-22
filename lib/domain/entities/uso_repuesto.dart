/// Repuesto usado en una orden, con los datos del repuesto ya resueltos.
class UsoRepuesto {
  const UsoRepuesto({
    required this.id,
    required this.ordenId,
    required this.repuestoId,
    required this.codigo,
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.fechaRegistro,
  });

  final int id;
  final int ordenId;
  final int repuestoId;
  final String codigo;
  final String nombre;
  final int cantidad;
  final double precioUnitario;
  final DateTime fechaRegistro;

  /// Costo del repuesto dentro de la orden: cantidad x precio unitario.
  double get subtotal => cantidad * precioUnitario;
}

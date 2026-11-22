/// Repuesto en inventario.
class Repuesto {
  const Repuesto({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.precio,
    required this.existencias,
  });

  final int id;
  final String codigo;
  final String nombre;
  final double precio;
  final int existencias;

  /// Indica si las existencias están en o por debajo del [umbral].
  bool esStockBajo(int umbral) => existencias <= umbral;

  bool get agotado => existencias <= 0;
}

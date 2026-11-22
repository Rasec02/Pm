/// Desglose del costo de una orden de reparación.
class CostoOrden {
  const CostoOrden({
    required this.manoObra,
    required this.repuestos,
  });

  /// Suma de los trabajos de mano de obra.
  final double manoObra;

  /// Suma de (cantidad x precio) de los repuestos usados.
  final double repuestos;

  /// Costo total de la orden.
  double get total => manoObra + repuestos;
}

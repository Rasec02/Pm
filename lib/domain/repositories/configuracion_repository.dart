/// Contrato de acceso a la configuración de la app.
abstract class ConfiguracionRepository {
  /// Umbral de stock bajo configurado (por defecto 3).
  Stream<int> watchUmbralStockBajo();

  Future<int> umbralStockBajo();

  Future<void> guardarUmbralStockBajo(int umbral);
}

/// Constantes de negocio compartidas por las capas de la aplicación.
class ConfiguracionKeys {
  const ConfiguracionKeys._();

  /// Clave con la que se guarda el umbral de stock bajo en la tabla de
  /// configuración.
  static const String umbralStockBajo = 'umbral_stock_bajo';

  /// Valor por defecto del umbral de stock bajo.
  static const int umbralStockBajoPorDefecto = 3;
}

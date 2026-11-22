/// Tipos de equipo que atiende el taller.
enum TipoEquipo {
  celular('Celular'),
  tablet('Tablet'),
  laptop('Laptop');

  const TipoEquipo(this.etiqueta);

  /// Texto legible para la interfaz.
  final String etiqueta;

  /// Reconstruye el enum desde el nombre guardado en la base de datos.
  static TipoEquipo desdeNombre(String nombre) {
    for (final tipo in values) {
      if (tipo.name == nombre) return tipo;
    }
    return TipoEquipo.celular;
  }
}

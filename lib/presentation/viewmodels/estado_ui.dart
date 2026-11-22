/// Estado de una operación asíncrona disparada por el usuario (guardar,
/// eliminar, tomar una orden, etc.).
///
/// Se usa para mostrar errores y para deshabilitar botones mientras se ejecuta
/// la acción, sin mezclar esa información con los datos de la pantalla.
class EstadoAccion {
  const EstadoAccion({
    this.enProgreso = false,
    this.mensajeError,
    this.mensajeExito,
  });

  final bool enProgreso;
  final String? mensajeError;
  final String? mensajeExito;

  bool get tieneError => mensajeError != null;

  bool get tieneExito => mensajeExito != null;

  static const EstadoAccion inicial = EstadoAccion();

  /// Devuelve el mensaje nuevo de una acción.
  ///
  /// Compara con el estado anterior para que el `SnackBar` se muestre una sola
  /// vez y no en cada rebuild.
  static String? procesarMensaje(
    EstadoAccion? anterior,
    EstadoAccion actual, {
    required bool exito,
  }) {
    final mensaje = exito ? actual.mensajeExito : actual.mensajeError;
    final anteriorMensaje = anterior == null
        ? null
        : (exito ? anterior.mensajeExito : anterior.mensajeError);
    if (mensaje == null || mensaje == anteriorMensaje) return null;
    return mensaje;
  }
}

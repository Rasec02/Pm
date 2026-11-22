/// Estados posibles de una orden de reparación.
///
/// Flujo principal:
/// `recibida -> enReparacion -> lista -> entregada`.
///
/// `cancelada` solo es alcanzable desde `recibida` o `enReparacion`.
enum EstadoOrden {
  recibida('Recibida'),
  enReparacion('En reparación'),
  lista('Lista para entregar'),
  entregada('Entregada'),
  cancelada('Cancelada');

  const EstadoOrden(this.etiqueta);

  /// Texto legible para la interfaz.
  final String etiqueta;

  /// Reconstruye el enum desde el nombre guardado en la base de datos.
  static EstadoOrden desdeNombre(String nombre) {
    for (final estado in values) {
      if (estado.name == nombre) return estado;
    }
    return EstadoOrden.recibida;
  }

  /// Una orden está abierta mientras no se entregue ni se cancele.
  bool get esAbierta =>
      this == EstadoOrden.recibida ||
      this == EstadoOrden.enReparacion ||
      this == EstadoOrden.lista;

  bool get estaCerrada => !esAbierta;

  /// Estados a los que se puede avanzar desde el estado actual.
  List<EstadoOrden> get siguientes {
    switch (this) {
      case EstadoOrden.recibida:
        return const [EstadoOrden.enReparacion, EstadoOrden.cancelada];
      case EstadoOrden.enReparacion:
        return const [EstadoOrden.lista, EstadoOrden.cancelada];
      case EstadoOrden.lista:
        return const [EstadoOrden.entregada];
      case EstadoOrden.entregada:
      case EstadoOrden.cancelada:
        return const [];
    }
  }

  /// Valida una transición de estado según las reglas del negocio.
  bool puedeCambiarA(EstadoOrden destino) => siguientes.contains(destino);
}

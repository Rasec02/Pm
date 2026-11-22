import '../enums/estado_orden.dart';

/// Excepciones de negocio que la capa de presentación traduce a mensajes.
sealed class AppException implements Exception {
  AppException(this.message);

  /// Mensaje listo para mostrar al usuario.
  final String message;

  @override
  String toString() => message;
}

/// Error de validación de formularios o de reglas de negocio.
class ValidacionException extends AppException {
  ValidacionException(super.message);
}

/// La orden solicitada no existe en la base de datos.
class OrdenNoEncontradaException extends AppException {
  OrdenNoEncontradaException(int ordenId)
      : super('La orden #$ordenId no existe.');
}

/// La orden ya tiene un técnico responsable asignado.
class OrdenYaTomadaException extends AppException {
  OrdenYaTomadaException({required int ordenId, required int tecnicoId})
      : super(
          'La orden #$ordenId ya fue tomada por el técnico #$tecnicoId. '
          'Solo puede haber un responsable.',
        );
}

/// Transición de estado no permitida por las reglas del negocio.
class TransicionInvalidaException extends AppException {
  TransicionInvalidaException({
    required EstadoOrden actual,
    required EstadoOrden destino,
  }) : super(
          'No se puede cambiar una orden de ${actual.etiqueta} '
          'a ${destino.etiqueta}.',
        );
}

/// No hay existencias suficientes para registrar el uso de un repuesto.
class StockInsuficienteException extends AppException {
  StockInsuficienteException({
    required String nombreRepuesto,
    required int disponible,
    required int solicitado,
  }) : super(
          'Stock insuficiente de $nombreRepuesto: '
          'disponible $disponible, solicitado $solicitado.',
        );
}

/// El repuesto solicitado no existe.
class RepuestoNoEncontradoException extends AppException {
  RepuestoNoEncontradoException(int repuestoId)
      : super('El repuesto #$repuestoId no existe.');
}

/// El técnico indicado no existe.
class TecnicoNoEncontradoException extends AppException {
  TecnicoNoEncontradoException(int tecnicoId)
      : super('El técnico #$tecnicoId no existe.');
}

/// El registro no se puede eliminar porque está referenciado por otros datos.
class RegistroEnUsoException extends AppException {
  RegistroEnUsoException(super.message);
}

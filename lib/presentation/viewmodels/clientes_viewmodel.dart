import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/exceptions/app_exceptions.dart';
import '../providers/repository_providers.dart';
import 'estado_ui.dart';

/// Acciones de alta/edición/baja de clientes.
///
/// Devuelven `true` cuando la operación se completó, para que la vista pueda
/// cerrar el diálogo o refrescar la lista.
final clientesAccionesProvider =
    NotifierProvider<ClientesAccionesNotifier, EstadoAccion>(
  ClientesAccionesNotifier.new,
);

class ClientesAccionesNotifier extends Notifier<EstadoAccion> {
  @override
  EstadoAccion build() => EstadoAccion.inicial;

  /// Crea un cliente y devuelve su id (o `null` si falló).
  Future<int?> crear({
    required String nombre,
    required String telefono,
  }) async {
    state = const EstadoAccion(enProgreso: true);
    try {
      final id = await ref.read(clienteRepositoryProvider).crear(
            nombre: nombre,
            telefono: telefono,
          );
      state = const EstadoAccion(mensajeExito: 'Cliente registrado.');
      return id;
    } on AppException catch (error) {
      state = EstadoAccion(mensajeError: error.message);
      return null;
    } catch (error) {
      state = EstadoAccion(mensajeError: 'Error inesperado: $error');
      return null;
    }
  }

  Future<bool> actualizar({
    required int id,
    required String nombre,
    required String telefono,
  }) async {
    return _ejecutar(
      () => ref.read(clienteRepositoryProvider).actualizar(
            id: id,
            nombre: nombre,
            telefono: telefono,
          ),
      exito: 'Cliente actualizado.',
    );
  }

  Future<bool> eliminar(int id) async {
    return _ejecutar(
      () => ref.read(clienteRepositoryProvider).eliminar(id),
      exito: 'Cliente eliminado.',
    );
  }

  Future<bool> _ejecutar(
    Future<void> Function() accion, {
    required String exito,
  }) async {
    state = const EstadoAccion(enProgreso: true);
    try {
      await accion();
      state = EstadoAccion(mensajeExito: exito);
      return true;
    } on AppException catch (error) {
      state = EstadoAccion(mensajeError: error.message);
      return false;
    } catch (error) {
      state = EstadoAccion(mensajeError: 'Error inesperado: $error');
      return false;
    }
  }
}

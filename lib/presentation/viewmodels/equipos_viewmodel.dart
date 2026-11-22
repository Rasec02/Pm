import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums/tipo_equipo.dart';
import '../../domain/exceptions/app_exceptions.dart';
import '../providers/repository_providers.dart';
import 'estado_ui.dart';

/// Acciones de alta y baja de equipos.
final equiposAccionesProvider =
    NotifierProvider<EquiposAccionesNotifier, EstadoAccion>(
  EquiposAccionesNotifier.new,
);

class EquiposAccionesNotifier extends Notifier<EstadoAccion> {
  @override
  EstadoAccion build() => EstadoAccion.inicial;

  /// Crea un equipo y devuelve su id (o `null` si falló).
  Future<int?> crear({
    required TipoEquipo tipo,
    required String marca,
    required String modelo,
    required String numeroSerie,
    required int clienteId,
  }) async {
    state = const EstadoAccion(enProgreso: true);
    try {
      final id = await ref.read(equipoRepositoryProvider).crear(
            tipo: tipo,
            marca: marca,
            modelo: modelo,
            numeroSerie: numeroSerie,
            clienteId: clienteId,
          );
      state = const EstadoAccion(mensajeExito: 'Equipo registrado.');
      return id;
    } on AppException catch (error) {
      state = EstadoAccion(mensajeError: error.message);
      return null;
    } catch (error) {
      state = EstadoAccion(mensajeError: 'Error inesperado: $error');
      return null;
    }
  }

  Future<bool> eliminar(int id) async {
    state = const EstadoAccion(enProgreso: true);
    try {
      await ref.read(equipoRepositoryProvider).eliminar(id);
      state = const EstadoAccion(mensajeExito: 'Equipo eliminado.');
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

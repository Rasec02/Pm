import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/exceptions/app_exceptions.dart';
import '../providers/repository_providers.dart';
import '../providers/usecase_providers.dart';
import 'estado_ui.dart';

/// Acciones del inventario: crear, editar, ajustar existencias y eliminar.
final inventarioAccionesProvider =
    NotifierProvider<InventarioAccionesNotifier, EstadoAccion>(
  InventarioAccionesNotifier.new,
);

class InventarioAccionesNotifier extends Notifier<EstadoAccion> {
  @override
  EstadoAccion build() => EstadoAccion.inicial;

  Future<bool> crear({
    required String codigo,
    required String nombre,
    required double precio,
    required int existencias,
  }) {
    return _ejecutar(
      () => ref.read(guardarRepuestoUseCaseProvider).crear(
            codigo: codigo,
            nombre: nombre,
            precio: precio,
            existencias: existencias,
          ),
      exito: 'Repuesto agregado al inventario.',
    );
  }

  Future<bool> actualizar({
    required int id,
    required String codigo,
    required String nombre,
    required double precio,
    required int existencias,
  }) {
    return _ejecutar(
      () => ref.read(guardarRepuestoUseCaseProvider).actualizar(
            id: id,
            codigo: codigo,
            nombre: nombre,
            precio: precio,
            existencias: existencias,
          ),
      exito: 'Repuesto actualizado.',
    );
  }

  Future<bool> ajustarExistencias({
    required int repuestoId,
    required int delta,
  }) {
    return _ejecutar(
      () => ref.read(ajustarExistenciasUseCaseProvider).ejecutar(
            repuestoId: repuestoId,
            delta: delta,
          ),
      exito: 'Existencias actualizadas.',
    );
  }

  Future<bool> eliminar(int id) {
    return _ejecutar(
      () => ref.read(repuestoRepositoryProvider).eliminar(id),
      exito: 'Repuesto eliminado.',
    );
  }

  Future<bool> guardarUmbral(int umbral) async {
    if (umbral < 0) {
      state = const EstadoAccion(
        mensajeError: 'El umbral no puede ser negativo.',
      );
      return false;
    }
    return _ejecutar(
      () => ref
          .read(configuracionRepositoryProvider)
          .guardarUmbralStockBajo(umbral),
      exito: 'Umbral de stock bajo actualizado a $umbral.',
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

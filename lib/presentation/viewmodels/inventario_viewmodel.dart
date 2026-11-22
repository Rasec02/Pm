import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/repuesto.dart';
import '../../domain/exceptions/app_exceptions.dart';
import '../providers/catalogos_providers.dart';
import '../providers/repository_providers.dart';
import '../providers/usecase_providers.dart';
import 'estado_ui.dart';

/// Repuestos del inventario con la alerta de stock bajo ya calculada.
class InventarioViewModel {
  const InventarioViewModel({
    required this.repuestos,
    required this.porAgotarse,
    required this.umbral,
  });

  final List<Repuesto> repuestos;

  /// Repuestos con existencias en o por debajo del umbral, de menor a mayor.
  final List<Repuesto> porAgotarse;

  final int umbral;

  int get agotados => porAgotarse.where((repuesto) => repuesto.agotado).length;

  bool get hayAlerta => porAgotarse.isNotEmpty;

  bool estaBajo(Repuesto repuesto) => repuesto.esStockBajo(umbral);
}

/// ViewModel del inventario: combina la lista de repuestos con el umbral
/// configurado. La vista solo pinta lo que devuelve este provider.
final inventarioViewModelProvider =
    Provider<AsyncValue<InventarioViewModel>>((ref) {
  final repuestosAsync = ref.watch(repuestosProvider);
  final umbral = ref.watch(umbralActualProvider);

  return repuestosAsync.whenData((repuestos) {
    final porAgotarse = <Repuesto>[
      for (final repuesto in repuestos)
        if (repuesto.esStockBajo(umbral)) repuesto,
    ]..sort((a, b) => a.existencias.compareTo(b.existencias));
    return InventarioViewModel(
      repuestos: repuestos,
      porAgotarse: porAgotarse,
      umbral: umbral,
    );
  });
});

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

  Future<bool> guardarUmbral(int umbral) {
    if (umbral < 0) {
      state = const EstadoAccion(
        mensajeError: 'El umbral no puede ser negativo.',
      );
      return Future.value(false);
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

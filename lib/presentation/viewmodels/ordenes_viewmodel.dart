import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/orden.dart';
import '../../domain/enums/estado_orden.dart';
import '../../domain/exceptions/app_exceptions.dart';
import '../providers/repository_providers.dart';
import '../providers/usecase_providers.dart';
import 'estado_ui.dart';

/// Filtros aplicados a la lista de órdenes abiertas.
class FiltroOrdenes {
  const FiltroOrdenes({this.estado, this.tecnicoId});

  final EstadoOrden? estado;
  final int? tecnicoId;

  bool get hayFiltros => estado != null || tecnicoId != null;
}

/// ViewModel de la lista de órdenes abiertas (filtros por estado y técnico).
final filtroOrdenesProvider =
    NotifierProvider<FiltroOrdenesNotifier, FiltroOrdenes>(
  FiltroOrdenesNotifier.new,
);

class FiltroOrdenesNotifier extends Notifier<FiltroOrdenes> {
  @override
  FiltroOrdenes build() => const FiltroOrdenes();

  /// Filtra por estado. Con `null` se quita el filtro de estado.
  void filtrarPorEstado(EstadoOrden? estado) {
    state = FiltroOrdenes(estado: estado, tecnicoId: state.tecnicoId);
  }

  /// Filtra por técnico responsable. Con `null` se quita el filtro.
  void filtrarPorTecnico(int? tecnicoId) {
    state = FiltroOrdenes(estado: state.estado, tecnicoId: tecnicoId);
  }

  void limpiar() {
    state = const FiltroOrdenes();
  }
}

/// Lista reactiva de órdenes abiertas según el filtro vigente.
final ordenesAbiertasProvider = StreamProvider<List<Orden>>((ref) {
  final filtro = ref.watch(filtroOrdenesProvider);
  return ref.watch(ordenRepositoryProvider).watchAbiertas(
        estado: filtro.estado,
        tecnicoId: filtro.tecnicoId,
      );
});

/// Acciones sobre órdenes disparadas desde las vistas.
final ordenesAccionesProvider =
    NotifierProvider<OrdenesAccionesNotifier, EstadoAccion>(
  OrdenesAccionesNotifier.new,
);

class OrdenesAccionesNotifier extends Notifier<EstadoAccion> {
  @override
  EstadoAccion build() => EstadoAccion.inicial;

  Future<bool> recibirEquipo({
    required int equipoId,
    required String fallaReportada,
  }) {
    return _ejecutar(
      () => ref.read(recibirEquipoUseCaseProvider).ejecutar(
            equipoId: equipoId,
            fallaReportada: fallaReportada,
          ),
      exito: 'Equipo recibido. Orden creada.',
    );
  }

  Future<bool> tomarOrden({
    required int ordenId,
    required int tecnicoId,
  }) {
    return _ejecutar(
      () => ref.read(tomarOrdenUseCaseProvider).ejecutar(
            ordenId: ordenId,
            tecnicoId: tecnicoId,
          ),
      exito: 'Orden tomada. Ahora tienes el responsable asignado.',
    );
  }

  Future<bool> cambiarEstado({
    required int ordenId,
    required EstadoOrden destino,
  }) {
    return _ejecutar(
      () => ref.read(cambiarEstadoOrdenUseCaseProvider).ejecutar(
            ordenId: ordenId,
            destino: destino,
          ),
      exito: 'Estado actualizado a ${destino.etiqueta}.',
    );
  }

  Future<bool> agregarTrabajo({
    required int ordenId,
    required String descripcion,
    required double costoManoObra,
  }) {
    return _ejecutar(
      () => ref.read(agregarTrabajoUseCaseProvider).ejecutar(
            ordenId: ordenId,
            descripcion: descripcion,
            costoManoObra: costoManoObra,
          ),
      exito: 'Trabajo registrado.',
    );
  }

  Future<bool> agregarRepuesto({
    required int ordenId,
    required int repuestoId,
    required int cantidad,
  }) {
    return _ejecutar(
      () => ref.read(agregarRepuestoUseCaseProvider).ejecutar(
            ordenId: ordenId,
            repuestoId: repuestoId,
            cantidad: cantidad,
          ),
      exito: 'Repuesto agregado y stock descontado.',
    );
  }

  Future<bool> eliminarTrabajo(int trabajoId) {
    return _ejecutar(
      () => ref
          .read(ordenRepositoryProvider)
          .eliminarTrabajo(trabajoId),
      exito: 'Trabajo eliminado.',
    );
  }

  Future<bool> eliminarUsoRepuesto(int usoId) {
    return _ejecutar(
      () => ref
          .read(ordenRepositoryProvider)
          .eliminarUsoRepuesto(usoId),
      exito: 'Repuesto devuelto al inventario.',
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
      state = EstadoAccion(
        mensajeError: 'Ocurrió un error inesperado: $error',
      );
      return false;
    }
  }
}

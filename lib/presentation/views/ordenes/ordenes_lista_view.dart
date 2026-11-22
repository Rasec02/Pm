import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/catalogos_providers.dart';
import '../../viewmodels/ordenes_viewmodel.dart';
import '../../widgets/estado_carga.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/error_vista.dart';
import '../../widgets/selector_estado.dart';
import '../../widgets/selector_tecnico.dart';
import '../../widgets/tarjeta_orden.dart';
import 'detalle_orden_view.dart';
import 'nueva_orden_view.dart';

/// Pantalla principal: órdenes abiertas con filtros por estado y técnico.
class OrdenesListaView extends ConsumerWidget {
  const OrdenesListaView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(filtroOrdenesProvider);
    final ordenesAsync = ref.watch(ordenesAbiertasProvider);
    final tecnicosAsync = ref.watch(tecnicosProvider);

    return Column(
      children: [
        SelectorEstado(
          seleccionado: filtro.estado,
          onCambiar: (estado) =>
              ref.read(filtroOrdenesProvider.notifier).filtrarPorEstado(estado),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: tecnicosAsync.when(
                  loading: () => const SizedBox(height: 56),
                  error: (_, __) => const SizedBox(height: 56),
                  data: (_) => SelectorTecnico(
                    seleccionado: filtro.tecnicoId,
                    etiquetaTodos: 'Todos los técnicos',
                    onCambiar: (tecnicoId) => ref
                        .read(filtroOrdenesProvider.notifier)
                        .filtrarPorTecnico(tecnicoId),
                  ),
                ),
              ),
              if (filtro.hayFiltros)
                IconButton(
                  tooltip: 'Quitar filtros',
                  onPressed: () =>
                      ref.read(filtroOrdenesProvider.notifier).limpiar(),
                  icon: const Icon(Icons.filter_alt_off),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: ordenesAsync.when(
            loading: () => const EstadoCarga(mensaje: 'Cargando órdenes...'),
            error: (error, _) => ErrorVista(
              mensaje: 'No se pudieron cargar las órdenes.\n$error',
              onReintentar: () => ref.invalidate(ordenesAbiertasProvider),
            ),
            data: (ordenes) {
              // El repositorio ya devuelve solo órdenes abiertas; se filtra de
              // nuevo por seguridad ante datos antiguos.
              final abiertas =
                  ordenes.where((orden) => orden.estado.esAbierta).toList();
              if (abiertas.isEmpty) {
                return EstadoVacio(
                  icono: Icons.assignment_outlined,
                  titulo: 'No hay órdenes abiertas',
                  detalle: filtro.hayFiltros
                      ? 'Prueba quitando los filtros de estado o técnico.'
                      : 'Registra un equipo recibido para crear la primera orden.',
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(ordenesAbiertasProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: abiertas.length,
                  itemBuilder: (context, index) {
                    final orden = abiertas[index];
                    return TarjetaOrden(
                      orden: orden,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => DetalleOrdenView(ordenId: orden.id),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Abre el formulario de nueva orden (se usa desde la pantalla de registro).
Future<void> abrirNuevaOrden(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const NuevaOrdenView()),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formato.dart';
import '../../../domain/entities/detalle_orden.dart';
import '../../../domain/entities/orden.dart';
import '../../../domain/enums/estado_orden.dart';
import '../../providers/catalogos_providers.dart';
import '../../viewmodels/detalle_orden_viewmodel.dart';
import '../../viewmodels/estado_ui.dart';
import '../../viewmodels/ordenes_viewmodel.dart';
import '../../widgets/estado_badge.dart';
import '../../widgets/estado_carga.dart';
import '../../widgets/error_vista.dart';
import 'agregar_repuesto_sheet.dart';
import 'agregar_trabajo_sheet.dart';

/// Detalle completo de una orden: equipo, dueño, falla, estado, responsable,
/// trabajos, repuestos usados, costo total y acciones disponibles.
class DetalleOrdenView extends ConsumerWidget {
  const DetalleOrdenView({super.key, required this.ordenId});

  final int ordenId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detalleAsync = ref.watch(detalleOrdenProvider(ordenId));

    ref.listen<EstadoAccion>(ordenesAccionesProvider, (anterior, actual) {
      final mensaje = EstadoAccion.procesarMensaje(
        anterior,
        actual,
        exito: actual.tieneExito,
      );
      if (mensaje == null) return;
      _mostrarMensaje(context, mensaje, esError: actual.tieneError);
    });

    return Scaffold(
      appBar: AppBar(title: Text('Orden #$ordenId')),
      body: detalleAsync.when(
        loading: () => const EstadoCarga(mensaje: 'Cargando orden...'),
        error: (error, _) => ErrorVista(
          mensaje: 'No se pudo cargar la orden.\n$error',
          onReintentar: () => ref.invalidate(detalleOrdenProvider(ordenId)),
        ),
        data: (detalle) {
          if (detalle == null) {
            return const ErrorVista(
              mensaje: 'La orden ya no existe.',
            );
          }
          return _ContenidoDetalle(detalle: detalle);
        },
      ),
    );
  }
}

void _mostrarMensaje(
  BuildContext context,
  String mensaje, {
  bool esError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? AppColors.error : AppColors.exito,
      ),
    );
}

class _ContenidoDetalle extends ConsumerWidget {
  const _ContenidoDetalle({required this.detalle});

  final DetalleOrden detalle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orden = detalle.orden;
    final acciones = ref.watch(ordenesAccionesProvider);
    final enProgreso = acciones.enProgreso;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _CabeceraOrden(orden: orden),
        _SeccionEquipoYDueno(orden: orden),
        _SeccionResponsable(orden: orden),
        _SeccionAccionesEstado(orden: orden, habilitado: !enProgreso),
        _SeccionTrabajos(detalle: detalle, habilitado: !enProgreso),
        _SeccionRepuestos(detalle: detalle, habilitado: !enProgreso),
        _SeccionCosto(detalle: detalle),
      ],
    );
  }
}

class _CabeceraOrden extends StatelessWidget {
  const _CabeceraOrden({required this.orden});

  final Orden orden;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          EstadoBadge(estado: orden.estado),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              orden.descripcionEquipo,
              style: tema.textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeccionEquipoYDueno extends StatelessWidget {
  const _SeccionEquipoYDueno({required this.orden});

  final Orden orden;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TituloSeccion(icono: Icons.devices, texto: 'Equipo y dueño'),
            const SizedBox(height: 8),
            _FilaDato(etiqueta: 'Equipo', valor: orden.descripcionEquipo),
            _FilaDato(etiqueta: 'Serie', valor: orden.numeroSerie),
            _FilaDato(etiqueta: 'Dueño', valor: orden.clienteNombre),
            _FilaDato(etiqueta: 'Teléfono', valor: orden.clienteTelefono),
            _FilaDato(
              etiqueta: 'Recepción',
              valor: Formato.fechaHora(orden.fechaRecepcion),
            ),
            _FilaDato(
              etiqueta: 'Entrega',
              valor: Formato.fechaHora(orden.fechaEntrega),
            ),
            const Divider(height: 24),
            Text('Falla reportada', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(orden.fallaReportada),
          ],
        ),
      ),
    );
  }
}

class _SeccionResponsable extends StatelessWidget {
  const _SeccionResponsable({required this.orden});

  final Orden orden;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TituloSeccion(
              icono: Icons.engineering,
              texto: 'Técnico responsable',
            ),
            const SizedBox(height: 8),
            if (orden.tieneResponsable)
              Row(
                children: [
                  const Icon(Icons.verified_user, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      orden.responsableTexto,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              )
            else
              const Text(
                'Sin asignar. Cualquier técnico puede tomar la orden; '
                'solo el primero que la tome queda como responsable.',
              ),
          ],
        ),
      ),
    );
  }
}

class _SeccionAccionesEstado extends ConsumerWidget {
  const _SeccionAccionesEstado({required this.orden, required this.habilitado});

  final Orden orden;
  final bool habilitado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(ordenesAccionesProvider.notifier);
    final tecnicosAsync = ref.watch(tecnicosProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TituloSeccion(
              icono: Icons.play_circle_outline,
              texto: 'Acciones de la orden',
            ),
            const SizedBox(height: 12),
            if (!orden.tieneResponsable)
              tecnicosAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('Error al cargar técnicos: $error'),
                data: (tecnicos) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tomar la orden como:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tecnico in tecnicos)
                          OutlinedButton(
                            onPressed: !habilitado
                                ? null
                                : () => notifier.tomarOrden(
                                      ordenId: orden.id,
                                      tecnicoId: tecnico.id,
                                    ),
                            child: Text(tecnico.nombre),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            if (orden.tieneResponsable) ...[
              Text(
                'Responsable actual: ${orden.responsableTexto}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Una orden ya tomada no puede ser tomada por otro técnico.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (orden.estado.siguientes.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Cambiar estado',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final destino in orden.estado.siguientes)
                    FilledButton.tonalIcon(
                      onPressed: !habilitado
                          ? null
                          : () => _confirmarCambio(context, ref, destino),
                      icon: Icon(
                        destino == EstadoOrden.cancelada
                            ? Icons.cancel_outlined
                            : Icons.arrow_forward,
                        size: 18,
                      ),
                      label: Text('Pasar a ${destino.etiqueta}'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarCambio(
    BuildContext context,
    WidgetRef ref,
    EstadoOrden destino,
  ) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar estado'),
        content: Text(
          '¿Cambiar la orden #${orden.id} a ${destino.etiqueta}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    await ref.read(ordenesAccionesProvider.notifier).cambiarEstado(
          ordenId: orden.id,
          destino: destino,
        );
  }
}

class _SeccionTrabajos extends ConsumerWidget {
  const _SeccionTrabajos({required this.detalle, required this.habilitado});

  final DetalleOrden detalle;
  final bool habilitado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orden = detalle.orden;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: _TituloSeccion(
                    icono: Icons.handyman,
                    texto: 'Trabajos (mano de obra)',
                  ),
                ),
                if (orden.estado.esAbierta)
                  TextButton.icon(
                    onPressed: !habilitado
                        ? null
                        : () => mostrarAgregarTrabajoSheet(context, ref, orden),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Agregar'),
                  ),
              ],
            ),
            if (detalle.trabajos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Todavía no hay trabajos registrados.'),
              ),
            for (final trabajo in detalle.trabajos)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle_outline, size: 20),
                title: Text(trabajo.descripcion),
                subtitle: Text(Formato.fecha(trabajo.fechaRegistro)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(Formato.dinero(trabajo.costoManoObra)),
                    if (orden.estado.esAbierta)
                      IconButton(
                        tooltip: 'Eliminar trabajo',
                        onPressed: !habilitado
                            ? null
                            : () => ref
                                .read(ordenesAccionesProvider.notifier)
                                .eliminarTrabajo(trabajo.id),
                        icon: const Icon(Icons.delete_outline, size: 20),
                      ),
                  ],
                ),
              ),
            const Divider(height: 16),
            Row(
              children: [
                const Text('Subtotal mano de obra'),
                const Spacer(),
                Text(
                  Formato.dinero(detalle.costo.manoObra),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionRepuestos extends ConsumerWidget {
  const _SeccionRepuestos({required this.detalle, required this.habilitado});

  final DetalleOrden detalle;
  final bool habilitado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orden = detalle.orden;
    final umbral = ref.watch(umbralActualProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: _TituloSeccion(
                    icono: Icons.inventory_2_outlined,
                    texto: 'Repuestos usados',
                  ),
                ),
                if (orden.estado.esAbierta)
                  TextButton.icon(
                    onPressed: !habilitado
                        ? null
                        : () => mostrarAgregarRepuestoSheet(context, ref, orden),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Agregar'),
                  ),
              ],
            ),
            if (detalle.repuestosUsados.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Todavía no se usaron repuestos.'),
              ),
            for (final uso in detalle.repuestosUsados)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.memory, size: 20),
                title: Text('${uso.cantidad} x ${uso.nombre}'),
                subtitle: Text(
                  '${uso.codigo} · ${Formato.dinero(uso.precioUnitario)} c/u',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(Formato.dinero(uso.subtotal)),
                    if (orden.estado.esAbierta)
                      IconButton(
                        tooltip: 'Devolver al inventario',
                        onPressed: !habilitado
                            ? null
                            : () => ref
                                .read(ordenesAccionesProvider.notifier)
                                .eliminarUsoRepuesto(uso.id),
                        icon: const Icon(Icons.delete_outline, size: 20),
                      ),
                  ],
                ),
              ),
            const Divider(height: 16),
            Row(
              children: [
                const Text('Subtotal repuestos'),
                const Spacer(),
                Text(
                  Formato.dinero(detalle.costo.repuestos),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Umbral de stock bajo configurado: $umbral unidades.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionCosto extends StatelessWidget {
  const _SeccionCosto({required this.detalle});

  final DetalleOrden detalle;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primario.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.receipt_long),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Costo total de la orden',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              Formato.dinero(detalle.costo.total),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primarioOscuro,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 18),
        const SizedBox(width: 8),
        Text(
          texto,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _FilaDato extends StatelessWidget {
  const _FilaDato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              etiqueta,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

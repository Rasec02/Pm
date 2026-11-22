import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formato.dart';
import '../../../domain/entities/repuesto.dart';
import '../../providers/catalogos_providers.dart';
import '../../viewmodels/estado_ui.dart';
import '../../viewmodels/inventario_viewmodel.dart';
import '../../widgets/estado_carga.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/error_vista.dart';
import 'dialogo_umbral.dart';
import 'formulario_repuesto.dart';

/// Inventario de repuestos con CRUD y alerta de stock bajo.
class InventarioView extends ConsumerWidget {
  const InventarioView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repuestosAsync = ref.watch(repuestosProvider);
    final umbral = ref.watch(umbralActualProvider);

    ref.listen<EstadoAccion>(inventarioAccionesProvider, (anterior, actual) {
      final mensaje = EstadoAccion.procesarMensaje(
        anterior,
        actual,
        exito: actual.tieneExito,
      );
      if (mensaje == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor:
                actual.tieneExito ? AppColors.exito : AppColors.error,
          ),
        );
    });

    return Scaffold(
      body: repuestosAsync.when(
        loading: () => const EstadoCarga(mensaje: 'Cargando inventario...'),
        error: (error, _) => ErrorVista(
          mensaje: 'No se pudo cargar el inventario.\n$error',
          onReintentar: () => ref.invalidate(repuestosProvider),
        ),
        data: (repuestos) {
          final bajos = repuestos
              .where((repuesto) => repuesto.esStockBajo(umbral))
              .toList()
            ..sort((a, b) => a.existencias.compareTo(b.existencias));
          final agotados = bajos.where((repuesto) => repuesto.agotado).length;

          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              _AlertaUmbral(
                umbral: umbral,
                bajos: bajos.length,
                agotados: agotados,
              ),
              if (bajos.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Repuestos por agotarse',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                for (final repuesto in bajos)
                  _TarjetaRepuesto(
                    repuesto: repuesto,
                    umbral: umbral,
                    resaltado: true,
                  ),
                const Divider(height: 24),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Inventario completo (${repuestos.length})',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (repuestos.isEmpty)
                const EstadoVacio(
                  icono: Icons.inventory_2_outlined,
                  titulo: 'Inventario vacío',
                  detalle: 'Agrega el primer repuesto con el botón +.',
                ),
              for (final repuesto in repuestos)
                _TarjetaRepuesto(
                  repuesto: repuesto,
                  umbral: umbral,
                  resaltado: false,
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showDialog<bool>(
            context: context,
            builder: (_) => const DialogoRepuesto(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo repuesto'),
      ),
    );
  }
}

class _AlertaUmbral extends StatelessWidget {
  const _AlertaUmbral({
    required this.umbral,
    required this.bajos,
    required this.agotados,
  });

  final int umbral;
  final int bajos;
  final int agotados;

  @override
  Widget build(BuildContext context) {
    final hayAlerta = bajos > 0;
    final color = hayAlerta ? AppColors.acento : AppColors.exito;
    return Card(
      color: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              hayAlerta ? Icons.warning_amber_rounded : Icons.check_circle,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hayAlerta
                        ? '$bajos repuesto(s) en o bajo el umbral'
                        : 'Sin alertas de stock',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    hayAlerta
                        ? 'Umbral actual: $umbral · agotados: $agotados'
                        : 'Todos los repuestos superan el umbral de $umbral.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                await showDialog<bool>(
                  context: context,
                  builder: (_) => DialogoUmbral(umbralActual: umbral),
                );
              },
              child: const Text('Cambiar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaRepuesto extends ConsumerWidget {
  const _TarjetaRepuesto({
    required this.repuesto,
    required this.umbral,
    required this.resaltado,
  });

  final Repuesto repuesto;
  final int umbral;
  final bool resaltado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(inventarioAccionesProvider.notifier);
    final bajo = repuesto.esStockBajo(umbral);
    final resaltar = resaltado && bajo;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: resaltar
              ? AppColors.acento.withValues(alpha: 0.6)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: bajo
              ? AppColors.acento.withValues(alpha: 0.2)
              : AppColors.primario.withValues(alpha: 0.15),
          child: Text(
            '${repuesto.existencias}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: bajo ? Colors.deepOrange : AppColors.primarioOscuro,
            ),
          ),
        ),
        title: Text(repuesto.nombre),
        subtitle: Text(
          '${repuesto.codigo} · ${Formato.dinero(repuesto.precio)}'
          '${repuesto.agotado ? ' · AGOTADO' : (bajo ? ' · stock bajo' : '')}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (accion) => _ejecutarAccion(
            context,
            notifier,
            accion,
          ),
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'editar', child: Text('Editar')),
            PopupMenuItem(value: 'entrada', child: Text('+1 existencia')),
            PopupMenuItem(value: 'salida', child: Text('-1 existencia')),
            PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }

  Future<void> _ejecutarAccion(
    BuildContext context,
    InventarioAccionesNotifier notifier,
    String accion,
  ) async {
    // Se usa if/else en lugar de switch porque cada rama hace un `await`
    // y necesitamos cortar el flujo después de cada acción.
    if (accion == 'editar') {
      await showDialog<bool>(
        context: context,
        builder: (_) => DialogoRepuesto(repuesto: repuesto),
      );
      return;
    }
    if (accion == 'entrada') {
      await notifier.ajustarExistencias(
        repuestoId: repuesto.id,
        delta: 1,
      );
      return;
    }
    if (accion == 'salida') {
      await notifier.ajustarExistencias(
        repuestoId: repuesto.id,
        delta: -1,
      );
      return;
    }
    if (accion == 'eliminar') {
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar repuesto'),
          content: Text('¿Eliminar ${repuesto.nombre} del inventario?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
      if (confirmado == true) {
        await notifier.eliminar(repuesto.id);
      }
    }
  }
}

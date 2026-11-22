import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/carga_trabajo.dart';
import '../../../domain/entities/orden.dart';
import '../../viewmodels/carga_trabajo_viewmodel.dart';
import '../../widgets/estado_badge.dart';
import '../../widgets/estado_carga.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/error_vista.dart';
import '../ordenes/detalle_orden_view.dart';

/// Carga de trabajo por técnico: órdenes abiertas asignadas a cada uno.
class CargaTrabajoView extends ConsumerWidget {
  const CargaTrabajoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cargaAsync = ref.watch(cargaTrabajoProvider);

    return cargaAsync.when(
      loading: () => const EstadoCarga(mensaje: 'Calculando carga...'),
      error: (error, _) => ErrorVista(
        mensaje: 'No se pudo calcular la carga de trabajo.\n$error',
        onReintentar: () => ref.invalidate(cargaTrabajoProvider),
      ),
      data: (cargas) {
        if (cargas.isEmpty) {
          return const EstadoVacio(
            icono: Icons.groups_outlined,
            titulo: 'Sin técnicos',
            detalle: 'La base de datos crea 3 técnicos al instalarse.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 96),
          itemCount: cargas.length,
          itemBuilder: (context, index) =>
              _TarjetaCarga(carga: cargas[index]),
        );
      },
    );
  }
}

class _TarjetaCarga extends StatelessWidget {
  const _TarjetaCarga({required this.carga});

  final CargaTrabajo carga;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primario.withValues(alpha: 0.15),
          child: Text(
            '${carga.total}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.primarioOscuro,
            ),
          ),
        ),
        title: Text(carga.tecnico.nombre),
        subtitle: Text(
          '${carga.total} orden(es) abiertas · '
          '${carga.enReparacion} en reparación · ${carga.listas} listas',
        ),
        children: [
          if (carga.ordenesAbiertas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin órdenes asignadas.'),
            ),
          for (final orden in carga.ordenesAbiertas)
            _FilaOrdenCarga(orden: orden),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total abierto: ${carga.total}',
                style: tema.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _FilaOrdenCarga extends StatelessWidget {
  const _FilaOrdenCarga({required this.orden});

  final Orden orden;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.assignment_outlined, size: 20),
      title: Text('Orden #${orden.id} · ${orden.descripcionEquipo}'),
      subtitle: Text(
        '${orden.clienteNombre} · ${orden.fallaReportada}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: EstadoBadge(estado: orden.estado, compacto: true),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DetalleOrdenView(ordenId: orden.id),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formato.dart';
import '../../../domain/entities/historial_item.dart';
import '../../viewmodels/historial_viewmodel.dart';
import '../../widgets/estado_badge.dart';
import '../../widgets/estado_carga.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/error_vista.dart';
import '../ordenes/detalle_orden_view.dart';

/// Historial completo de un equipo: todas las veces que volvió al taller.
class HistorialEquipoView extends ConsumerWidget {
  const HistorialEquipoView({
    super.key,
    required this.equipoId,
    required this.titulo,
  });

  final int equipoId;
  final String titulo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historialAsync = ref.watch(historialEquipoProvider(equipoId));

    return Scaffold(
      appBar: AppBar(title: Text('Historial: $titulo')),
      body: historialAsync.when(
        loading: () => const EstadoCarga(mensaje: 'Cargando historial...'),
        error: (error, _) => ErrorVista(
          mensaje: 'No se pudo cargar el historial.\n$error',
          onReintentar: () =>
              ref.invalidate(historialEquipoProvider(equipoId)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EstadoVacio(
              icono: Icons.history,
              titulo: 'Este equipo no tiene órdenes',
              detalle: 'Cuando se reciba el equipo aparecerá aquí su historial.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: items.length,
            itemBuilder: (context, index) =>
                _TarjetaHistorial(item: items[index]),
          );
        },
      ),
    );
  }
}

class _TarjetaHistorial extends StatelessWidget {
  const _TarjetaHistorial({required this.item});

  final HistorialEquipoItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DetalleOrdenView(ordenId: item.ordenId),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Orden #${item.ordenId}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  EstadoBadge(estado: item.estado, compacto: true),
                ],
              ),
              const SizedBox(height: 6),
              Text(item.fallaReportada),
              const SizedBox(height: 8),
              Text(
                'Recibido: ${Formato.fecha(item.fechaRecepcion)} · '
                'Entregado: ${Formato.fecha(item.fechaEntrega)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Técnico: ${item.tecnicoNombre ?? 'Sin asignar'} · '
                'Repuestos usados: ${item.repuestosUsados}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.receipt_long, size: 16),
                  const SizedBox(width: 6),
                  Text('Costo total: ${Formato.dinero(item.costoTotal)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

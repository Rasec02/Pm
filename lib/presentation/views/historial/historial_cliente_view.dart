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

/// Historial de todas las reparaciones de un cliente (todos sus equipos).
class HistorialClienteView extends ConsumerWidget {
  const HistorialClienteView({
    super.key,
    required this.clienteId,
    required this.titulo,
  });

  final int clienteId;
  final String titulo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historialAsync = ref.watch(historialClienteProvider(clienteId));

    return Scaffold(
      appBar: AppBar(title: Text('Historial: $titulo')),
      body: historialAsync.when(
        loading: () => const EstadoCarga(mensaje: 'Cargando historial...'),
        error: (error, _) => ErrorVista(
          mensaje: 'No se pudo cargar el historial.\n$error',
          onReintentar: () =>
              ref.invalidate(historialClienteProvider(clienteId)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EstadoVacio(
              icono: Icons.history,
              titulo: 'Este cliente no tiene reparaciones',
              detalle: 'Las órdenes de sus equipos aparecerán aquí.',
            );
          }
          final total = items.fold<double>(
            0,
            (suma, item) => suma + item.costoTotal,
          );
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.summarize_outlined),
                    title: Text('${items.length} reparación(es)'),
                    subtitle: Text('Total facturado: ${Formato.dinero(total)}'),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      _TarjetaHistorialClienteItem(item: items[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TarjetaHistorialClienteItem extends StatelessWidget {
  const _TarjetaHistorialClienteItem({required this.item});

  final HistorialClienteItem item;

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
              const SizedBox(height: 4),
              Text(item.equipoDescripcion),
              Text(
                'Serie: ${item.numeroSerie}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Text(item.fallaReportada),
              const SizedBox(height: 6),
              Text(
                'Recibido: ${Formato.fecha(item.fechaRecepcion)} · '
                'Entregado: ${Formato.fecha(item.fechaEntrega)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Costo total: ${Formato.dinero(item.costoTotal)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/cliente.dart';
import '../../../domain/entities/equipo.dart';
import '../../providers/catalogos_providers.dart';
import '../../widgets/estado_carga.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/error_vista.dart';
import 'historial_cliente_view.dart';
import 'historial_equipo_view.dart';

/// Historial de reparaciones: se elige el dueño y luego el equipo, o se ven
/// todas las órdenes del cliente (equipos que vuelven al taller).
class HistorialView extends ConsumerWidget {
  const HistorialView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientesAsync = ref.watch(clientesProvider);
    final equiposAsync = ref.watch(equiposProvider);

    return clientesAsync.when(
      loading: () => const EstadoCarga(mensaje: 'Cargando historial...'),
      error: (error, _) => ErrorVista(
        mensaje: 'No se pudo cargar el historial.\n$error',
        onReintentar: () => ref.invalidate(clientesProvider),
      ),
      data: (clientes) {
        if (clientes.isEmpty) {
          return const EstadoVacio(
            icono: Icons.history,
            titulo: 'Sin historial todavía',
            detalle: 'Registra clientes, equipos y órdenes para ver el '
                'historial por equipo y por cliente.',
          );
        }
        return equiposAsync.when(
          loading: () => const EstadoCarga(mensaje: 'Cargando equipos...'),
          error: (error, _) => ErrorVista(
            mensaje: 'No se pudieron cargar los equipos.\n$error',
            onReintentar: () => ref.invalidate(equiposProvider),
          ),
          data: (equipos) => ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final cliente = clientes[index];
              final propios = equipos
                  .where((equipo) => equipo.clienteId == cliente.id)
                  .toList();
              return _TarjetaHistorialCliente(
                cliente: cliente,
                equipos: propios,
              );
            },
          ),
        );
      },
    );
  }
}

class _TarjetaHistorialCliente extends StatelessWidget {
  const _TarjetaHistorialCliente({
    required this.cliente,
    required this.equipos,
  });

  final Cliente cliente;
  final List<Equipo> equipos;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.person_outline),
        title: Text(cliente.nombre),
        subtitle: Text(
          '${equipos.length} equipo(s) · ${cliente.telefono}',
        ),
        children: [
          for (final equipo in equipos)
            ListTile(
              dense: true,
              leading: const Icon(Icons.devices_other, size: 20),
              title: Text(equipo.descripcion),
              subtitle: Text('Serie: ${equipo.numeroSerie}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => HistorialEquipoView(
                    equipoId: equipo.id,
                    titulo: equipo.descripcion,
                  ),
                ),
              ),
            ),
          if (equipos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Este cliente no tiene equipos registrados.'),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => HistorialClienteView(
                      clienteId: cliente.id,
                      titulo: cliente.nombre,
                    ),
                  ),
                ),
                icon: const Icon(Icons.receipt_long, size: 18),
                label: const Text('Ver historial del cliente'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

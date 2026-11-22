import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/cliente.dart';
import '../../../domain/entities/equipo.dart';
import '../../providers/catalogos_providers.dart';
import '../../viewmodels/clientes_viewmodel.dart';
import '../../viewmodels/estado_ui.dart';
import '../../widgets/estado_carga.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/error_vista.dart';
import '../ordenes/nueva_orden_view.dart';
import 'formulario_cliente.dart';
import 'formulario_equipo.dart';

/// Pantalla de clientes y equipos: altas, búsqueda e historial por cliente.
class RegistroView extends ConsumerWidget {
  const RegistroView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientesAsync = ref.watch(clientesProvider);

    ref.listen<EstadoAccion>(clientesAccionesProvider, (anterior, actual) {
      final mensaje = EstadoAccion.procesarMensaje(
        anterior,
        actual,
        exito: actual.tieneExito,
      );
      if (mensaje == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(mensaje)));
    });

    return Scaffold(
      body: clientesAsync.when(
        loading: () => const EstadoCarga(mensaje: 'Cargando clientes...'),
        error: (error, _) => ErrorVista(
          mensaje: 'No se pudieron cargar los clientes.\n$error',
          onReintentar: () => ref.invalidate(clientesProvider),
        ),
        data: (clientes) {
          if (clientes.isEmpty) {
            return const EstadoVacio(
              icono: Icons.people_outline,
              titulo: 'Todavía no hay clientes',
              detalle: 'Registra al primer dueño con el botón +.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final cliente = clientes[index];
              return _TarjetaCliente(cliente: cliente);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => mostrarFormularioCliente(context),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Nuevo cliente'),
      ),
    );
  }
}

class _TarjetaCliente extends ConsumerWidget {
  const _TarjetaCliente({required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equiposAsync = ref.watch(equiposProvider);
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Text(
            cliente.nombre.isEmpty ? '?' : cliente.nombre[0].toUpperCase(),
          ),
        ),
        title: Text(cliente.nombre),
        subtitle: Text(cliente.telefono),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: [
          equiposAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(12),
              child: LinearProgressIndicator(),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Error al cargar equipos: $error'),
            ),
            data: (equipos) {
              final propios =
                  equipos.where((equipo) => equipo.clienteId == cliente.id);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (propios.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Sin equipos registrados.'),
                    ),
                  for (final equipo in propios)
                    _FilaEquipo(equipo: equipo),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        TextButton.icon(
                          onPressed: () => mostrarFormularioEquipo(
                            context,
                            clienteId: cliente.id,
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Agregar equipo'),
                        ),
                        TextButton.icon(
                          onPressed: () => abrirNuevaOrden(context),
                          icon: const Icon(Icons.assignment_add, size: 18),
                          label: const Text('Recibir equipo'),
                        ),
                        TextButton.icon(
                          onPressed: () => _editar(context),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Editar'),
                        ),
                        TextButton.icon(
                          onPressed: () => _eliminar(context, ref),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<int?> _editar(BuildContext context) {
    return mostrarFormularioCliente(
      context,
      clienteId: cliente.id,
      nombreInicial: cliente.nombre,
      telefonoInicial: cliente.telefono,
    );
  }

  Future<void> _eliminar(BuildContext context, WidgetRef ref) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cliente'),
        content: Text(
          '¿Eliminar a ${cliente.nombre}? Esta acción no se puede deshacer.',
        ),
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
    if (confirmado != true) return;
    await ref.read(clientesAccionesProvider.notifier).eliminar(cliente.id);
  }
}

class _FilaEquipo extends StatelessWidget {
  const _FilaEquipo({required this.equipo});

  final Equipo equipo;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.devices_other, size: 20),
      title: Text(equipo.descripcion),
      subtitle: Text('Serie: ${equipo.numeroSerie}'),
      trailing: const Icon(Icons.chevron_right, size: 18),
    );
  }
}

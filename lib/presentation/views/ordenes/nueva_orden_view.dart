import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/cliente.dart';
import '../../../domain/entities/equipo.dart';
import '../../providers/catalogos_providers.dart';
import '../../viewmodels/estado_ui.dart';
import '../../viewmodels/ordenes_viewmodel.dart';
import '../../widgets/estado_carga.dart';
import '../registro/formulario_cliente.dart';
import '../registro/formulario_equipo.dart';

/// Formulario para recibir un equipo y crear su orden de reparación.
///
/// Si el equipo todavía no está registrado, se puede dar de alta el dueño y el
/// equipo sin salir de la pantalla.
class NuevaOrdenView extends ConsumerStatefulWidget {
  const NuevaOrdenView({super.key});

  @override
  ConsumerState<NuevaOrdenView> createState() => _NuevaOrdenViewState();
}

class _NuevaOrdenViewState extends ConsumerState<NuevaOrdenView> {
  final _formKey = GlobalKey<FormState>();
  final _falla = TextEditingController();
  int? _clienteId;
  int? _equipoId;
  String? _errorLocal;

  @override
  void dispose() {
    _falla.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clientesProvider);
    final equiposAsync = ref.watch(equiposProvider);
    final acciones = ref.watch(ordenesAccionesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recibir equipo')),
      body: clientesAsync.when(
        loading: () => const EstadoCarga(mensaje: 'Cargando clientes...'),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (clientes) => equiposAsync.when(
          loading: () => const EstadoCarga(mensaje: 'Cargando equipos...'),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (equipos) => _formulario(context, clientes, equipos, acciones),
        ),
      ),
    );
  }

  Widget _formulario(
    BuildContext context,
    List<Cliente> clientes,
    List<Equipo> equipos,
    EstadoAccion acciones,
  ) {
    final equiposDelCliente = _clienteId == null
        ? <Equipo>[]
        : equipos.where((equipo) => equipo.clienteId == _clienteId).toList();
    final enProgreso = acciones.enProgreso;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SeccionTitulo(texto: '1. Dueño del equipo'),
            const SizedBox(height: 8),
            if (clientes.isEmpty)
              const Text(
                'Aún no hay clientes registrados. Crea el primero aquí abajo.',
              )
            else
              DropdownButtonFormField<int>(
                key: ValueKey<int?>(_clienteId),
                initialValue: _clienteId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Cliente'),
                items: [
                  for (final cliente in clientes)
                    DropdownMenuItem<int>(
                      value: cliente.id,
                      child: Text(
                        '${cliente.nombre} · ${cliente.telefono}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (id) => setState(() {
                  _clienteId = id;
                  _equipoId = null;
                }),
                validator: (valor) =>
                    valor == null ? 'Selecciona el dueño del equipo.' : null,
              ),
            TextButton.icon(
              onPressed: () async {
                final creado = await mostrarFormularioCliente(context);
                if (creado != null) {
                  setState(() {
                    _clienteId = creado;
                    _equipoId = null;
                  });
                }
              },
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Registrar nuevo dueño'),
            ),
            const SizedBox(height: 8),
            _SeccionTitulo(texto: '2. Equipo recibido'),
            const SizedBox(height: 8),
            if (_clienteId == null)
              const Text(
                'Selecciona primero al dueño para ver sus equipos.',
              )
            else if (equiposDelCliente.isEmpty)
              const Text(
                'Este dueño no tiene equipos registrados. '
                'Registra el equipo para continuar.',
              )
            else
              DropdownButtonFormField<int>(
                key: ValueKey<String>('equipo-$_clienteId-$_equipoId'),
                initialValue: _equipoId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Equipo'),
                items: [
                  for (final equipo in equiposDelCliente)
                    DropdownMenuItem<int>(
                      value: equipo.id,
                      child: Text(
                        '${equipo.descripcion} · ${equipo.numeroSerie}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (id) => setState(() => _equipoId = id),
                validator: (valor) =>
                    valor == null ? 'Selecciona el equipo a reparar.' : null,
              ),
            if (_clienteId != null)
              TextButton.icon(
                onPressed: () async {
                  final creado = await mostrarFormularioEquipo(
                    context,
                    clienteId: _clienteId!,
                  );
                  if (creado != null) {
                    setState(() => _equipoId = creado);
                  }
                },
                icon: const Icon(Icons.devices_other),
                label: const Text('Registrar nuevo equipo'),
              ),
            const SizedBox(height: 8),
            _SeccionTitulo(texto: '3. Falla reportada'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _falla,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Falla reportada',
                hintText: 'No enciende, pantalla rota, no carga...',
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Describe la falla reportada por el dueño.';
                }
                return null;
              },
            ),
            if (_errorLocal != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorLocal!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: enProgreso ? null : _crearOrden,
              icon: const Icon(Icons.save),
              label: enProgreso
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear orden de reparación'),
            ),
            const SizedBox(height: 8),
            const Text(
              'La orden se crea en estado Recibida y sin responsable. '
              'El primer técnico que la tome queda asignado.',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _crearOrden() async {
    if (_formKey.currentState?.validate() != true) return;
    final equipoId = _equipoId;
    if (equipoId == null) {
      setState(() => _errorLocal = 'Selecciona el equipo a reparar.');
      return;
    }
    setState(() => _errorLocal = null);
    final exito = await ref.read(ordenesAccionesProvider.notifier).recibirEquipo(
          equipoId: equipoId,
          fallaReportada: _falla.text,
        );
    if (!mounted) return;
    if (exito) {
      Navigator.of(context).pop();
    } else {
      final error =
          ref.read(ordenesAccionesProvider).mensajeError ?? 'Error desconocido';
      setState(() => _errorLocal = error);
    }
  }
}

class _SeccionTitulo extends StatelessWidget {
  const _SeccionTitulo({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

/// Abre el formulario de nueva orden desde la pantalla de registro.
Future<void> abrirNuevaOrden(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const NuevaOrdenView()),
  );
}

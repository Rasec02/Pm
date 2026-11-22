import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/enums/tipo_equipo.dart';
import '../../viewmodels/equipos_viewmodel.dart';

/// Muestra el formulario de alta de equipo para un cliente concreto.
///
/// Devuelve el id del equipo creado, o `null` si se canceló.
Future<int?> mostrarFormularioEquipo(
  BuildContext context, {
  required int clienteId,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => DialogoEquipo(clienteId: clienteId),
  );
}

/// Diálogo de alta de equipo.
class DialogoEquipo extends ConsumerStatefulWidget {
  const DialogoEquipo({super.key, required this.clienteId});

  final int clienteId;

  @override
  ConsumerState<DialogoEquipo> createState() => _DialogoEquipoState();
}

class _DialogoEquipoState extends ConsumerState<DialogoEquipo> {
  final _formKey = GlobalKey<FormState>();
  final _marca = TextEditingController();
  final _modelo = TextEditingController();
  final _serie = TextEditingController();
  TipoEquipo _tipo = TipoEquipo.celular;
  String? _errorLocal;

  @override
  void dispose() {
    _marca.dispose();
    _modelo.dispose();
    _serie.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(equiposAccionesProvider);
    return AlertDialog(
      title: const Text('Nuevo equipo'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<TipoEquipo>(
                initialValue: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: [
                  for (final tipo in TipoEquipo.values)
                    DropdownMenuItem<TipoEquipo>(
                      value: tipo,
                      child: Text(tipo.etiqueta),
                    ),
                ],
                onChanged: (tipo) {
                  if (tipo != null) setState(() => _tipo = tipo);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _marca,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Marca'),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'La marca es obligatoria.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modelo,
                decoration: const InputDecoration(labelText: 'Modelo'),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'El modelo es obligatorio.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _serie,
                decoration:
                    const InputDecoration(labelText: 'Número de serie'),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'El número de serie es obligatorio.'
                    : null,
              ),
              if (_errorLocal != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorLocal!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: estado.enProgreso ? null : _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _guardar() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _errorLocal = null);
    final id = await ref.read(equiposAccionesProvider.notifier).crear(
          tipo: _tipo,
          marca: _marca.text,
          modelo: _modelo.text,
          numeroSerie: _serie.text,
          clienteId: widget.clienteId,
        );
    if (!mounted) return;
    if (id != null) {
      Navigator.of(context).pop(id);
    } else {
      setState(() {
        _errorLocal =
            ref.read(equiposAccionesProvider).mensajeError ?? 'Error desconocido';
      });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/clientes_viewmodel.dart';

/// Muestra el formulario de alta o edición de un cliente.
///
/// Devuelve el id del cliente guardado, o `null` si se canceló.
Future<int?> mostrarFormularioCliente(
  BuildContext context, {
  int? clienteId,
  String? nombreInicial,
  String? telefonoInicial,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => DialogoCliente(
      clienteId: clienteId,
      nombreInicial: nombreInicial,
      telefonoInicial: telefonoInicial,
    ),
  );
}

/// Diálogo de alta de cliente (también se usa desde la pantalla de registro).
class DialogoCliente extends ConsumerStatefulWidget {
  const DialogoCliente({
    super.key,
    this.clienteId,
    this.nombreInicial,
    this.telefonoInicial,
  });

  /// Si viene informado, el diálogo edita el cliente en lugar de crearlo.
  final int? clienteId;
  final String? nombreInicial;
  final String? telefonoInicial;

  @override
  ConsumerState<DialogoCliente> createState() => _DialogoClienteState();
}

class _DialogoClienteState extends ConsumerState<DialogoCliente> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre =
      TextEditingController(text: widget.nombreInicial ?? '');
  late final TextEditingController _telefono =
      TextEditingController(text: widget.telefonoInicial ?? '');
  String? _errorLocal;

  bool get _esEdicion => widget.clienteId != null;

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(clientesAccionesProvider);
    return AlertDialog(
      title: Text(_esEdicion ? 'Editar cliente' : 'Nuevo cliente'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              validator: (valor) => (valor == null || valor.trim().isEmpty)
                  ? 'El nombre es obligatorio.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefono,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              validator: (valor) => (valor == null || valor.trim().isEmpty)
                  ? 'El teléfono es obligatorio.'
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: estado.enProgreso ? null : _guardar,
          child: Text(_esEdicion ? 'Guardar cambios' : 'Guardar'),
        ),
      ],
    );
  }

  Future<void> _guardar() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _errorLocal = null);
    final notifier = ref.read(clientesAccionesProvider.notifier);

    if (_esEdicion) {
      final exito = await notifier.actualizar(
        id: widget.clienteId!,
        nombre: _nombre.text,
        telefono: _telefono.text,
      );
      if (!mounted) return;
      if (exito) {
        Navigator.of(context).pop(widget.clienteId);
      } else {
        _mostrarError();
      }
      return;
    }

    final id = await notifier.crear(
      nombre: _nombre.text,
      telefono: _telefono.text,
    );
    if (!mounted) return;
    if (id != null) {
      Navigator.of(context).pop(id);
    } else {
      _mostrarError();
    }
  }

  void _mostrarError() {
    setState(() {
      _errorLocal =
          ref.read(clientesAccionesProvider).mensajeError ?? 'Error desconocido';
    });
  }
}

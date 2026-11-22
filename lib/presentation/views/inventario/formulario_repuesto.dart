import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formato.dart';
import '../../../domain/entities/repuesto.dart';
import '../../viewmodels/inventario_viewmodel.dart';
import '../../widgets/formato_texto.dart';

/// Diálogo de alta o edición de un repuesto del inventario.
class DialogoRepuesto extends ConsumerStatefulWidget {
  const DialogoRepuesto({super.key, this.repuesto});

  /// Si viene informado, el diálogo edita el repuesto.
  final Repuesto? repuesto;

  @override
  ConsumerState<DialogoRepuesto> createState() => _DialogoRepuestoState();
}

class _DialogoRepuestoState extends ConsumerState<DialogoRepuesto> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codigo =
      TextEditingController(text: widget.repuesto?.codigo ?? '');
  late final TextEditingController _nombre =
      TextEditingController(text: widget.repuesto?.nombre ?? '');
  late final TextEditingController _precio = TextEditingController(
    text: widget.repuesto == null
        ? ''
        : widget.repuesto!.precio.toStringAsFixed(2),
  );
  late final TextEditingController _existencias = TextEditingController(
    text: widget.repuesto == null ? '0' : '${widget.repuesto!.existencias}',
  );
  String? _errorLocal;

  bool get _esEdicion => widget.repuesto != null;

  @override
  void dispose() {
    _codigo.dispose();
    _nombre.dispose();
    _precio.dispose();
    _existencias.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(inventarioAccionesProvider);
    return AlertDialog(
      title: Text(_esEdicion ? 'Editar repuesto' : 'Nuevo repuesto'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codigo,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Código único',
                  hintText: 'PAN-IP11',
                ),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'El código es obligatorio.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombre,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'El nombre es obligatorio.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precio,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: Formateadores.decimales,
                decoration: const InputDecoration(
                  labelText: 'Precio unitario',
                  prefixText: '\$ ',
                ),
                validator: (valor) {
                  final numero = Formato.aDouble(valor ?? '');
                  if (numero == null) return 'Ingresa un precio válido.';
                  if (numero < 0) return 'El precio no puede ser negativo.';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _existencias,
                keyboardType: TextInputType.number,
                inputFormatters: Formateadores.enteros,
                decoration: const InputDecoration(labelText: 'Existencias'),
                validator: (valor) {
                  final numero = Formato.aEntero(valor ?? '');
                  if (numero == null) return 'Ingresa una cantidad válida.';
                  if (numero < 0) return 'No puede ser negativo.';
                  return null;
                },
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
          child: Text(_esEdicion ? 'Guardar cambios' : 'Guardar'),
        ),
      ],
    );
  }

  Future<void> _guardar() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _errorLocal = null);
    final notifier = ref.read(inventarioAccionesProvider.notifier);
    final precio = Formato.aDouble(_precio.text) ?? 0;
    final existencias = Formato.aEntero(_existencias.text) ?? 0;

    final bool exito;
    if (_esEdicion) {
      exito = await notifier.actualizar(
        id: widget.repuesto!.id,
        codigo: _codigo.text,
        nombre: _nombre.text,
        precio: precio,
        existencias: existencias,
      );
    } else {
      exito = await notifier.crear(
        codigo: _codigo.text,
        nombre: _nombre.text,
        precio: precio,
        existencias: existencias,
      );
    }
    if (!mounted) return;
    if (exito) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorLocal = ref.read(inventarioAccionesProvider).mensajeError ??
            'Error desconocido';
      });
    }
  }
}

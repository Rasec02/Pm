import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formato.dart';
import '../../../domain/entities/orden.dart';
import '../../viewmodels/ordenes_viewmodel.dart';
import '../../widgets/formato_texto.dart';

/// Abre el formulario para registrar mano de obra en una orden abierta.
Future<void> mostrarAgregarTrabajoSheet(
  BuildContext context,
  WidgetRef ref,
  Orden orden,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _FormularioTrabajo(orden: orden),
    ),
  );
}

class _FormularioTrabajo extends ConsumerStatefulWidget {
  const _FormularioTrabajo({required this.orden});

  final Orden orden;

  @override
  ConsumerState<_FormularioTrabajo> createState() => _FormularioTrabajoState();
}

class _FormularioTrabajoState extends ConsumerState<_FormularioTrabajo> {
  final _formKey = GlobalKey<FormState>();
  final _descripcion = TextEditingController();
  final _costo = TextEditingController();
  String? _errorLocal;

  @override
  void dispose() {
    _descripcion.dispose();
    _costo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(ordenesAccionesProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agregar trabajo a la orden #${widget.orden.id}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcion,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción del trabajo',
                hintText: 'Cambio de pantalla, limpieza, diagnóstico...',
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Describe el trabajo realizado.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costo,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: Formateadores.decimales,
              decoration: const InputDecoration(
                labelText: 'Costo de mano de obra',
                prefixText: '\$ ',
              ),
              validator: (valor) {
                final numero = Formato.aDouble(valor ?? '');
                if (numero == null) return 'Ingresa un monto válido.';
                if (numero < 0) return 'El monto no puede ser negativo.';
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
            FilledButton(
              onPressed: estado.enProgreso ? null : _guardar,
              child: estado.enProgreso
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar trabajo'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _errorLocal = null);
    final costo = Formato.aDouble(_costo.text) ?? 0;
    final exito = await ref.read(ordenesAccionesProvider.notifier).agregarTrabajo(
          ordenId: widget.orden.id,
          descripcion: _descripcion.text,
          costoManoObra: costo,
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

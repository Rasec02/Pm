import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formato.dart';
import '../../../domain/entities/orden.dart';
import '../../../domain/entities/repuesto.dart';
import '../../providers/catalogos_providers.dart';
import '../../viewmodels/ordenes_viewmodel.dart';
import '../../widgets/formato_texto.dart';

/// Abre el formulario para usar un repuesto en una orden.
///
/// Valida el stock disponible en la interfaz y el repositorio vuelve a
/// validarlo dentro de la transacción de Drift.
Future<void> mostrarAgregarRepuestoSheet(
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
      child: _FormularioRepuesto(orden: orden),
    ),
  );
}

class _FormularioRepuesto extends ConsumerStatefulWidget {
  const _FormularioRepuesto({required this.orden});

  final Orden orden;

  @override
  ConsumerState<_FormularioRepuesto> createState() =>
      _FormularioRepuestoState();
}

class _FormularioRepuestoState extends ConsumerState<_FormularioRepuesto> {
  final _formKey = GlobalKey<FormState>();
  final _cantidad = TextEditingController(text: '1');
  Repuesto? _seleccionado;
  String? _errorLocal;

  @override
  void dispose() {
    _cantidad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repuestosAsync = ref.watch(repuestosProvider);
    final umbral = ref.watch(umbralActualProvider);
    final estado = ref.watch(ordenesAccionesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agregar repuesto a la orden #${widget.orden.id}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            repuestosAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Error al cargar repuestos: $error'),
              data: (repuestos) {
                if (repuestos.isEmpty) {
                  return const Text(
                    'No hay repuestos en el inventario. Agrega uno primero.',
                  );
                }
                return DropdownButtonFormField<int>(
                  key: ValueKey<int?>(_seleccionado?.id),
                  initialValue: _seleccionado?.id,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Repuesto'),
                  items: [
                    for (final repuesto in repuestos)
                      DropdownMenuItem<int>(
                        value: repuesto.id,
                        child: Text(
                          '${repuesto.nombre} (${repuesto.existencias} disp.)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (id) {
                    setState(() {
                      _seleccionado = _buscarPorId(repuestos, id);
                      _errorLocal = null;
                    });
                  },
                  validator: (valor) =>
                      valor == null ? 'Selecciona un repuesto.' : null,
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cantidad,
              keyboardType: TextInputType.number,
              inputFormatters: Formateadores.enteros,
              decoration: InputDecoration(
                labelText: 'Cantidad',
                helperText: _seleccionado == null
                    ? null
                    : 'Disponibles: ${_seleccionado!.existencias} · '
                        'precio ${Formato.dinero(_seleccionado!.precio)}',
              ),
              validator: (valor) {
                final cantidad = Formato.aEntero(valor ?? '');
                if (cantidad == null || cantidad <= 0) {
                  return 'La cantidad debe ser mayor que cero.';
                }
                if (_seleccionado != null &&
                    cantidad > _seleccionado!.existencias) {
                  return 'Solo hay ${_seleccionado!.existencias} unidades.';
                }
                return null;
              },
            ),
            if (_seleccionado != null &&
                _seleccionado!.esStockBajo(umbral)) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.warning_amber, size: 18, color: Colors.orange),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Repuesto con stock bajo (umbral $umbral). '
                      'Considera comprar más.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
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
                  : const Text('Descontar stock y agregar'),
            ),
          ],
        ),
      ),
    );
  }

  Repuesto? _buscarPorId(List<Repuesto> repuestos, int? id) {
    for (final repuesto in repuestos) {
      if (repuesto.id == id) return repuesto;
    }
    return null;
  }

  Future<void> _guardar() async {
    if (_formKey.currentState?.validate() != true) return;
    final repuesto = _seleccionado;
    if (repuesto == null) {
      setState(() => _errorLocal = 'Selecciona un repuesto.');
      return;
    }
    final cantidad = Formato.aEntero(_cantidad.text) ?? 0;
    setState(() => _errorLocal = null);
    final exito = await ref.read(ordenesAccionesProvider.notifier).agregarRepuesto(
          ordenId: widget.orden.id,
          repuestoId: repuesto.id,
          cantidad: cantidad,
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

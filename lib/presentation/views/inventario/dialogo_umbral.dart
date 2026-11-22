import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formato.dart';
import '../../viewmodels/inventario_viewmodel.dart';
import '../../widgets/formato_texto.dart';

/// Diálogo para configurar el umbral de stock bajo.
class DialogoUmbral extends ConsumerStatefulWidget {
  const DialogoUmbral({super.key, required this.umbralActual});

  final int umbralActual;

  @override
  ConsumerState<DialogoUmbral> createState() => _DialogoUmbralState();
}

class _DialogoUmbralState extends ConsumerState<DialogoUmbral> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _umbral =
      TextEditingController(text: '${widget.umbralActual}');
  String? _errorLocal;

  @override
  void dispose() {
    _umbral.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(inventarioAccionesProvider);
    return AlertDialog(
      title: const Text('Umbral de stock bajo'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Se muestra la alerta cuando las existencias de un repuesto '
              'son iguales o menores a este valor.',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _umbral,
              keyboardType: TextInputType.number,
              inputFormatters: Formateadores.enteros,
              decoration: const InputDecoration(
                labelText: 'Umbral',
                suffixText: 'unidades',
              ),
              validator: (valor) {
                final numero = Formato.aEntero(valor ?? '');
                if (numero == null) return 'Ingresa un número válido.';
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
    final umbral = Formato.aEntero(_umbral.text) ?? 0;
    final exito =
        await ref.read(inventarioAccionesProvider.notifier).guardarUmbral(umbral);
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

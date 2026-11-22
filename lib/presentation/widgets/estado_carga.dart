import 'package:flutter/material.dart';

/// Indicador de carga centrado con mensaje opcional.
class EstadoCarga extends StatelessWidget {
  const EstadoCarga({super.key, this.mensaje});

  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (mensaje != null) ...[
            const SizedBox(height: 12),
            Text(mensaje!),
          ],
        ],
      ),
    );
  }
}

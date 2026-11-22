import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formato.dart';
import '../../domain/entities/orden.dart';
import 'estado_badge.dart';

/// Tarjeta de una orden en la lista: estado, equipo, dueño y responsable.
class TarjetaOrden extends StatelessWidget {
  const TarjetaOrden({super.key, required this.orden, required this.onTap});

  final Orden orden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final sinResponsable = !orden.tieneResponsable;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Orden #${orden.id}',
                    style: tema.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  EstadoBadge(estado: orden.estado),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                orden.descripcionEquipo,
                style: tema.textTheme.titleMedium,
              ),
              Text(
                'Serie: ${orden.numeroSerie}',
                style: tema.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Falla: ${orden.fallaReportada}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: sinResponsable
                        ? AppColors.acento
                        : tema.colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      sinResponsable
                          ? 'Sin asignar'
                          : 'Responsable: ${orden.responsableTexto}',
                      style: tema.textTheme.bodySmall?.copyWith(
                        fontWeight:
                            sinResponsable ? FontWeight.w700 : FontWeight.w500,
                        color: sinResponsable ? AppColors.acento : null,
                      ),
                    ),
                  ),
                  Text(
                    Formato.fecha(orden.fechaRecepcion),
                    style: tema.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Dueño: ${orden.clienteNombre} · ${orden.clienteTelefono}',
                style: tema.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

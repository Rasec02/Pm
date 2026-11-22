import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/constants.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/entities/equipo.dart';
import '../../domain/entities/repuesto.dart';
import '../../domain/entities/tecnico.dart';
import 'repository_providers.dart';

/// Catálogos reactivos compartidos por varias pantallas.
final clientesProvider = StreamProvider<List<Cliente>>((ref) {
  return ref.watch(clienteRepositoryProvider).watchTodos();
});

final tecnicosProvider = StreamProvider<List<Tecnico>>((ref) {
  return ref.watch(tecnicoRepositoryProvider).watchTodos();
});

final equiposProvider = StreamProvider<List<Equipo>>((ref) {
  return ref.watch(equipoRepositoryProvider).watchTodos();
});

final repuestosProvider = StreamProvider<List<Repuesto>>((ref) {
  return ref.watch(repuestoRepositoryProvider).watchTodos();
});

/// Umbral de stock bajo configurable desde el inventario (por defecto 3).
///
/// Es un `StreamProvider` sobre la tabla de configuración de Drift: cuando se
/// guarda un umbral nuevo, todas las pantallas que lo usan se reconstruyen.
final umbralStockBajoProvider = StreamProvider<int>((ref) {
  return ref.watch(configuracionRepositoryProvider).watchUmbralStockBajo();
});

/// Umbral efectivo para la interfaz: usa el valor guardado y, mientras carga
/// la primera vez, el valor por defecto de [ConfiguracionKeys].
final umbralActualProvider = Provider<int>((ref) {
  return ref.watch(umbralStockBajoProvider).valueOrNull ??
      ConfiguracionKeys.umbralStockBajoPorDefecto;
});

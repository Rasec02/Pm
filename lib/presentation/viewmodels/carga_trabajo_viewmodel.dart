import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/carga_trabajo.dart';
import '../providers/repository_providers.dart';

/// Carga de trabajo (órdenes abiertas) por técnico.
final cargaTrabajoProvider = StreamProvider<List<CargaTrabajo>>((ref) {
  return ref.watch(ordenRepositoryProvider).watchCargaTrabajo();
});

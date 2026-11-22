import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/cliente_repository_impl.dart';
import '../../data/repositories/configuracion_repository_impl.dart';
import '../../data/repositories/equipo_repository_impl.dart';
import '../../data/repositories/orden_repository_impl.dart';
import '../../data/repositories/repuesto_repository_impl.dart';
import '../../data/repositories/tecnico_repository_impl.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../../domain/repositories/configuracion_repository.dart';
import '../../domain/repositories/equipo_repository.dart';
import '../../domain/repositories/orden_repository.dart';
import '../../domain/repositories/repuesto_repository.dart';
import '../../domain/repositories/tecnico_repository.dart';
import 'database_provider.dart';

/// Repositorios expuestos a la capa de presentación.
final clienteRepositoryProvider = Provider<ClienteRepository>((ref) {
  return ClienteRepositoryImpl(ref.watch(databaseProvider));
});

final equipoRepositoryProvider = Provider<EquipoRepository>((ref) {
  return EquipoRepositoryImpl(ref.watch(databaseProvider));
});

final tecnicoRepositoryProvider = Provider<TecnicoRepository>((ref) {
  return TecnicoRepositoryImpl(ref.watch(databaseProvider));
});

final repuestoRepositoryProvider = Provider<RepuestoRepository>((ref) {
  return RepuestoRepositoryImpl(ref.watch(databaseProvider));
});

final ordenRepositoryProvider = Provider<OrdenRepository>((ref) {
  return OrdenRepositoryImpl(ref.watch(databaseProvider));
});

final configuracionRepositoryProvider = Provider<ConfiguracionRepository>((ref) {
  return ConfiguracionRepositoryImpl(ref.watch(databaseProvider));
});

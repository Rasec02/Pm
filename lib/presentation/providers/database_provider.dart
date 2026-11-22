import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';

/// Instancia única de la base de datos Drift durante toda la sesión.
///
/// Se cierra cuando el contenedor de providers se destruye.
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

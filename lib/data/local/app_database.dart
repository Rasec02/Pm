import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/constants.dart';
import 'daos/clientes_dao.dart';
import 'daos/configuracion_dao.dart';
import 'daos/equipos_dao.dart';
import 'daos/ordenes_dao.dart';
import 'daos/repuestos_dao.dart';
import 'daos/tecnicos_dao.dart';
import 'daos/trabajos_dao.dart';
import 'daos/usos_repuesto_dao.dart';
import 'seed/seed_data.dart';
import 'tables/clientes.dart';
import 'tables/configuracion.dart';
import 'tables/equipos.dart';
import 'tables/ordenes.dart';
import 'tables/repuestos.dart';
import 'tables/tecnicos.dart';
import 'tables/trabajos_realizados.dart';
import 'tables/usos_repuesto.dart';

part 'app_database.g.dart';

/// Base de datos SQLite local de App Tu Solution.
///
/// Todo el estado del taller vive aquí: la app funciona sin conexión y los
/// datos sobreviven al cierre de la aplicación porque el archivo SQLite se
/// guarda en el directorio de documentos de la app.
@DriftDatabase(
  tables: [
    Clientes,
    Equipos,
    Tecnicos,
    Ordenes,
    TrabajosRealizados,
    Repuestos,
    UsosRepuesto,
    Configuracion,
  ],
  daos: [
    ClientesDao,
    EquiposDao,
    TecnicosDao,
    OrdenesDao,
    TrabajosDao,
    RepuestosDao,
    UsosRepuestoDao,
    ConfiguracionDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Abre (o crea) el archivo SQLite de la aplicación.
  AppDatabase() : super(_abrirBaseDeDatos());

  /// Constructor para pruebas: recibe un [QueryExecutor] ya construido.
  AppDatabase.paraPruebas(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _cargarDatosIniciales();
        },
        beforeOpen: (OpeningDetails details) async {
          // Necesario para que las claves foráneas se validen en SQLite.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Seed inicial: 3 técnicos, umbral de stock bajo y repuestos de ejemplo.
  /// Se ejecuta una sola vez, cuando se crea la base de datos.
  Future<void> _cargarDatosIniciales() async {
    for (final nombre in SeedData.tecnicos) {
      await into(tecnicos).insert(TecnicosCompanion.insert(nombre: nombre));
    }

    for (final repuesto in SeedData.repuestos) {
      await into(this.repuestos).insert(
        RepuestosCompanion.insert(
          codigo: repuesto.codigo,
          nombre: repuesto.nombre,
          precio: repuesto.precio,
          existencias: Value(repuesto.existencias),
        ),
      );
    }

    await into(configuracion).insertOnConflictUpdate(
      ConfiguracionCompanion.insert(
        clave: ConfiguracionKeys.umbralStockBajo,
        valor: '${ConfiguracionKeys.umbralStockBajoPorDefecto}',
      ),
    );
  }
}

/// Conexión perezosa al archivo SQLite de la app.
///
/// Se usa `NativeDatabase.createInBackground` para que las consultas corran en
/// un isolate aparte y no bloqueen la interfaz. El paquete
/// `sqlite3_flutter_libs` incluye la librería nativa de SQLite en Android.
LazyDatabase _abrirBaseDeDatos() {
  return LazyDatabase(() async {
    final carpeta = await getApplicationDocumentsDirectory();
    final archivo = File(p.join(carpeta.path, 'app_tu_solution.sqlite'));
    return NativeDatabase.createInBackground(archivo);
  });
}

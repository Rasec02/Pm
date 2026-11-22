import '../../domain/entities/repuesto.dart';
import '../../domain/exceptions/app_exceptions.dart';
import '../../domain/repositories/repuesto_repository.dart';
import '../local/app_database.dart';
import 'mappers.dart';

/// Implementación de [RepuestoRepository] sobre Drift.
class RepuestoRepositoryImpl implements RepuestoRepository {
  RepuestoRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Repuesto>> watchTodos() {
    return _db.repuestosDao.watchTodos().map(
          (filas) => filas.map((fila) => fila.aDominio()).toList(),
        );
  }

  @override
  Stream<List<Repuesto>> watchStockBajo(int umbral) {
    return _db.repuestosDao.watchStockBajo(umbral).map(
          (filas) => filas.map((fila) => fila.aDominio()).toList(),
        );
  }

  @override
  Future<List<Repuesto>> todos() async {
    final filas = await _db.repuestosDao.todos();
    return filas.map((fila) => fila.aDominio()).toList();
  }

  @override
  Future<Repuesto?> porId(int id) async {
    final fila = await _db.repuestosDao.porId(id);
    return fila?.aDominio();
  }

  @override
  Future<int> crear({
    required String codigo,
    required String nombre,
    required double precio,
    required int existencias,
  }) async {
    final codigoLimpio = codigo.trim().toUpperCase();
    final nombreLimpio = nombre.trim();
    if (codigoLimpio.isEmpty) {
      throw ValidacionException('El código del repuesto es obligatorio.');
    }
    if (nombreLimpio.isEmpty) {
      throw ValidacionException('El nombre del repuesto es obligatorio.');
    }
    if (precio < 0) {
      throw ValidacionException('El precio no puede ser negativo.');
    }
    if (existencias < 0) {
      throw ValidacionException('Las existencias no pueden ser negativas.');
    }
    final existente = await _db.repuestosDao.porCodigo(codigoLimpio);
    if (existente != null) {
      throw ValidacionException(
        'Ya existe un repuesto con el código $codigoLimpio.',
      );
    }
    return _db.repuestosDao.insertar(
      codigo: codigoLimpio,
      nombre: nombreLimpio,
      precio: precio,
      existencias: existencias,
    );
  }

  @override
  Future<void> actualizar({
    required int id,
    required String codigo,
    required String nombre,
    required double precio,
    required int existencias,
  }) async {
    final actual = await _db.repuestosDao.porId(id);
    if (actual == null) {
      throw ValidacionException('El repuesto ya no existe.');
    }
    final codigoLimpio = codigo.trim().toUpperCase();
    final nombreLimpio = nombre.trim();
    if (codigoLimpio.isEmpty || nombreLimpio.isEmpty) {
      throw ValidacionException('Código y nombre del repuesto son obligatorios.');
    }
    if (precio < 0 || existencias < 0) {
      throw ValidacionException('Precio y existencias no pueden ser negativos.');
    }
    final conMismoCodigo = await _db.repuestosDao.porCodigo(codigoLimpio);
    if (conMismoCodigo != null && conMismoCodigo.id != id) {
      throw ValidacionException(
        'El código $codigoLimpio ya está usado por otro repuesto.',
      );
    }
    await _db.repuestosDao.actualizar(
      actual.copyWith(
        codigo: codigoLimpio,
        nombre: nombreLimpio,
        precio: precio,
        existencias: existencias,
      ),
    );
  }

  @override
  Future<void> ajustarExistencias({
    required int id,
    required int delta,
  }) async {
    final actual = await _db.repuestosDao.porId(id);
    if (actual == null) {
      throw ValidacionException('El repuesto ya no existe.');
    }
    final nuevo = actual.existencias + delta;
    if (nuevo < 0) {
      throw ValidacionException('Las existencias no pueden ser negativas.');
    }
    await _db.repuestosDao.actualizar(
      actual.copyWith(existencias: nuevo),
    );
  }

  @override
  Future<void> eliminar(int id) async {
    final enUso = await _db.usosRepuestoDao.repuestoEstaEnUso(id);
    if (enUso) {
      throw RegistroEnUsoException(
        'No se puede eliminar el repuesto: ya fue usado en una orden.',
      );
    }
    await _db.repuestosDao.eliminar(id);
  }
}

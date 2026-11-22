import '../../domain/entities/cliente.dart';
import '../../domain/exceptions/app_exceptions.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../local/app_database.dart';
import 'mappers.dart';

/// Implementación de [ClienteRepository] sobre Drift.
class ClienteRepositoryImpl implements ClienteRepository {
  ClienteRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Cliente>> watchTodos() {
    return _db.clientesDao.watchTodos().map(
          (filas) => filas.map((fila) => fila.aDominio()).toList(),
        );
  }

  @override
  Future<List<Cliente>> todos() async {
    final filas = await _db.clientesDao.todos();
    return filas.map((fila) => fila.aDominio()).toList();
  }

  @override
  Future<Cliente?> porId(int id) async {
    final fila = await _db.clientesDao.porId(id);
    return fila?.aDominio();
  }

  @override
  Future<int> crear({required String nombre, required String telefono}) async {
    final nombreLimpio = nombre.trim();
    final telefonoLimpio = telefono.trim();
    if (nombreLimpio.isEmpty) {
      throw ValidacionException('El nombre del cliente es obligatorio.');
    }
    if (telefonoLimpio.isEmpty) {
      throw ValidacionException('El teléfono del cliente es obligatorio.');
    }
    return _db.clientesDao.insertar(
      nombre: nombreLimpio,
      telefono: telefonoLimpio,
    );
  }

  @override
  Future<void> actualizar({
    required int id,
    required String nombre,
    required String telefono,
  }) async {
    final actual = await _db.clientesDao.porId(id);
    if (actual == null) {
      throw ValidacionException('El cliente ya no existe.');
    }
    if (nombre.trim().isEmpty) {
      throw ValidacionException('El nombre del cliente es obligatorio.');
    }
    if (telefono.trim().isEmpty) {
      throw ValidacionException('El teléfono del cliente es obligatorio.');
    }
    await _db.clientesDao.actualizar(
      actual.copyWith(nombre: nombre.trim(), telefono: telefono.trim()),
    );
  }

  @override
  Future<void> eliminar(int id) async {
    final equipos = await _db.equiposDao.porCliente(id);
    if (equipos.isNotEmpty) {
      throw RegistroEnUsoException(
        'No se puede eliminar el cliente: tiene ${equipos.length} equipo(s) '
        'registrado(s).',
      );
    }
    await _db.clientesDao.eliminar(id);
  }
}

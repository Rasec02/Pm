import '../../domain/entities/equipo.dart';
import '../../domain/enums/tipo_equipo.dart';
import '../../domain/exceptions/app_exceptions.dart';
import '../../domain/repositories/equipo_repository.dart';
import '../local/app_database.dart';
import '../models/equipo_con_cliente.dart';
import 'mappers.dart';

/// Implementación de [EquipoRepository] sobre Drift.
class EquipoRepositoryImpl implements EquipoRepository {
  EquipoRepositoryImpl(this._db);

  final AppDatabase _db;

  Equipo _mapear(EquipoConCliente fila) => fila.equipo.aDominio();

  @override
  Stream<List<Equipo>> watchTodos() {
    return _db.equiposDao.watchTodos().map(
          (filas) => filas.map(_mapear).toList(),
        );
  }

  @override
  Stream<List<Equipo>> watchPorCliente(int clienteId) {
    return _db.equiposDao.watchPorCliente(clienteId).map(
          (filas) => filas.map(_mapear).toList(),
        );
  }

  @override
  Future<List<Equipo>> porCliente(int clienteId) async {
    final filas = await _db.equiposDao.porCliente(clienteId);
    return filas.map(_mapear).toList();
  }

  @override
  Future<Equipo?> porId(int id) async {
    final fila = await _db.equiposDao.porId(id);
    return fila?.aDominio();
  }

  @override
  Future<int> crear({
    required TipoEquipo tipo,
    required String marca,
    required String modelo,
    required String numeroSerie,
    required int clienteId,
  }) async {
    if (marca.trim().isEmpty) {
      throw ValidacionException('La marca del equipo es obligatoria.');
    }
    if (modelo.trim().isEmpty) {
      throw ValidacionException('El modelo del equipo es obligatorio.');
    }
    if (numeroSerie.trim().isEmpty) {
      throw ValidacionException('El número de serie es obligatorio.');
    }
    return _db.equiposDao.insertar(
      tipo: tipo.name,
      marca: marca.trim(),
      modelo: modelo.trim(),
      numeroSerie: numeroSerie.trim(),
      clienteId: clienteId,
    );
  }

  @override
  Future<void> eliminar(int id) async {
    final ordenes = await _db.ordenesDao.contarPorEquipo(id);
    if (ordenes > 0) {
      throw RegistroEnUsoException(
        'No se puede eliminar el equipo: tiene $ordenes orden(es) asociada(s).',
      );
    }
    await _db.equiposDao.eliminar(id);
  }
}

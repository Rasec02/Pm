import '../entities/equipo.dart';
import '../enums/tipo_equipo.dart';

/// Contrato de acceso a equipos.
abstract class EquipoRepository {
  Stream<List<Equipo>> watchTodos();

  Stream<List<Equipo>> watchPorCliente(int clienteId);

  Future<List<Equipo>> porCliente(int clienteId);

  Future<Equipo?> porId(int id);

  Future<int> crear({
    required TipoEquipo tipo,
    required String marca,
    required String modelo,
    required String numeroSerie,
    required int clienteId,
  });

  Future<void> eliminar(int id);
}

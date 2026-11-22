import '../entities/cliente.dart';

/// Contrato de acceso a clientes / dueños.
abstract class ClienteRepository {
  Stream<List<Cliente>> watchTodos();

  Future<List<Cliente>> todos();

  Future<Cliente?> porId(int id);

  Future<int> crear({required String nombre, required String telefono});

  Future<void> actualizar({
    required int id,
    required String nombre,
    required String telefono,
  });

  Future<void> eliminar(int id);
}

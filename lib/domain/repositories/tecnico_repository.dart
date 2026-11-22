import '../entities/tecnico.dart';

/// Contrato de acceso a técnicos.
abstract class TecnicoRepository {
  Stream<List<Tecnico>> watchTodos();
}

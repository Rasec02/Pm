import '../local/app_database.dart';

/// Equipo junto con los datos de su dueño.
class EquipoConCliente {
  const EquipoConCliente({required this.equipo, required this.cliente});

  final EquipoRow equipo;
  final ClienteRow cliente;
}

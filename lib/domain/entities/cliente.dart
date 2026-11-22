/// Cliente / dueño de uno o varios equipos.
class Cliente {
  const Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
  });

  final int id;
  final String nombre;
  final String telefono;
}

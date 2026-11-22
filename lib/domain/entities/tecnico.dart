/// Técnico del taller. No hay autenticación: solo se identifica por nombre.
class Tecnico {
  const Tecnico({
    required this.id,
    required this.nombre,
  });

  final int id;
  final String nombre;
}

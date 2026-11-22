/// Datos iniciales que se cargan la primera vez que se crea la base de datos.
class SeedData {
  const SeedData._();

  /// Los 3 técnicos fijos del taller. Sin autenticación: solo nombre.
  static const List<String> tecnicos = <String>[
    'Carlos Méndez',
    'Luis Herrera',
    'Ana Torres',
  ];

  /// Repuestos de ejemplo con stock inicial variado, para poder demostrar la
  /// alerta de stock bajo durante la demo.
  static const List<RepuestoSeed> repuestos = <RepuestoSeed>[
    RepuestoSeed(
      codigo: 'PAN-IP11',
      nombre: 'Pantalla iPhone 11',
      precio: 85.00,
      existencias: 5,
    ),
    RepuestoSeed(
      codigo: 'BAT-SAM-A51',
      nombre: 'Batería Samsung A51',
      precio: 22.50,
      existencias: 3,
    ),
    RepuestoSeed(
      codigo: 'CON-TYPEC',
      nombre: 'Puerto de carga USB-C',
      precio: 12.00,
      existencias: 2,
    ),
    RepuestoSeed(
      codigo: 'TEC-LAP-HP',
      nombre: 'Teclado laptop HP 15',
      precio: 45.00,
      existencias: 1,
    ),
    RepuestoSeed(
      codigo: 'DIS-SSD-480',
      nombre: 'Disco SSD 480 GB',
      precio: 55.00,
      existencias: 8,
    ),
    RepuestoSeed(
      codigo: 'PEG-ADHESIVO',
      nombre: 'Adhesivo para pantalla',
      precio: 4.50,
      existencias: 0,
    ),
    RepuestoSeed(
      codigo: 'VEN-TAB-IPAD',
      nombre: 'Ventilador iPad (flex)',
      precio: 9.75,
      existencias: 2,
    ),
  ];
}

/// Definición de un repuesto de ejemplo para el seed.
class RepuestoSeed {
  const RepuestoSeed({
    required this.codigo,
    required this.nombre,
    required this.precio,
    required this.existencias,
  });

  final String codigo;
  final String nombre;
  final double precio;
  final int existencias;
}

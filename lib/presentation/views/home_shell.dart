import 'package:flutter/material.dart';

import 'carga_trabajo/carga_trabajo_view.dart';
import 'historial/historial_view.dart';
import 'inventario/inventario_view.dart';
import 'ordenes/ordenes_lista_view.dart';
import 'registro/registro_view.dart';

/// Contenedor principal con la navegación inferior de la app.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // Este estado es puramente de navegación: no contiene lógica de negocio.
  int _indice = 0;

  static const List<Widget> _pantallas = <Widget>[
    OrdenesListaView(),
    CargaTrabajoView(),
    HistorialView(),
    InventarioView(),
    RegistroView(),
  ];

  static const List<String> _titulos = <String>[
    'Órdenes abiertas',
    'Carga de trabajo',
    'Historial',
    'Inventario',
    'Clientes y equipos',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_indice]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                const Icon(Icons.build_circle_outlined, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Tu Solution',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _indice,
        children: _pantallas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (nuevo) => setState(() => _indice = nuevo),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Órdenes',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Carga',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventario',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Registro',
          ),
        ],
      ),
    );
  }
}

# App Tu Solution

Aplicación Android para el taller de reparación **Tu Solution** (celulares, tablets y laptops).
La usan los **3 técnicos** del taller: no hay login, no hay clientes conectados y no hay
notificaciones. Todo el trabajo se guarda en el teléfono con **SQLite (Drift)** y funciona
sin internet.

## Funcionalidad

- **Órdenes abiertas** con estado y técnico responsable visibles, con filtros por estado y por técnico.
- **Detalle de orden**: equipo, dueño, falla reportada, estado, responsable, trabajos de mano de obra,
  repuestos usados, **costo total** y acciones (tomar, cambiar estado, agregar trabajo, agregar repuesto).
- **Responsable único**: tomar una orden es una actualización condicional atómica; si otro técnico ya
  la tomó, la app lo informa y no se sobreescribe.
- **Carga de trabajo por técnico**: órdenes abiertas asignadas a cada uno.
- **Historial por equipo y por cliente** (equipos que vuelven al taller), con costo de cada reparación.
- **Inventario de repuestos** con CRUD, descuento automático de stock en una transacción y
  **alerta de stock bajo con umbral configurable** (por defecto 3, incluidos los agotados).
- **Alta de clientes, equipos y órdenes** desde la misma app.
- **Seed inicial**: 3 técnicos (Carlos Méndez, Luis Herrera, Ana Torres) y 7 repuestos de ejemplo,
  varios de ellos en o bajo el umbral para poder demostrar la alerta.

### Stack

| Paquete | Uso |
|---------|-----|
| `drift` + `drift_dev` (misma línea de versión, 2.28–2.29) | Base de datos SQLite, DAOs y generación de código |
| `sqlite3_flutter_libs` + `path_provider` | Librería nativa de SQLite y ubicación del archivo `.sqlite` en el teléfono |
| `flutter_riverpod` 2.x | Estado con `Notifier` / `StreamProvider`, providers por feature |
| `build_runner` | Genera `*.g.dart` (no se versionan) |
| `flutter_lints` | Reglas de `flutter analyze` |

Versiones fijadas en `android/`: Gradle 8.12, AGP 8.9.1 y Kotlin 2.1.0. Si tu instalación de
Flutter espera otras, cámbialas en `android/gradle/wrapper/gradle-wrapper.properties` y en
`android/settings.gradle.kts`.

Drift se abre con `NativeDatabase.createInBackground`, por lo que las consultas se ejecutan en un
isolate aparte y no bloquean la interfaz del taller.

## Requisitos

- Flutter estable con Dart 3.47.7 o superior (el `pubspec.yaml` declara `sdk: ">=3.47.7 <4.0.0"`).
  Valida la versión instalada con:

  ```bash
  flutter --version
  ```

- Android SDK (API 24 o superior) y un emulador o teléfono con depuración USB.
- JDK 17 a 21 (ver la sección **JDK** más abajo).

## Puesta en marcha

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Los archivos `*.g.dart` (código generado por Drift) **no se versionan**: se generan con el comando
de `build_runner`. Si el comando falla por conflictos previos, usa
`dart run build_runner build --delete-conflicting-outputs` (ya incluido) o
`dart run build_runner clean` y vuelve a ejecutarlo.

> El wrapper de Gradle (`gradlew`, `gradlew.bat` y `gradle/wrapper/gradle-wrapper.jar`) no se
> versiona porque son binarios generados. Flutter lo reconstruye automáticamente la primera vez
> que ejecutas `flutter run` (los inyecta desde su caché). Si prefieres tenerlo en el repo, ejecuta
> `flutter create --platforms=android .` una vez y quedará generado.

### JDK

La máquina de desarrollo puede tener **JDK 25** instalado, que todavía no es compatible con
Gradle/AGP de algunas versiones de Flutter. Si `flutter run` falla con un error de Gradle
relacionado con la versión de Java, apunta Gradle a un **JDK 17–21**:

1. Opción A: descomenta y ajusta la línea en `android/gradle.properties`:

   ```properties
   org.gradle.java.home=/ruta/al/jdk-17
   ```

2. Opción B: exporta la variable de entorno antes de ejecutar Flutter:

   ```bash
   export JAVA_HOME=/ruta/al/jdk-17
   flutter run
   ```

Verifica la versión con `java -version`. Con JDK 25 instalado el proyecto compila igualmente si tu
versión de Flutter y de AGP (8.9.1 en este proyecto) ya lo soportan; el cambio solo es necesario si
Gradle se queja de la versión de Java.

## Estructura del proyecto

```
lib/
├── main.dart                       # Punto de entrada (ProviderScope)
├── app.dart                        # MaterialApp + tema
├── core/
│   ├── theme/app_theme.dart        # Colores, estados y tema Material 3
│   └── utils/formato.dart          # Formato de dinero y fechas
├── domain/                         # Reglas de negocio, sin Flutter ni Drift
│   ├── constants.dart              # Claves de configuración y umbral por defecto (3)
│   ├── entities/                   # Cliente, Equipo, Técnico, Orden, Trabajo, Repuesto, Uso, Costo
│   ├── enums/                      # EstadoOrden (flujo y transiciones), TipoEquipo
│   ├── exceptions/                 # Errores de negocio con mensajes para la UI
│   ├── repositories/               # Contratos de los repositorios
│   └── usecases/                   # Casos de uso (recibir, tomar, cambiar estado, inventario, historial)
├── data/                           # Persistencia con Drift
│   ├── local/
│   │   ├── tables/                 # Definición de tablas SQLite
│   │   ├── daos/                   # Consultas y transacciones por agregado
│   │   ├── seed/seed_data.dart     # Técnicos y repuestos iniciales
│   │   └── app_database.dart       # @DriftDatabase, migración y seed inicial
│   ├── models/                     # Resultados de joins (orden + equipo + dueño + técnico)
│   └── repositories/               # Implementación de los contratos + mappers
└── presentation/                   # MVVM con Riverpod
    ├── providers/                  # Base de datos, repositorios, casos de uso y catálogos
    ├── viewmodels/                 # Notifier/StreamProvider por feature (incluye InventarioViewModel)
    ├── widgets/                    # Tarjetas, badges, selectores y formateadores de entrada
    └── views/                      # Pantallas
        ├── ordenes/                # Lista, detalle, nueva orden, hojas de trabajo y repuesto
        ├── carga_trabajo/          # Carga por técnico
        ├── historial/              # Historial por cliente y por equipo
        ├── inventario/             # CRUD de repuestos, umbral, formularios
        └── registro/               # Clientes y equipos
```

### Arquitectura (MVVM)

- **domain**: entidades inmutables, enums con las reglas de transición (`EstadoOrden.siguientes`),
  excepciones de negocio y casos de uso finos que envuelven los repositorios.
- **data**: tablas Drift, DAOs con las consultas y **todas las transacciones atómicas**
  (tomar orden, descontar stock, cambiar estado, devolver repuesto). Los repositorios validan datos
  y convierten filas de Drift a entidades de dominio.
- **presentation**: los widgets no contienen lógica de negocio; solo leen ViewModels
  (`NotifierProvider` / `StreamProvider`) y llaman a sus métodos. Los únicos `setState` son de
  navegación (pestaña inferior seleccionada) y de estado puramente visual de los formularios
  (qué cliente o equipo está elegido en un desplegable y el texto de error de validación); nunca
  tocan la base de datos ni calculan reglas de negocio.

## Uso rápido (demo)

1. Pestaña **Registro**: crea un cliente y su equipo (o usa *Recibir equipo*).
2. Pestaña **Órdenes**: abre la orden y **tómala** como uno de los 3 técnicos.
3. Agrega un **trabajo** con su costo y un **repuesto**: verás cómo baja el stock y cómo se
   actualiza el **costo total**.
4. Cambia el estado a **Lista** y luego a **Entregada** (queda la fecha de entrega).
5. Revisa **Historial**: por cliente y por equipo, con el costo de cada reparación.
6. En **Inventario** cambia el umbral de stock bajo y observa la lista de repuestos por agotarse.

## Lista de verificación para la demo en vivo

| # | Paso | Qué debe verse |
|---|------|----------------|
| 1 | Recibir un equipo (Registro → Recibir equipo) | Orden creada en estado **Recibida**, sin responsable |
| 2 | Abrir la orden y tomarla como técnico | Estado **En reparación** y responsable visible para todos |
| 3 | Intentar tomarla con otro técnico | Mensaje de error: solo puede haber un responsable |
| 4 | Agregar trabajo de mano de obra | Aparece en la lista y sube el subtotal de mano de obra |
| 5 | Agregar repuesto (cantidad 1) | El stock baja en Inventario y sube el subtotal de repuestos |
| 6 | Intentar agregar más repuestos que el stock | Mensaje de stock insuficiente, no se descuenta nada |
| 7 | Ver el costo total | Mano de obra + repuestos en la tarjeta de la orden |
| 8 | Marcar **Lista** y luego **Entregada** | Cambian los estados y se guarda la fecha de entrega |
| 9 | Abrir Historial → cliente y equipo | Se ve la reparación con su costo |
| 10 | Cambiar el umbral en Inventario | La alerta de stock bajo se recalcula al instante |
| 11 | Cerrar y reabrir la app | Todos los datos siguen ahí (SQLite local) |

## Publicar en GitHub

1. Crea el repositorio vacío en GitHub (sin README para evitar conflictos).
2. Sube el proyecto **como código fuente**, sin `.rar` ni `.zip`:

   ```bash
   git init
   git add .
   git commit -m "App Tu Solution: gestión de órdenes, inventario e historial"
   git branch -M main
   git remote add origin https://github.com/<usuario>/app-tu-solution.git
   git push -u origin main
   ```

3. Verifica que **no** se suban `build/`, `.dart_tool/`, `*.g.dart` ni archivos comprimidos:
   el `.gitignore` del proyecto ya los excluye.
4. Las **capturas de pantalla reales** van en `docs/screenshots/` con nombres descriptivos:

   ```
   docs/screenshots/01-ordenes-abiertas.png
   docs/screenshots/02-detalle-orden.png
   docs/screenshots/03-tomar-orden.png
   docs/screenshots/04-inventario-stock-bajo.png
   docs/screenshots/05-historial-equipo.png
   docs/screenshots/06-historial-cliente.png
   docs/screenshots/07-carga-trabajo.png
   ```

   La descripción de cada captura está en `docs/screenshots/README.md`.

   Tómalas del emulador o del teléfono (`Ctrl+Shift+4`/`Power+Vol-`) y enlázalas en el README
   con `![Órdenes abiertas](docs/screenshots/01-ordenes-abiertas.png)`.

## Pruebas

```bash
flutter test
```

Los tests de `test/app_database_test.dart` cubren el seed, la toma única de una orden, el descuento
de stock, la validación de stock insuficiente, el flujo de estados, el costo total, el historial y
el umbral configurable. Usan una base de datos en memoria (`NativeDatabase.memory()`).

## Notas de alcance

- Sin autenticación: los 3 técnicos se eligen de una lista.
- Sin notificaciones ni comunicación con clientes.
- Sin paquetes fuera del stack pedido: `drift`, `drift_dev`, `build_runner`, `flutter_riverpod`,
  `sqlite3_flutter_libs`, `path_provider`, `path` y `flutter_lints`.

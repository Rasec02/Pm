import '../../domain/entities/cliente.dart';
import '../../domain/entities/equipo.dart';
import '../../domain/entities/orden.dart';
import '../../domain/entities/repuesto.dart';
import '../../domain/entities/tecnico.dart';
import '../../domain/entities/trabajo_realizado.dart';
import '../../domain/entities/uso_repuesto.dart';
import '../../domain/enums/estado_orden.dart';
import '../../domain/enums/tipo_equipo.dart';
import '../local/app_database.dart';
import '../models/orden_con_detalle.dart';
import '../models/uso_repuesto_con_repuesto.dart';

/// Conversión de filas de Drift a entidades de dominio.
extension ClienteRowX on ClienteRow {
  Cliente aDominio() => Cliente(id: id, nombre: nombre, telefono: telefono);
}

extension EquipoRowX on EquipoRow {
  Equipo aDominio() => Equipo(
        id: id,
        tipo: TipoEquipo.desdeNombre(tipo),
        marca: marca,
        modelo: modelo,
        numeroSerie: numeroSerie,
        clienteId: clienteId,
      );
}

extension TecnicoRowX on TecnicoRow {
  Tecnico aDominio() => Tecnico(id: id, nombre: nombre);
}

extension RepuestoRowX on RepuestoRow {
  Repuesto aDominio() => Repuesto(
        id: id,
        codigo: codigo,
        nombre: nombre,
        precio: precio,
        existencias: existencias,
      );
}

extension TrabajoRowX on TrabajoRow {
  TrabajoRealizado aDominio() => TrabajoRealizado(
        id: id,
        ordenId: ordenId,
        descripcion: descripcion,
        costoManoObra: costoManoObra,
        fechaRegistro: fechaRegistro,
      );
}

extension UsoRepuestoConRepuestoX on UsoRepuestoConRepuesto {
  UsoRepuesto aDominio() => UsoRepuesto(
        id: uso.id,
        ordenId: uso.ordenId,
        repuestoId: uso.repuestoId,
        codigo: repuesto.codigo,
        nombre: repuesto.nombre,
        cantidad: uso.cantidad,
        precioUnitario: uso.precioUnitario,
        fechaRegistro: uso.fechaRegistro,
      );
}

extension OrdenConDetalleX on OrdenConDetalle {
  Orden aDominio() => Orden(
        id: orden.id,
        equipoId: orden.equipoId,
        fallaReportada: orden.fallaReportada,
        estado: EstadoOrden.desdeNombre(orden.estado),
        fechaRecepcion: orden.fechaRecepcion,
        fechaEntrega: orden.fechaEntrega,
        tipoEquipo: TipoEquipo.desdeNombre(equipo.tipo).etiqueta,
        marca: equipo.marca,
        modelo: equipo.modelo,
        numeroSerie: equipo.numeroSerie,
        clienteId: cliente.id,
        clienteNombre: cliente.nombre,
        clienteTelefono: cliente.telefono,
        tecnicoId: tecnico?.id,
        tecnicoNombre: tecnico?.nombre,
      );
}

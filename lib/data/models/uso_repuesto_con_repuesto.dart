import '../local/app_database.dart';

/// Uso de repuesto junto con los datos del repuesto.
class UsoRepuestoConRepuesto {
  const UsoRepuestoConRepuesto({required this.uso, required this.repuesto});

  final UsoRepuestoRow uso;
  final RepuestoRow repuesto;
}

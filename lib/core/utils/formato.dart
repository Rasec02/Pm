/// Utilidades de formato usadas por las vistas.
class Formato {
  const Formato._();

  /// Formatea un monto con dos decimales y separador de miles simple.
  static String dinero(double valor) {
    final negativo = valor < 0;
    final texto = valor.abs().toStringAsFixed(2);
    final partes = texto.split('.');
    final entero = partes.first;
    final buffer = StringBuffer();
    for (var i = 0; i < entero.length; i++) {
      buffer.write(entero[i]);
      final restante = entero.length - 1 - i;
      if (restante > 0 && restante % 3 == 0) {
        buffer.write(',');
      }
    }
    final signo = negativo ? '-' : '';
    return '$signo\$${buffer.toString()}.${partes.last}';
  }

  /// Fecha corta dd/mm/aaaa.
  static String fecha(DateTime? fecha) {
    if (fecha == null) return '—';
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  /// Fecha y hora dd/mm/aaaa hh:mm.
  static String fechaHora(DateTime? fecha) {
    if (fecha == null) return '—';
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '${fecha(fecha)} $hora:$minuto';
  }

  /// Convierte un texto a double aceptando coma o punto decimal.
  static double? aDouble(String texto) {
    final limpio = texto.trim().replaceAll(',', '.');
    if (limpio.isEmpty) return null;
    return double.tryParse(limpio);
  }

  /// Convierte un texto a entero.
  static int? aEntero(String texto) {
    final limpio = texto.trim();
    if (limpio.isEmpty) return null;
    return int.tryParse(limpio);
  }
}

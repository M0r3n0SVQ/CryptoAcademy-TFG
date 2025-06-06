class TransaccionApiModel {
  final int idTransaccion;
  final String usuarioEmail;
  final int idCartera;
  final String idCriptomoneda;
  final String simboloCriptomoneda;
  final String nombreCriptomoneda;
  final String tipoTransaccion;
  final double cantidadCripto;
  final double precioPorUnidadEUR;
  final double valorTotalEUR;
  final String fechaTransaccion;

  TransaccionApiModel({
    required this.idTransaccion,
    required this.usuarioEmail,
    required this.idCartera,
    required this.idCriptomoneda,
    required this.simboloCriptomoneda,
    required this.nombreCriptomoneda,
    required this.tipoTransaccion,
    required this.cantidadCripto,
    required this.precioPorUnidadEUR,
    required this.valorTotalEUR,
    required this.fechaTransaccion,
  });

  factory TransaccionApiModel.fromJson(Map<String, dynamic> json) {
    return TransaccionApiModel(
      idTransaccion: json['idTransaccion'] as int,
      usuarioEmail: json['usuarioEmail'] as String,
      idCartera: json['idCartera'] as int,
      idCriptomoneda: json['idCriptomoneda'] as String,
      simboloCriptomoneda: json['simboloCriptomoneda'] as String,
      nombreCriptomoneda: json['nombreCriptomoneda'] as String,
      tipoTransaccion: json['tipoTransaccion'] as String,
      cantidadCripto: (json['cantidadCripto'] as num).toDouble(),
      precioPorUnidadEUR: (json['precioPorUnidadEUR'] as num).toDouble(),
      valorTotalEUR: (json['valorTotalEUR'] as num).toDouble(),
      fechaTransaccion: json['fechaTransaccion'] as String,
    );
  }
}

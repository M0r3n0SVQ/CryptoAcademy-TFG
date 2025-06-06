import 'package:intl/intl.dart';
class RankingItemModel {
  final int posicion;
  final int? idUsuario;
  final String nombreUsuario;
  final String emailOculto;
  final double valorTotalPortfolioEUR;

  RankingItemModel({
    required this.posicion,
    this.idUsuario,
    required this.nombreUsuario,
    required this.emailOculto,
    required this.valorTotalPortfolioEUR,
  });

  factory RankingItemModel.fromJson(Map<String, dynamic> json) {
    return RankingItemModel(
      posicion: json['posicion'] as int? ?? 0,
      idUsuario: json['idUsuario'] as int?,
      nombreUsuario: json['nombreUsuario'] as String? ?? 'Usuario Desconocido',
      emailOculto: json['emailOculto'] as String? ?? '---',
      valorTotalPortfolioEUR: (json['valorTotalPortfolioEUR'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get valorPortfolioFormateado {
    final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 2);
    return currencyFormatter.format(valorTotalPortfolioEUR);
  }
}

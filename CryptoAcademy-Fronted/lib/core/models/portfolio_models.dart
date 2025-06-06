class PortfolioItemModel {
  final String idCriptomoneda;
  final String nombreCriptomoneda;
  final String simboloCriptomoneda;
  final String? imagenUrl;
  final double cantidadPoseida;
  final double precioActualPorUnidadEUR;
  final double valorTotalTenenciaEUR;
  final double? cambioPorcentaje24h;

  PortfolioItemModel({
    required this.idCriptomoneda,
    required this.nombreCriptomoneda,
    required this.simboloCriptomoneda,
    this.imagenUrl,
    required this.cantidadPoseida,
    required this.precioActualPorUnidadEUR,
    required this.valorTotalTenenciaEUR,
    this.cambioPorcentaje24h,
  });

  factory PortfolioItemModel.fromJson(Map<String, dynamic> json) {
    return PortfolioItemModel(
      idCriptomoneda: json['idCriptomoneda'] as String,
      nombreCriptomoneda: json['nombreCriptomoneda'] as String,
      simboloCriptomoneda: json['simboloCriptomoneda'] as String,
      imagenUrl: json['imagenUrl'] as String?,
      cantidadPoseida: (json['cantidadPoseida'] as num?)?.toDouble() ?? 0.0,
      precioActualPorUnidadEUR: (json['precioActualPorUnidadEUR'] as num?)?.toDouble() ?? 0.0,
      valorTotalTenenciaEUR: (json['valorTotalTenenciaEUR'] as num?)?.toDouble() ?? 0.0,
      cambioPorcentaje24h: (json['cambioPorcentaje24h'] as num?)?.toDouble(),
    );
  }
}

class PortfolioResponseModel {
  final int idCartera;
  final String nombreCartera;
  final double saldoVirtualEUR;
  final List<PortfolioItemModel> items;
  final double valorTotalCriptosEUR;
  final double valorTotalPortfolioEUR;

  PortfolioResponseModel({
    required this.idCartera,
    required this.nombreCartera,
    required this.saldoVirtualEUR,
    required this.items,
    required this.valorTotalCriptosEUR,
    required this.valorTotalPortfolioEUR,
  });

  factory PortfolioResponseModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<PortfolioItemModel> parsedItems = itemsList
        .map((itemJson) => PortfolioItemModel.fromJson(itemJson as Map<String, dynamic>))
        .toList();

    return PortfolioResponseModel(
      idCartera: json['idCartera'] as int,
      nombreCartera: json['nombreCartera'] as String? ?? 'Cartera',
      saldoVirtualEUR: (json['saldoVirtualEUR'] as num?)?.toDouble() ?? 0.0,
      items: parsedItems,
      valorTotalCriptosEUR: (json['valorTotalCriptosEUR'] as num?)?.toDouble() ?? 0.0,
      valorTotalPortfolioEUR: (json['valorTotalPortfolioEUR'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

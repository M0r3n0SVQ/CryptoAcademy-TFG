class OrdenRequestModel {
  final int idCartera;
  final String idCriptomoneda;
  final String cantidad;

  OrdenRequestModel({
    required this.idCartera,
    required this.idCriptomoneda,
    required this.cantidad,
  });

  Map<String, dynamic> toJson() {
    return {
      'idCartera': idCartera,
      'idCriptomoneda': idCriptomoneda,
      'cantidad': cantidad,
    };
  }
}

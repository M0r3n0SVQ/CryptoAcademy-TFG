class PaginatedCriptoResponse {
  final List<CriptoApiModel> content;
  final int totalPages;
  final int totalElements;
  final int number;
  final int size;
  final bool first;
  final bool last;
  final bool empty;

  PaginatedCriptoResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.number,
    required this.size,
    required this.first,
    required this.last,
    required this.empty,
  });

  factory PaginatedCriptoResponse.fromJson(Map<String, dynamic> json) {
    var list = json['content'] as List;
    List<CriptoApiModel> criptoContent = list.map((i) => CriptoApiModel.fromJson(i)).toList();

    return PaginatedCriptoResponse(
      content: criptoContent,
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
      empty: json['empty'] as bool? ?? true,
    );
  }
}



class CriptoApiModel {
  final String id;
  final String nombre;
  final String simbolo;
  final double? precioActual;
  final String? imagen;
  final double? capitalizacion;
  final double? volumen24h;
  final double? cambioPorcentaje24h;
  final String? fechaActualizacion;

  CriptoApiModel({
    required this.id,
    required this.nombre,
    required this.simbolo,
    this.precioActual,
    this.imagen,
    this.capitalizacion,
    this.volumen24h,
    this.cambioPorcentaje24h,
    this.fechaActualizacion,
  });

  factory CriptoApiModel.fromJson(Map<String, dynamic> json) {
    return CriptoApiModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      simbolo: json['simbolo'] as String,
      precioActual: (json['precioActual'] as num?)?.toDouble(),
      imagen: json['imagen'] as String?,
      capitalizacion: (json['capitalizacionMercado'] as num?)?.toDouble(),
      volumen24h: (json['volumen24h'] as num?)?.toDouble(),
      cambioPorcentaje24h: (json['cambio24h'] as num?)?.toDouble(),
      fechaActualizacion: json['fechaActualizacion'] as String?,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'simbolo': simbolo,
      'precioActual': precioActual,
      'imagen': imagen,
      'capitalizacionMercado': capitalizacion,
      'volumen24h': volumen24h,
      'cambioPorcentaje24h': cambioPorcentaje24h,
      'fechaActualizacion': fechaActualizacion,
    };
  }
}

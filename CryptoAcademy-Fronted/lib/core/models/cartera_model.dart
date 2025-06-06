class CarteraModel {
  final int idCartera;
  final String nombre;
  final double saldoVirtualEUR; 
  final int? idUsuario;
  final DateTime? fechaCreacion;

  CarteraModel({
    required this.idCartera,
    required this.nombre,
    required this.saldoVirtualEUR,
    this.idUsuario,
    this.fechaCreacion,
  });

  factory CarteraModel.fromJson(Map<String, dynamic> json) {
    return CarteraModel(
      idCartera: json['idCartera'] as int,
      nombre: json['nombre'] as String? ?? 'Cartera sin nombre',
      saldoVirtualEUR: (json['saldo'] as num?)?.toDouble() ?? 0.0, 
      idUsuario: json['idUsuario'] as int?,
      fechaCreacion: json['fechaCreacion'] == null
          ? null
          : DateTime.tryParse(json['fechaCreacion'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCartera': idCartera,
      'nombre': nombre,
      'saldo': saldoVirtualEUR, 
      'idUsuario': idUsuario,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
    };
  }

  CarteraModel copyWith({
    int? idCartera,
    String? nombre,
    double? saldoVirtualEUR,
    int? idUsuario,
    DateTime? fechaCreacion,
  }) {
    return CarteraModel(
      idCartera: idCartera ?? this.idCartera,
      nombre: nombre ?? this.nombre,
      saldoVirtualEUR: saldoVirtualEUR ?? this.saldoVirtualEUR,
      idUsuario: idUsuario ?? this.idUsuario,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarteraModel &&
          runtimeType == other.runtimeType &&
          idCartera == other.idCartera;

  @override
  int get hashCode => idCartera.hashCode;
}

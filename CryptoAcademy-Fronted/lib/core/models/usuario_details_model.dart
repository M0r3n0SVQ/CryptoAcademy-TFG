
class UsuarioDetailsModel {
  final int id;
  final String nombre;
  final String email;
  final String fechaRegistro;
  final String rol;

  UsuarioDetailsModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.fechaRegistro,
    required this.rol,
  });

  factory UsuarioDetailsModel.fromJson(Map<String, dynamic> json) {
    return UsuarioDetailsModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      fechaRegistro: json['fechaRegistro'] as String,
      rol: json['rol'] as String,
    );
  }
}

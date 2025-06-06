class LoginResponseModel {
  final String token;
  final bool success;
  final String message;

  LoginResponseModel({
    required this.token,
    required this.success,
    required this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('data') && 
        json['data'] is Map<String, dynamic> && 
        (json['data'] as Map<String, dynamic>).containsKey('token') &&
        json['data']['token'] != null) {
      return LoginResponseModel(
        token: json['data']['token'] as String,
        success: json['success'] as bool? ?? false,
        message: json['message'] as String? ?? 'Mensaje no disponible',
      );
    } else {
      print('LoginResponseModel.fromJson: Estructura JSON inesperada o token faltante. JSON: $json');
      throw FormatException('Respuesta de login inválida: falta el token en data.token o la estructura es incorrecta.');
    }
  }
}

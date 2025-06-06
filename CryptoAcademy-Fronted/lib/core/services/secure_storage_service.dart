import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage(
  );

  // Clave bajo la cual guardaremos el token JWT
  static const String _jwtTokenKey = 'jwt_token';

  /// Guarda el token JWT de forma segura.
  Future<void> saveJwtToken(String token) async {
    try {
      await _storage.write(key: _jwtTokenKey, value: token);
      print('SecureStorageService: Token JWT guardado de forma segura.');
    } catch (e) {
      print('SecureStorageService: Error al guardar el token JWT: $e');
    }
  }

  Future<String?> getJwtToken() async {
    try {
      final token = await _storage.read(key: _jwtTokenKey);
      if (token != null) {
        print('SecureStorageService: Token JWT recuperado.');
      } else {
        print('SecureStorageService: No se encontró token JWT guardado.');
      }
      return token;
    } catch (e) {
      print('SecureStorageService: Error al leer el token JWT: $e');
      return null;
    }
  }

  Future<void> deleteJwtToken() async {
    try {
      await _storage.delete(key: _jwtTokenKey);
      print('SecureStorageService: Token JWT eliminado.');
    } catch (e) {
      print('SecureStorageService: Error al eliminar el token JWT: $e');
    }
  }
}

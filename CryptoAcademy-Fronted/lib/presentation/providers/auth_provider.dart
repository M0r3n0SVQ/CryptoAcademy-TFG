// lib/presentation/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cryptoacademy_app/core/services/secure_storage_service.dart';
import 'cartera_provider.dart'; // Asegúrate que la ruta es correcta
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthProvider with ChangeNotifier {
  final SecureStorageService _storageService = SecureStorageService();

  String? _token;
  String? _loginSuccessMessage;

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  String? get loginSuccessMessage => _loginSuccessMessage;

  AuthProvider() {
    print("AuthProvider: Constructor INVOCADO. Auto-login DESHABILITADO.");
  }

  Future<void> login(String token, BuildContext context) async {
    print('AuthProvider: Login manual llamado con token.');
    _token = token;
    await _storageService.saveJwtToken(token);
    
    _loginSuccessMessage = '¡Inicio de sesión exitoso!'; // Establecer mensaje de éxito

    try {
      await Provider.of<CarteraProvider>(context, listen: false).fetchCarterasUsuario();
      print('AuthProvider: Carteras cargadas después del login manual.');
    } catch (e) {
      print('AuthProvider: Error al cargar carteras después del login manual: $e');
    }
    
    notifyListeners();
    print('AuthProvider: Estado de autenticación actualizado, token guardado, mensaje de éxito establecido.');
  }

  // Método para limpiar el mensaje de éxito
  void clearLoginSuccessMessage() {
    if (_loginSuccessMessage != null) {
      _loginSuccessMessage = null;
      notifyListeners(); 
      print('AuthProvider: Mensaje de éxito de login limpiado.');
    }
  }

  Future<void> logout(BuildContext context) async {
    print('AuthProvider: Logout llamado.');
    _token = null;
    _loginSuccessMessage = null; // Limpiar mensaje al hacer logout también
    await _storageService.deleteJwtToken();
    
    try {
      Provider.of<CarteraProvider>(context, listen: false).limpiarCarteras();
      print('AuthProvider: Carteras limpiadas durante el logout.');
    } catch (e) {
      print('AuthProvider: Error al limpiar carteras durante el logout: $e');
    }

    notifyListeners();
    print('AuthProvider: Estado de autenticación limpiado, token eliminado.');
  }

  String? _decodeClaim(String claimName) {
    if (_token == null) {
      print("AuthProvider: _decodeClaim - Token es null, no se puede decodificar claim '$claimName'.");
      return null;
    }
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      final claimValue = decodedToken[claimName];
      print("AuthProvider: _decodeClaim - Claim '$claimName' del token: $claimValue (tipo: ${claimValue.runtimeType})");
      if (claimValue is String) {
        return claimValue;
      } else if (claimValue != null) {
        return claimValue.toString();
      }
      return null;
    } catch (e) {
      print("AuthProvider: Error decodificando token o parseando claim '$claimName': $e");
      return null;
    }
  }

  int? getUserIdFromToken() {
    if (_token == null) {
      print("AuthProvider: getUserIdFromToken - Token es null, no se puede decodificar.");
      return null;
    }
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      
      final subjectClaim = decodedToken['sub'];
      print("AuthProvider: getUserIdFromToken - Claim 'sub' del token: $subjectClaim (tipo: ${subjectClaim.runtimeType})");

      if (subjectClaim is String) {
        return int.tryParse(subjectClaim);
      } else if (subjectClaim is int) {
        return subjectClaim;
      } else if (subjectClaim is num) {
        return subjectClaim.toInt();
      }
      return null;
    } catch (e) {
      print("AuthProvider: Error decodificando token o parseando ID de usuario: $e");
      return null;
    }
  }

  String? get userEmail {
    return _decodeClaim('email');
  }

  String? get userName {
    return _decodeClaim('nombre'); 
  }
}

// lib/core/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../constants/app_constants.dart';

class AuthService {
  
  Map<String, String> _getPublicJsonHeaders() {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  Future<LoginResponseModel> login(LoginRequestModel loginRequest) async {
    final Uri loginUrl = Uri.parse(AppConstants.activeApiBaseUrl + AppConstants.loginEndpoint);
    print('AuthService: [START] Intentando login a $loginUrl con email: ${loginRequest.email}');
    http.Response? response;

    try {
      final headers = _getPublicJsonHeaders();
      final body = jsonEncode(loginRequest.toJson());
      print('AuthService: [TRYING] Login Headers: $headers');
      print('AuthService: [TRYING] Login Body: $body');
      
      response = await http.post(
        loginUrl,
        headers: headers,
        body: body,
      ).timeout(AppConstants.defaultTimeout);

      print('AuthService: [SUCCESS] Login DESPUÉS de http.post - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && 
            responseData['data'] is Map && 
            (responseData['data'] as Map).containsKey('token')) {
            return LoginResponseModel.fromJson(responseData);
        } else if (responseData.containsKey('token')) {
             return LoginResponseModel(
                token: responseData['token'] as String, 
                success: responseData['success'] as bool? ?? true,
                message: responseData['message'] as String? ?? "Login exitoso"
            );
        } else {
            throw FormatException('Respuesta de login inválida.');
        }
      } else {
        String errorMessage = 'Error de autenticación: ${response.statusCode}.';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? (errorData['error'] ?? errorMessage);
        } catch (_) {
          if (response.body.isNotEmpty) errorMessage = response.body;
        }
        print('AuthService: [ERROR LOGIN ${response.statusCode}] $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print('AuthService: [CATCH LOGIN SocketException] $e');
      throw Exception('Error de red: No se pudo conectar.');
    } on TimeoutException catch (e) {
      print('AuthService: [CATCH LOGIN TimeoutException] $e');
      throw Exception('Error de red: La conexión tardó demasiado.');
    } on FormatException catch (e) { 
      print('AuthService: [CATCH LOGIN FormatException] Body: ${response?.body}. Error: $e');
      throw Exception('Error al procesar la respuesta del servidor.');
    } catch (e) {
      print('AuthService: [CATCH LOGIN Genérico] $e');
      throw Exception('Error inesperado en login: ${e.toString()}');
    }
  }

  Future<void> register(RegisterRequestModel registerRequest) async {
    final Uri registerUrl = Uri.parse(AppConstants.activeApiBaseUrl + AppConstants.registerEndpoint);
    print('AuthService: Intentando registro en $registerUrl con email: ${registerRequest.email}');
    http.Response? response;

    try {
      final headers = _getPublicJsonHeaders(); 
      final body = jsonEncode(registerRequest.toJson());
      print('AuthService: [REGISTER TRYING] Headers: $headers');
      print('AuthService: [REGISTER TRYING] Body: $body');

      response = await http.post(
        registerUrl,
        headers: headers,
        body: body,
      ).timeout(AppConstants.defaultTimeout);

      print('AuthService: [REGISTER] DESPUÉS de http.post - Status: ${response.statusCode}');
      print('AuthService: [REGISTER] Respuesta de registro - Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('AuthService: Registro exitoso para ${registerRequest.email}');
        return; 
      } else {
        String errorMessage = 'Error al registrar el usuario: ${response.statusCode}.';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? (errorData['error'] ?? errorMessage);
        } catch (_) {
          if (response.body.isNotEmpty) errorMessage = response.body;
        }
        print('AuthService: [REGISTER ERROR ${response.statusCode}] $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print('AuthService: [REGISTER CATCH SocketException] $e');
      throw Exception('Error de red: No se pudo conectar al servidor.');
    } on TimeoutException catch (e) {
      print('AuthService: [REGISTER CATCH TimeoutException] $e');
      throw Exception('Error de red: La conexión tardó demasiado.');
    } on FormatException catch (e) { 
      print('AuthService: [REGISTER CATCH FormatException] Body: ${response?.body}. Error: $e');
      throw Exception('Error al procesar la respuesta del servidor.');
    } catch (e) {
      print('AuthService: [REGISTER CATCH Genérico] $e');
      throw Exception('Ocurrió un error inesperado durante el registro: ${e.toString()}');
    }
  }
}

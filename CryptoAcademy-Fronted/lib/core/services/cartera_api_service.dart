import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/cartera_model.dart';
import '../models/api_response_model.dart';
import 'secure_storage_service.dart';

class CarteraApiService {
  final SecureStorageService _storageService = SecureStorageService();

  Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await _storageService.getJwtToken();
    if (token == null || token.isEmpty) {
      return {'Content-Type': 'application/json; charset=UTF-8'};
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  /// Obtiene la lista de carteras para el usuario autenticado.
  Future<List<CarteraModel>> getCarterasUsuario() async {
    final Uri url = Uri.parse("${AppConstants.activeApiBaseUrl}${AppConstants.carterasEndpoint}"); 
    
    print('CarteraApiService: Intentando obtener carteras de $url');
    http.Response? response;

    try {
      final headers = await _getAuthHeaders();
      if (!headers.containsKey('Authorization')) {
        throw Exception('Usuario no autenticado. No se pueden obtener las carteras.');
      }
      print('CarteraApiService: Headers para getCarterasUsuario: $headers');

      response = await http.get(
        url,
        headers: headers,
      ).timeout(AppConstants.defaultTimeout);

      print('CarteraApiService: Respuesta getCarterasUsuario - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        final apiResponse = ApiResponse<List<CarteraModel>>.fromJson(
          responseData,
          (dataJson) {
            if (dataJson is List) {
              return dataJson
                  .map((carteraJson) => CarteraModel.fromJson(carteraJson as Map<String, dynamic>))
                  .toList();
            }
            print('CarteraApiService: El campo "data" para getCarterasUsuario no es una lista o es nulo. JSON: $dataJson');
            return [];
          },
        );

        if (apiResponse.success && apiResponse.data != null) {
          print('CarteraApiService: Carteras obtenidas con éxito: ${apiResponse.data!.length} carteras.');
          return apiResponse.data!;
        } else {
          print('CarteraApiService: Fallo al obtener carteras. Mensaje del backend: ${apiResponse.message}');
          throw Exception(apiResponse.message.isNotEmpty ? apiResponse.message : 'Error al obtener carteras del servidor.');
        }
      } else {
        String errorMessage = 'Error del servidor al obtener carteras: ${response.statusCode}.';
        try {
            final Map<String, dynamic> errorBody = jsonDecode(response.body);
            errorMessage = errorBody['message'] ?? (errorBody['error'] ?? errorMessage);
        } catch(_){}
        if (response.body.isNotEmpty && errorMessage.contains(response.statusCode.toString())) {
            errorMessage += ' Cuerpo: ${response.body}';
        }
        print('CarteraApiService: [HTTP ERROR ${response.statusCode}] $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print('CarteraApiService (getCarteras): [CATCH SocketException] $e');
      throw Exception('Error de red: No se pudo conectar. Verifica la IP del servidor ($url) y tu conexión.');
    } on TimeoutException catch (e) {
      print('CarteraApiService (getCarteras): [CATCH TimeoutException] $e');
      throw Exception('Error de red: La conexión tardó demasiado (timeout).');
    } on FormatException catch (e) { 
      print('CarteraApiService (getCarteras): [CATCH FormatException] Respuesta no es JSON. Body: ${response?.body}. Error: $e');
      throw Exception('Error al procesar la respuesta del servidor.');
    } catch (e) {
      print('CarteraApiService (getCarteras): [CATCH Genérico] $e');
      throw Exception('Ocurrió un error inesperado al obtener las carteras: ${e.toString()}');
    }
  }

  Future<CarteraModel> crearCartera(String nombreCartera) async {
    final Uri url = Uri.parse("${AppConstants.activeApiBaseUrl}${AppConstants.carterasEndpoint}");
    print('CarteraApiService: Intentando crear cartera en $url con nombre: $nombreCartera');
    http.Response? response;

    try {
      final headers = await _getAuthHeaders();
      if (!headers.containsKey('Authorization')) {
        throw Exception('Usuario no autenticado. No se puede crear la cartera.');
      }

      response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'nombre': nombreCartera}),
      ).timeout(AppConstants.defaultTimeout);

      print('CarteraApiService (crearCartera): Respuesta - Status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final apiResponse = ApiResponse<CarteraModel>.fromJson(
          responseData,
          (dataJson) => CarteraModel.fromJson(dataJson as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          print('CarteraApiService: Cartera creada con éxito: ${apiResponse.data!.nombre}');
          return apiResponse.data!;
        } else {
          print('CarteraApiService (crearCartera): Fallo. Mensaje del backend: ${apiResponse.message}');
          throw Exception(apiResponse.message.isNotEmpty ? apiResponse.message : 'Error al crear la cartera desde el servidor.');
        }
      } else {
        String errorMessage = 'Error del servidor al crear la cartera: ${response.statusCode}.';
         try {
            final Map<String, dynamic> errorBody = jsonDecode(response.body);
            final apiResponseError = ApiResponse.fromJson(errorBody, (data) => null);
            errorMessage = apiResponseError.message.isNotEmpty ? apiResponseError.message : (errorBody['message'] ?? (errorBody['error'] ?? errorMessage));
        } catch(_){}
        if (response.body.isNotEmpty && errorMessage.contains(response.statusCode.toString())) {
            errorMessage += ' Cuerpo: ${response.body}';
        }
        print('CarteraApiService (crearCartera): [HTTP ERROR ${response.statusCode}] $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print('CarteraApiService (crearCartera): [CATCH SocketException] $e');
      throw Exception('Error de red al crear cartera.');
    } on TimeoutException catch (e) {
      print('CarteraApiService (crearCartera): [CATCH TimeoutException] $e');
      throw Exception('Timeout al crear cartera.');
    } on FormatException catch (e) { 
      print('CarteraApiService (crearCartera): [CATCH FormatException] Body: ${response?.body}. Error: $e');
      throw Exception('Error al procesar respuesta del servidor al crear cartera.');
    } catch (e) {
      print('CarteraApiService (crearCartera): [CATCH Genérico] $e');
      throw Exception('Error inesperado al crear cartera: ${e.toString()}');
    }
  }

  Future<CarteraModel> actualizarNombreCartera(int idCartera, String nuevoNombre) async {
    final Uri url = Uri.parse("${AppConstants.activeApiBaseUrl}${AppConstants.carterasEndpoint}/$idCartera");
    print('CarteraApiService: Intentando actualizar nombre de cartera ID $idCartera a "$nuevoNombre" en $url');
    http.Response? response;

    try {
      final headers = await _getAuthHeaders();
      if (!headers.containsKey('Authorization')) {
        throw Exception('Usuario no autenticado. No se puede actualizar la cartera.');
      }

      response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({'nuevoNombre': nuevoNombre}),
      ).timeout(AppConstants.defaultTimeout);

      print('CarteraApiService (actualizarNombre): Respuesta - Status: ${response.statusCode}');

      if (response.statusCode == 200) { // OK
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final apiResponse = ApiResponse<CarteraModel>.fromJson(
          responseData,
          (dataJson) => CarteraModel.fromJson(dataJson as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          print('CarteraApiService: Nombre de cartera actualizado con éxito: ${apiResponse.data!.nombre}');
          return apiResponse.data!;
        } else {
          print('CarteraApiService (actualizarNombre): Fallo. Mensaje del backend: ${apiResponse.message}');
          throw Exception(apiResponse.message.isNotEmpty ? apiResponse.message : 'Error al actualizar nombre de cartera desde el servidor.');
        }
      } else {
        String errorMessage = 'Error del servidor al actualizar nombre de cartera: ${response.statusCode}.';
        try {
            final Map<String, dynamic> errorBody = jsonDecode(response.body);
            final apiResponseError = ApiResponse.fromJson(errorBody, (data) => null);
            errorMessage = apiResponseError.message.isNotEmpty ? apiResponseError.message : (errorBody['message'] ?? (errorBody['error'] ?? errorMessage));
        } catch(_){}
         if (response.body.isNotEmpty && errorMessage.contains(response.statusCode.toString())) {
            errorMessage += ' Cuerpo: ${response.body}';
        }
        print('CarteraApiService (actualizarNombre): [HTTP ERROR ${response.statusCode}] $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print('CarteraApiService (actualizarNombre): [CATCH SocketException] $e');
      throw Exception('Error de red al actualizar nombre de cartera.');
    } on TimeoutException catch (e) {
      print('CarteraApiService (actualizarNombre): [CATCH TimeoutException] $e');
      throw Exception('Timeout al actualizar nombre de cartera.');
    } on FormatException catch (e) { 
      print('CarteraApiService (actualizarNombre): [CATCH FormatException] Body: ${response?.body}. Error: $e');
      throw Exception('Error al procesar respuesta del servidor al actualizar nombre.');
    } catch (e) {
      print('CarteraApiService (actualizarNombre): [CATCH Genérico] $e');
      throw Exception('Error inesperado al actualizar nombre de cartera: ${e.toString()}');
    }
  }
}

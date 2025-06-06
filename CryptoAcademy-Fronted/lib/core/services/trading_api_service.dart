// lib/core/services/trading_api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cryptoacademy_app/core/models/usuario_details_model.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/orden_request_model.dart';
import '../models/transaccion_api_model.dart';
import '../models/portfolio_models.dart';
import 'secure_storage_service.dart';
import '../models/paginated_response_model.dart';

class TradingApiService {
  final SecureStorageService _storageService = SecureStorageService();

  Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await _storageService.getJwtToken();
    if (token == null || token.isEmpty) {
      print(
          'TradingApiService: Token no encontrado. Realizando petición sin token (si el endpoint es público).');
      return {'Content-Type': 'application/json; charset=UTF-8'};
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<TransaccionApiModel> comprarCripto(OrdenRequestModel orden) async {
    final Uri comprarUrl = Uri.parse(
        AppConstants.activeApiBaseUrl + AppConstants.comprarEndpoint);
    print(
        'TradingApiService: Intentando comprar en $comprarUrl con orden: ${jsonEncode(
            orden.toJson())}');
    http.Response? response;

    try {
      final headers = await _getAuthHeaders();
      if (!headers.containsKey('Authorization')) {
        throw Exception('Usuario no autenticado para realizar la compra.');
      }
      response = await http.post(
        comprarUrl,
        headers: headers,
        body: jsonEncode(orden.toJson()),
      ).timeout(AppConstants.defaultTimeout);

      print('TradingApiService (Comprar): Respuesta - Status: ${response
          .statusCode}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return TransaccionApiModel.fromJson(responseData);
      } else {
        String errorMessage = 'Error al procesar la compra: ${response
            .statusCode}.';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ?? (errorData['error'] ?? errorMessage);
        } catch (_) {
          if (response.body.isNotEmpty) errorMessage = response.body;
        }
        print('TradingApiService (Comprar): [ERROR ${response
            .statusCode}] $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print('TradingApiService (Comprar): [CATCH SocketException] $e');
      throw Exception('Error de red: No se pudo conectar al servidor.');
    } on TimeoutException catch (e) {
      print('TradingApiService (Comprar): [CATCH TimeoutException] $e');
      throw Exception('Error de red: La conexión tardó demasiado.');
    } on FormatException catch (e) {
      print(
          'TradingApiService (Comprar): [CATCH FormatException] Respuesta no es JSON. Body: ${response
              ?.body}. Error: $e');
      throw Exception('Error al procesar la respuesta del servidor.');
    } catch (e) {
      print('TradingApiService (Comprar): [CATCH Genérico] $e');
      throw Exception('Ocurrió un error inesperado: ${e.toString()}');
    }
  }

  Future<TransaccionApiModel> venderCripto(OrdenRequestModel orden) async {
    final Uri venderUrl = Uri.parse(
        AppConstants.activeApiBaseUrl + AppConstants.venderEndpoint);
    print(
        'TradingApiService: Intentando vender en $venderUrl con orden: ${jsonEncode(
            orden.toJson())}');
    http.Response? response;

    try {
      final headers = await _getAuthHeaders();
      if (!headers.containsKey('Authorization')) {
        throw Exception('Usuario no autenticado para realizar la venta.');
      }
      response = await http.post(
        venderUrl,
        headers: headers,
        body: jsonEncode(orden.toJson()),
      ).timeout(AppConstants.defaultTimeout);

      print('TradingApiService (Vender): Respuesta - Status: ${response
          .statusCode}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return TransaccionApiModel.fromJson(responseData);
      } else {
        String errorMessage = 'Error al procesar la venta: ${response
            .statusCode}.';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ?? (errorData['error'] ?? errorMessage);
        } catch (_) {
          if (response.body.isNotEmpty) errorMessage = response.body;
        }
        print('TradingApiService (Vender): [ERROR ${response
            .statusCode}] $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print('TradingApiService (Vender): [CATCH SocketException] $e');
      throw Exception('Error de red: No se pudo conectar al servidor.');
    } on TimeoutException catch (e) {
      print('TradingApiService (Vender): [CATCH TimeoutException] $e');
      throw Exception('Error de red: La conexión tardó demasiado.');
    } on FormatException catch (e) {
      print(
          'TradingApiService (Vender): [CATCH FormatException] Respuesta no es JSON. Body: ${response
              ?.body}. Error: $e');
      throw Exception('Error al procesar la respuesta del servidor.');
    } catch (e) {
      print('TradingApiService (Vender): [CATCH Genérico] $e');
      throw Exception('Ocurrió un error inesperado: ${e.toString()}');
    }
  }

  Future<PortfolioResponseModel> obtenerPortfolioPorCartera(
      int idCartera) async {
    final Uri portfolioUrl = Uri.parse(
        '${AppConstants.activeApiBaseUrl}${AppConstants
            .portfolioEndpointBase}/$idCartera');
    print(
        'TradingApiService: Intentando obtener portfolio para cartera ID $idCartera desde $portfolioUrl');
    http.Response? response;

    try {
      final headers = await _getAuthHeaders();
      if (!headers.containsKey('Authorization')) {
        throw Exception('Usuario no autenticado para obtener el portfolio.');
      }
      print(
          'TradingApiService: Headers para obtenerPortfolioPorCartera: $headers');

      response = await http.get(
        portfolioUrl,
        headers: headers,
      ).timeout(AppConstants.defaultTimeout);

      print('TradingApiService (Portfolio): Respuesta - Status: ${response
          .statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return PortfolioResponseModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión de nuevo.');
      } else if (response.statusCode == 404) {
        throw Exception('Portfolio para cartera ID $idCartera no encontrado.');
      } else {
        String errorMessage = 'Error del servidor al obtener el portfolio: ${response
            .statusCode}.';
        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          errorMessage =
              errorBody['message'] ?? (errorBody['error'] ?? errorMessage);
        } catch (_) {}
        if (response.body.isNotEmpty &&
            errorMessage.contains(response.statusCode.toString())) {
          errorMessage += ' Cuerpo: ${response.body}';
        }
        print('TradingApiService (Portfolio): [ERROR ${response
            .statusCode}] $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print('TradingApiService (Portfolio): [CATCH SocketException] $e');
      throw Exception('Error de red: No se pudo conectar al servidor.');
    } on TimeoutException catch (e) {
      print('TradingApiService (Portfolio): [CATCH TimeoutException] $e');
      throw Exception('Error de red: La conexión tardó demasiado.');
    } on FormatException catch (e) {
      print(
          'TradingApiService (Portfolio): [CATCH FormatException] Respuesta no es JSON. Body: ${response
              ?.body}. Error: $e');
      throw Exception('Error al procesar la respuesta del servidor.');
    } catch (e) {
      print('TradingApiService (Portfolio): [CATCH Genérico] $e');
      throw Exception('Ocurrió un error inesperado al obtener el portfolio: ${e
          .toString()}');
    }
  }

  Future<PaginatedResponseModel<
      TransaccionApiModel>> obtenerHistorialTransaccionesUsuario({
    int page = 0,
    int size = AppConstants.defaultPageSize,
    String? sort,
    String? tipo,
  }) async {
    Map<String, String> queryParams = {
      'page': page.toString(),
      'size': size.toString(),
    };
    if (sort != null && sort.isNotEmpty) {
      queryParams['sort'] = sort;
    }
    if (tipo != null && tipo.isNotEmpty) {
      queryParams['tipo'] = tipo;
    }

    final Uri historialUrl = Uri.parse(AppConstants.activeApiBaseUrl +
        AppConstants.historialTransaccionesEndpoint)
        .replace(queryParameters: queryParams);
    print(
        'TradingApiService: Intentando obtener historial de transacciones de $historialUrl');
    http.Response? response;

    try {
      final headers = await _getAuthHeaders();
      print(
          'TradingApiService: Headers para obtenerHistorialTransaccionesUsuario: $headers');
      response = await http.get(historialUrl, headers: headers).timeout(
          AppConstants.defaultTimeout);

      print('TradingApiService (Historial): Respuesta - Status: ${response
          .statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return PaginatedResponseModel<TransaccionApiModel>.fromJson(
          responseData,
              (itemJson) => TransaccionApiModel.fromJson(itemJson),
        );
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión de nuevo.');
      } else {
        String errorMessage = 'Error del servidor al obtener el historial de transacciones: ${response
            .statusCode}.';
        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          errorMessage =
              errorBody['message'] ?? (errorBody['error'] ?? errorMessage);
        } catch (_) {}
        if (response.body.isNotEmpty &&
            errorMessage.contains(response.statusCode.toString())) {
          errorMessage += ' Cuerpo: ${response.body}';
        }
        print('TradingApiService (Historial): [ERROR ${response
            .statusCode}] $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print('TradingApiService (Historial): [CATCH SocketException] $e');
      throw Exception('Error de red: No se pudo conectar al servidor.');
    } on TimeoutException catch (e) {
      print('TradingApiService (Historial): [CATCH TimeoutException] $e');
      throw Exception('Error de red: La conexión tardó demasiado.');
    } on FormatException catch (e) {
      print(
          'TradingApiService (Historial): [CATCH FormatException] Respuesta no es JSON. Body: ${response
              ?.body}. Error: $e');
      throw Exception('Error al procesar la respuesta del servidor.');
    } catch (e) {
      print('TradingApiService (Historial): [CATCH Genérico] $e');
      throw Exception(
          'Ocurrió un error inesperado al obtener el historial de transacciones: ${e
              .toString()}');
    }
  }

  Future<double?> getMiSaldoFiatTotal() async {
    final Uri saldoUrl = Uri.parse(
        '${AppConstants.activeApiBaseUrl}/usuarios/me/saldo-fiat-total');

    print(
        'TradingApiService: Intentando obtener saldo fiat total del usuario desde $saldoUrl');
    http.Response? response;

    try {
      final headers = await _getAuthHeaders();
      if (!headers.containsKey('Authorization')) {
        // Este endpoint requiere autenticación
        throw Exception(
            'Usuario no autenticado para obtener el saldo fiat total.');
      }
      print('TradingApiService: Headers para getMiSaldoFiatTotal: $headers');

      response = await http.get(
        saldoUrl,
        headers: headers,
      ).timeout(AppConstants.defaultTimeout);

      print(
          'TradingApiService (Saldo Fiat Total): Respuesta - Status: ${response
              .statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('success') &&
            responseData['success'] == true &&
            responseData.containsKey('data') && responseData['data'] != null) {
          return (responseData['data'] as num).toDouble();
        } else {
          String message = responseData.containsKey('message')
              ? responseData['message']
              : 'Respuesta inesperada del servidor.';
          print(
              'TradingApiService (Saldo Fiat Total): Error en la estructura de la respuesta - $message');
          throw Exception('Error al obtener saldo fiat total: $message');
        }
      } else if (response.statusCode == 401) {
        throw Exception(
            'No autorizado para obtener el saldo fiat total. Por favor, inicia sesión de nuevo.');
      } else {
        String errorMessage = 'Error del servidor al obtener el saldo fiat total: ${response
            .statusCode}.';
        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          errorMessage =
              errorBody['message'] ?? (errorBody['error'] ?? errorMessage);
        } catch (_) {}
        if (response.body.isNotEmpty &&
            errorMessage.contains(response.statusCode.toString())) {
          errorMessage += ' Cuerpo: ${response.body}';
        }
        print('TradingApiService (Saldo Fiat Total): [ERROR ${response
            .statusCode}] $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print('TradingApiService (Saldo Fiat Total): [CATCH SocketException] $e');
      throw Exception('Error de red: No se pudo conectar al servidor.');
    } on TimeoutException catch (e) {
      print(
          'TradingApiService (Saldo Fiat Total): [CATCH TimeoutException] $e');
      throw Exception('Error de red: La conexión tardó demasiado.');
    } on FormatException catch (e) {
      print(
          'TradingApiService (Saldo Fiat Total): [CATCH FormatException] Respuesta no es JSON. Body: ${response
              ?.body}. Error: $e');
      throw Exception('Error al procesar la respuesta del servidor.');
    } catch (e) {
      print('TradingApiService (Saldo Fiat Total): [CATCH Genérico] $e');
      throw Exception(
          'Ocurrió un error inesperado al obtener el saldo fiat total: ${e
              .toString()}');
    }
  }

  Future<UsuarioDetailsModel?> getMiPerfilDetails() async {
    final Uri perfilUrl = Uri.parse(
        '${AppConstants.activeApiBaseUrl}/usuarios/me/details');
    print(
        'TradingApiService: Intentando obtener detalles del perfil desde $perfilUrl');
    http.Response? response;

    try {
      final headers = await _getAuthHeaders();
      if (!headers.containsKey('Authorization')) {
        throw Exception(
            'Usuario no autenticado para obtener los detalles del perfil.');
      }
      print('TradingApiService: Headers para getMiPerfilDetails: $headers');

      response = await http.get(
        perfilUrl,
        headers: headers,
      ).timeout(AppConstants.defaultTimeout);

      print('TradingApiService (Perfil Details): Respuesta - Status: ${response
          .statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('success') &&
            responseData['success'] == true &&
            responseData.containsKey('data') && responseData['data'] != null) {
          return UsuarioDetailsModel.fromJson(
              responseData['data'] as Map<String, dynamic>);
        } else {
          String message = responseData.containsKey('message')
              ? responseData['message']
              : 'Respuesta inesperada del servidor.';
          print(
              'TradingApiService (Perfil Details): Error en la estructura de la respuesta - $message');
          throw Exception('Error al obtener detalles del perfil: $message');
        }
      } else if (response.statusCode == 401) {
        throw Exception(
            'No autorizado para obtener los detalles del perfil. Por favor, inicia sesión de nuevo.');
      } else {
        String errorMessage = 'Error del servidor al obtener los detalles del perfil: ${response
            .statusCode}.';
        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          errorMessage =
              errorBody['message'] ?? (errorBody['error'] ?? errorMessage);
        } catch (_) {}
        if (response.body.isNotEmpty &&
            errorMessage.contains(response.statusCode.toString())) {
          errorMessage += ' Cuerpo: ${response.body}';
        }
        print('TradingApiService (Perfil Details): [ERROR ${response
            .statusCode}] $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print('TradingApiService (Perfil Details): [CATCH SocketException] $e');
      throw Exception('Error de red: No se pudo conectar al servidor.');
    } on TimeoutException catch (e) {
      print('TradingApiService (Perfil Details): [CATCH TimeoutException] $e');
      throw Exception('Error de red: La conexión tardó demasiado.');
    } on FormatException catch (e) {
      print(
          'TradingApiService (Perfil Details): [CATCH FormatException] Respuesta no es JSON. Body: ${response
              ?.body}. Error: $e');
      throw Exception('Error al procesar la respuesta del servidor.');
    } catch (e) {
      print('TradingApiService (Perfil Details): [CATCH Genérico] $e');
      throw Exception(
          'Ocurrió un error inesperado al obtener los detalles del perfil: ${e
              .toString()}');
    }
  }
  Future<double?> getMiValorCriptoTotal() async {
    final Uri valorCriptoUrl = Uri.parse('${AppConstants.activeApiBaseUrl}/usuarios/me/valorcriptototal');
    print('TradingApiService: Intentando obtener valor cripto total del usuario desde $valorCriptoUrl');
    http.Response? response;

    try {
      final headers = await _getAuthHeaders();
      if (!headers.containsKey('Authorization')) {
        throw Exception('Usuario no autenticado para obtener el valor cripto total.');
      }
      print('TradingApiService: Headers para getMiValorCriptoTotal: $headers');

      response = await http.get(
        valorCriptoUrl,
        headers: headers,
      ).timeout(AppConstants.defaultTimeout);

      print('TradingApiService (Valor Cripto Total): Respuesta - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('success') && responseData['success'] == true && responseData.containsKey('data') && responseData['data'] != null) {
          return (responseData['data'] as num).toDouble();
        } else {
          String message = responseData.containsKey('message') ? responseData['message'] : 'Respuesta inesperada del servidor.';
          print('TradingApiService (Valor Cripto Total): Error en la estructura de la respuesta - $message');
          throw Exception('Error al obtener valor cripto total: $message');
        }
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado para obtener el valor cripto total. Por favor, inicia sesión de nuevo.');
      } else {
        String errorMessage = 'Error del servidor al obtener el valor cripto total: ${response.statusCode}.';
        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? (errorBody['error'] ?? errorMessage);
        } catch(_){}
        if (response.body.isNotEmpty && errorMessage.contains(response.statusCode.toString())) {
          errorMessage += ' Cuerpo: ${response.body}';
        }
        print('TradingApiService (Valor Cripto Total): [ERROR ${response.statusCode}] $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print('TradingApiService (Valor Cripto Total): [CATCH SocketException] $e');
      throw Exception('Error de red: No se pudo conectar al servidor.');
    } on TimeoutException catch (e) {
      print('TradingApiService (Valor Cripto Total): [CATCH TimeoutException] $e');
      throw Exception('Error de red: La conexión tardó demasiado.');
    } on FormatException catch (e) {
      print('TradingApiService (Valor Cripto Total): [CATCH FormatException] Respuesta no es JSON. Body: ${response?.body}. Error: $e');
      throw Exception('Error al procesar la respuesta del servidor.');
    } catch (e) {
      print('TradingApiService (Valor Cripto Total): [CATCH Genérico] $e');
      throw Exception('Ocurrió un error inesperado al obtener el valor cripto total: ${e.toString()}');
    }
  }
  Future<UsuarioDetailsModel?> actualizarMiNombre(String nuevoNombre) async {
    final Uri actualizarNombreUrl = Uri.parse('${AppConstants.activeApiBaseUrl}/usuarios/me/nombre');
    print('TradingApiService: Intentando actualizar nombre a "$nuevoNombre" en $actualizarNombreUrl');
    http.Response? response;

    try {
      final headers = await _getAuthHeaders();
      if (!headers.containsKey('Authorization')) {
        throw Exception('Usuario no autenticado para actualizar el nombre.');
      }

      final body = jsonEncode({'nuevoNombre': nuevoNombre});
      print('TradingApiService (Actualizar Nombre): Body a enviar: $body');

      response = await http.put(
        actualizarNombreUrl,
        headers: headers,
        body: body,
      ).timeout(AppConstants.defaultTimeout);

      print('TradingApiService (Actualizar Nombre): Respuesta - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('success') && responseData['success'] == true && responseData.containsKey('data') && responseData['data'] != null) {
          return UsuarioDetailsModel.fromJson(responseData['data'] as Map<String, dynamic>);
        } else {
          String message = responseData.containsKey('message') ? responseData['message'] : 'Respuesta inesperada del servidor al actualizar nombre.';
          print('TradingApiService (Actualizar Nombre): Error en la estructura de la respuesta - $message');
          throw Exception('Error al actualizar nombre: $message');
        }
      } else if (response.statusCode == 400) {
        String errorMessage = 'Error de validación al actualizar el nombre.';
        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? (errorBody['error'] ?? (errorBody['errors']?.toString() ?? errorMessage));
        } catch(_){}
        print('TradingApiService (Actualizar Nombre): [ERROR 400] $errorMessage');
        throw Exception(errorMessage);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado para actualizar el nombre. Por favor, inicia sesión de nuevo.');
      } else {
        String errorMessage = 'Error del servidor al actualizar el nombre: ${response.statusCode}.';
        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? (errorBody['error'] ?? errorMessage);
        } catch(_){}
        if (response.body.isNotEmpty && errorMessage.contains(response.statusCode.toString())) {
          errorMessage += ' Cuerpo: ${response.body}';
        }
        print('TradingApiService (Actualizar Nombre): [ERROR ${response.statusCode}] $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print('TradingApiService (Actualizar Nombre): [CATCH SocketException] $e');
      throw Exception('Error de red: No se pudo conectar al servidor.');
    } on TimeoutException catch (e) {
      print('TradingApiService (Actualizar Nombre): [CATCH TimeoutException] $e');
      throw Exception('Error de red: La conexión tardó demasiado.');
    } on FormatException catch (e) {
      print('TradingApiService (Actualizar Nombre): [CATCH FormatException] Respuesta no es JSON. Body: ${response?.body}. Error: $e');
      throw Exception('Error al procesar la respuesta del servidor.');
    } catch (e) {
      print('TradingApiService (Actualizar Nombre): [CATCH Genérico] $e');
      throw Exception('Ocurrió un error inesperado al actualizar el nombre: ${e.toString()}');
    }
  }
}
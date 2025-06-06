import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cryptoacademy_app/core/models/market_chart_model.dart';
import 'package:http/http.dart' as http;
import 'package:cryptoacademy_app/core/models/cripto_api_model.dart';
import 'package:cryptoacademy_app/core/services/secure_storage_service.dart';
import '../constants/app_constants.dart';
import '../models/api_response_model.dart';
import '../models/ranking_item_model.dart';

class CryptoApiService {
  final SecureStorageService _storageService = SecureStorageService();

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storageService.getJwtToken();
    if (token != null && token.isNotEmpty) {
      return {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      };
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  // Obtiene una lista paginada de criptomonedas.
  Future<PaginatedCriptoResponse> getCriptomonedasPaginado({
    int page = 0,
    int size = AppConstants.defaultPageSize,
    String? sort,
  }) async {
    Map<String, String> queryParams = {
      'page': page.toString(),
      'size': size.toString(),
    };
    if (sort != null && sort.isNotEmpty) {
      queryParams['sort'] = sort;
    }

    final Uri criptoUrl = Uri.parse(AppConstants.activeApiBaseUrl + AppConstants.criptomonedasEndpointBase)
        .replace(queryParameters: queryParams);
    
    print('CryptoApiService: Intentando obtener criptomonedas de $criptoUrl');
    http.Response? response;

    try {
      final headers = await _getHeaders(); 
      print('CryptoApiService: Headers para getCriptomonedas: $headers');
      response = await http.get(criptoUrl, headers: headers).timeout(AppConstants.defaultTimeout);

      print('CryptoApiService: Respuesta de getCriptomonedas - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body); 
        return PaginatedCriptoResponse.fromJson(responseData); 
      } else if (response.statusCode == 401) { 
        throw Exception('No autorizado. Por favor, inicia sesión de nuevo.');
      } else { 
        print('CryptoApiService: Error en getCriptomonedasPaginado - Body: ${response.body}');
        throw Exception('Error del servidor al obtener criptomonedas: ${response.statusCode}.');
      }
    } on SocketException catch (e) { 
      print('CryptoApiService: SocketException en getCriptomonedas: $e');
      throw Exception('Error de red: No se pudo conectar al servidor.');
    } on TimeoutException catch (e) { 
      print('CryptoApiService: TimeoutException en getCriptomonedas: $e');
      throw Exception('Error de red: La conexión tardó demasiado.');
    } on FormatException catch (e) { 
      print('CryptoApiService: FormatException en getCriptomonedas. Body: ${response?.body}. Error: $e');
      throw Exception('Error al procesar la respuesta del servidor.');
    } catch (e) { 
      print('CryptoApiService: Excepción genérica en getCriptomonedas: $e');
      throw Exception('Ocurrió un error inesperado al obtener las criptomonedas.');
    }
  }

  // Obtiene los detalles de una criptomoneda específica por su ID.
  Future<CriptoApiModel> getCriptomonedaById(String id) async {
    if (id.isEmpty) { 
      throw ArgumentError('El ID de la criptomoneda no puede estar vacío.');
    }
    final Uri detailUrl = Uri.parse('${AppConstants.activeApiBaseUrl}${AppConstants.criptomonedasEndpointBase}/$id');
    print('CryptoApiService: Intentando obtener detalles para la criptomoneda ID: $id desde $detailUrl');

    http.Response? response;

    try {
      final headers = await _getHeaders();
      print('CryptoApiService: Headers para getCriptomonedaById: $headers');
      response = await http.get(detailUrl, headers: headers).timeout(AppConstants.defaultTimeout);

      print('CryptoApiService: Respuesta de getCriptomonedaById - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return CriptoApiModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión de nuevo.');
      } else if (response.statusCode == 404) {
        throw Exception('Criptomoneda con ID $id no encontrada.');
      } else {
        print('CryptoApiService: Error en getCriptomonedaById - Body: ${response.body}');
        throw Exception('Error del servidor al obtener detalles de la criptomoneda: ${response.statusCode}.');
      }
    } on SocketException catch (e) {
      print('CryptoApiService: SocketException en getCriptomonedaById para ID $id: $e');
      throw Exception('Error de red: No se pudo conectar al servidor.');
    } on TimeoutException catch (e) {
      print('CryptoApiService: TimeoutException en getCriptomonedaById para ID $id: $e');
      throw Exception('Error de red: La conexión tardó demasiado.');
    } on FormatException catch (e) {
      print('CryptoApiService: FormatException en getCriptomonedaById para ID $id. Body: ${response?.body}. Error: $e');
      throw Exception('Error al procesar la respuesta del servidor.');
    } catch (e) {
      print('CryptoApiService: Excepción genérica en getCriptomonedaById para ID $id: $e');
      throw Exception('Ocurrió un error inesperado al obtener los detalles de la criptomoneda.');
    }
  }

  /// Busca criptomonedas en el backend según un término de búsqueda.
  Future<PaginatedCriptoResponse> buscarCriptomonedas(
    String termino, {
    int page = 0,
    int size = AppConstants.defaultPageSize,
  }) async {
    if (termino.isEmpty) {
      print('CryptoApiService: Término de búsqueda vacío, devolviendo respuesta paginada vacía.');
      return PaginatedCriptoResponse(
          content: [],
          totalPages: 0,
          totalElements: 0,
          number: 0,
          size: size,
          first: true,
          last: true,
          empty: true);
    }
    Map<String, String> queryParams = {
      'termino': termino,
      'page': page.toString(),
      'size': size.toString(),
    };

    final Uri searchUrl = Uri.parse(AppConstants.activeApiBaseUrl + AppConstants.buscarCriptomonedasEndpoint)
        .replace(queryParameters: queryParams);
    print('CryptoApiService: Intentando buscar criptomonedas con término "$termino" en $searchUrl');

    http.Response? response;

    try {
      final headers = await _getHeaders();
      print('CryptoApiService: Headers para buscarCriptomonedas: $headers');
      response = await http.get(searchUrl, headers: headers).timeout(AppConstants.defaultTimeout);

      print('CryptoApiService: Respuesta de buscarCriptomonedas - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return PaginatedCriptoResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión de nuevo.');
      } else {
        print('CryptoApiService: Error en buscarCriptomonedas - Body: ${response.body}');
        throw Exception('Error del servidor al buscar criptomonedas: ${response.statusCode}.');
      }
    } on SocketException catch (e) {
      print('CryptoApiService: SocketException en buscarCriptomonedas: $e');
      throw Exception('Error de red: No se pudo conectar al servidor.');
    } on TimeoutException catch (e) {
      print('CryptoApiService: TimeoutException en buscarCriptomonedas: $e');
      throw Exception('Error de red: La conexión tardó demasiado.');
    } on FormatException catch (e) {
      print('CryptoApiService: FormatException en buscarCriptomonedas. Body: ${response?.body}. Error: $e');
      throw Exception('Error al procesar la respuesta del servidor.');
    } catch (e) {
      print('CryptoApiService: Excepción genérica en buscarCriptomonedas: $e');
      throw Exception('Ocurrió un error inesperado al buscar las criptomonedas.');
    }
  }

  // Obtiene los datos del gráfico para una criptomoneda específica.
  Future<MarketChartData> getMarketChartData(
    String cryptoId, {
    String dias = "7", 
    String vsCurrency = "eur", // Por defecto EUR
  }) async {
    if (cryptoId.isEmpty) {
      throw ArgumentError('El ID de la criptomoneda no puede estar vacío.');
    }
    Map<String, String> queryParams = {
      'dias': dias,
      'vsCurrency': vsCurrency,
    };
    
    final Uri chartUrl = Uri.parse('${AppConstants.activeApiBaseUrl}${AppConstants.criptomonedasEndpointBase}/$cryptoId/grafico')
        .replace(queryParameters: queryParams);
    
    print('CryptoApiService: Intentando obtener datos de gráfico para ID: $cryptoId desde $chartUrl');
    http.Response? response;

    try {
      final headers = await _getHeaders(); 
      print('CryptoApiService: Headers para getMarketChartData: $headers');
      response = await http.get(chartUrl, headers: headers).timeout(AppConstants.defaultTimeout);

      print('CryptoApiService: Respuesta de getMarketChartData - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return MarketChartData.fromJson(responseData);
      } else if (response.statusCode == 204) { // No Content
        print('CryptoApiService: No hay datos de gráfico para $cryptoId (204 No Content).');
        return MarketChartData(prices: []); // Devolver objeto vacío si no hay contenido
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión de nuevo.');
      } else if (response.statusCode == 404) {
        throw Exception('Datos de gráfico para la criptomoneda con ID $cryptoId no encontrados.');
      } else {
        print('CryptoApiService: Error en getMarketChartData - Body: ${response.body}');
        throw Exception('Error del servidor al obtener datos de gráfico: ${response.statusCode}.');
      }
    } on SocketException catch (e) {
      print('CryptoApiService: SocketException en getMarketChartData para ID $cryptoId: $e');
      throw Exception('Error de red: No se pudo conectar al servidor.');
    } on TimeoutException catch (e) {
      print('CryptoApiService: TimeoutException en getMarketChartData para ID $cryptoId: $e');
      throw Exception('Error de red: La conexión tardó demasiado.');
    } on FormatException catch (e) {
      print('CryptoApiService: FormatException en getMarketChartData para ID $cryptoId. Body: ${response?.body}. Error: $e');
      throw Exception('Error al procesar la respuesta del servidor.');
    } catch (e) {
      print('CryptoApiService: Excepción genérica en getMarketChartData para ID $cryptoId: $e');
      throw Exception('Ocurrió un error inesperado al obtener los datos del gráfico.');
    }
  }

  Future<List<RankingItemModel>> getRanking({int limite = 50}) async {
    final Map<String, String> queryParams = {
      'limite': limite.toString(),
    };
    final Uri rankingUrl = Uri.parse(AppConstants.activeApiBaseUrl + AppConstants.rankingEndpoint)
        .replace(queryParameters: queryParams);
    
    print('CryptoApiService: Intentando obtener ranking de $rankingUrl');
    http.Response? response;

    try {
      final headers = await _getHeaders();
      print('CryptoApiService: Headers para getRanking: $headers');
      response = await http.get(rankingUrl, headers: headers).timeout(AppConstants.defaultTimeout);

      print('CryptoApiService: Respuesta de getRanking - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final apiResponse = ApiResponse<List<RankingItemModel>>.fromJson(
          responseData,
          (dataJson) {
            if (dataJson is List) {
              return dataJson
                  .map((itemJson) => RankingItemModel.fromJson(itemJson as Map<String, dynamic>))
                  .toList();
            }
            print('CryptoApiService: El campo "data" para getRanking no es una lista o es nulo. JSON: $dataJson');
            return [];
          },
        );

        if (apiResponse.success && apiResponse.data != null) {
          print('CryptoApiService: Ranking obtenido con éxito: ${apiResponse.data!.length} items.');
          return apiResponse.data!;
        } else {
          print('CryptoApiService: Fallo al obtener ranking. Mensaje del backend: ${apiResponse.message}');
          throw Exception(apiResponse.message.isNotEmpty ? apiResponse.message : 'Error al obtener el ranking del servidor.');
        }
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado para ver el ranking. Por favor, inicia sesión.');
      } else {
        print('CryptoApiService: Error en getRanking - Body: ${response.body}');
        throw Exception('Error del servidor al obtener el ranking: ${response.statusCode}.');
      }
    } on SocketException catch (e) {
      print('CryptoApiService (Ranking): [CATCH SocketException] $e');
      throw Exception('Error de red al obtener el ranking.');
    } on TimeoutException catch (e) {
      print('CryptoApiService (Ranking): [CATCH TimeoutException] $e');
      throw Exception('Timeout al obtener el ranking.');
    } on FormatException catch (e) {
      print('CryptoApiService (Ranking): [CATCH FormatException] Body: ${response?.body}. Error: $e');
      throw Exception('Error al procesar respuesta del servidor para el ranking.');
    } catch (e) {
      print('CryptoApiService (Ranking): [CATCH Genérico] $e');
      throw Exception('Error inesperado al obtener el ranking: ${e.toString()}');
    }
  }
}
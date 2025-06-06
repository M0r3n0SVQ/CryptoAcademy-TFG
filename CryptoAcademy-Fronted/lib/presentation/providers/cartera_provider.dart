import 'package:flutter/material.dart';
import '../../core/models/cartera_model.dart';
import '../../core/services/cartera_api_service.dart';

class CarteraProvider with ChangeNotifier {
  final CarteraApiService _carteraApiService = CarteraApiService();

  List<CarteraModel> _carteras = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoadedSuccessfully = false; // Para saber si la carga inicial fue exitosa

  // Estados específicos para operaciones de creación/actualización
  bool _isCreatingCartera = false;
  bool _isUpdatingCartera = false;
  String? _operationErrorMessage;


  List<CarteraModel> get carteras => _carteras;
  bool get isLoading => _isLoading; // Para la carga inicial de la lista
  String? get errorMessage => _errorMessage; // Para errores de la carga inicial
  bool get tieneCarteras => _carteras.isNotEmpty;
  bool get hasLoadedSuccessfully => _hasLoadedSuccessfully;

  bool get isCreatingCartera => _isCreatingCartera;
  bool get isUpdatingCartera => _isUpdatingCartera;
  String? get operationErrorMessage => _operationErrorMessage;


  Future<void> fetchCarterasUsuario({bool forceRefresh = false}) async {
    if (_isLoading || (_hasLoadedSuccessfully && !forceRefresh && _carteras.isNotEmpty)) {
      print('CarteraProvider: fetchCarterasUsuario omitido (ya cargado o en progreso y no forzado).');
      if (!_isLoading && _errorMessage == null) {
      }
      return;
    }
    
    print('CarteraProvider: Iniciando fetchCarterasUsuario (forceRefresh: $forceRefresh)...');
    _isLoading = true;
    _errorMessage = null;
    _operationErrorMessage = null;
    notifyListeners();

    try {
      _carteras = await _carteraApiService.getCarterasUsuario();
      _hasLoadedSuccessfully = true;
      print('CarteraProvider: Carteras cargadas: ${_carteras.length}');
    } catch (e) {
      print('CarteraProvider: Error en fetchCarterasUsuario: $e');
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      _carteras = [];
      _hasLoadedSuccessfully = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> crearNuevaCartera(String nombreCartera) async {
    print('CarteraProvider: Intentando crear nueva cartera con nombre: $nombreCartera');
    _isCreatingCartera = true;
    _operationErrorMessage = null;
    notifyListeners();

    try {
      final nuevaCartera = await _carteraApiService.crearCartera(nombreCartera);
      _carteras.add(nuevaCartera);
      _isCreatingCartera = false;
      print('CarteraProvider: Cartera "${nuevaCartera.nombre}" creada con ID ${nuevaCartera.idCartera}.');
      notifyListeners();
      return true;
    } catch (e) {
      print('CarteraProvider: Error al crear nueva cartera: $e');
      _operationErrorMessage = e.toString().replaceFirst("Exception: ", "");
      _isCreatingCartera = false;
      notifyListeners();
      return false;
  }
  }
  Future<bool> actualizarNombreDeCartera(int idCartera, String nuevoNombre) async {
    print('CarteraProvider: Intentando actualizar nombre de cartera ID $idCartera a "$nuevoNombre"');
    _isUpdatingCartera = true;
    _operationErrorMessage = null;
    notifyListeners();

    try {
      final carteraActualizada = await _carteraApiService.actualizarNombreCartera(idCartera, nuevoNombre);
      
      final index = _carteras.indexWhere((c) => c.idCartera == idCartera);
      if (index != -1) {
        _carteras[index] = carteraActualizada;
        print('CarteraProvider: Cartera ID $idCartera actualizada en la lista local a nombre "${carteraActualizada.nombre}".');
      } else {
        _carteras.add(carteraActualizada); 
        print('CarteraProvider: Cartera ID $idCartera no encontrada en lista local, añadiendo la actualizada.');
      }
      
      _isUpdatingCartera = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('CarteraProvider: Error al actualizar nombre de cartera: $e');
      _operationErrorMessage = e.toString().replaceFirst("Exception: ", "");
      _isUpdatingCartera = false;
      notifyListeners();
      return false;
    }
  }

  void limpiarCarteras() {
    _carteras = [];
    _isLoading = false;
    _errorMessage = null;
    _hasLoadedSuccessfully = false;
    _isCreatingCartera = false;
    _isUpdatingCartera = false;
    _operationErrorMessage = null;
    print('CarteraProvider: Carteras y estados limpiados.');
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/paginated_response_model.dart';
import '../../../core/models/transaccion_api_model.dart';
import '../../../core/services/trading_api_service.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class HistorialTransaccionesScreen extends StatefulWidget {
  const HistorialTransaccionesScreen({super.key});

  @override
  State<HistorialTransaccionesScreen> createState() => _HistorialTransaccionesScreenState();
}

class _HistorialTransaccionesScreenState extends State<HistorialTransaccionesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TradingApiService _tradingApiService = TradingApiService();

  // Listas y estados de carga para cada pestaña
  final List<TransaccionApiModel> _todasTransacciones = [];
  final List<TransaccionApiModel> _comprasTransacciones = [];
  final List<TransaccionApiModel> _ventasTransacciones = [];

  int _currentPageTodas = 0;
  int _currentPageCompras = 0;
  int _currentPageVentas = 0;

  bool _isLoadingMoreTodas = false;
  bool _isLoadingMoreCompras = false;
  bool _isLoadingMoreVentas = false;

  bool _hasMorePagesTodas = true;
  bool _hasMorePagesCompras = true;
  bool _hasMorePagesVentas = true;
  
  bool _isInitialLoadingTodas = true;
  bool _isInitialLoadingCompras = true;
  bool _isInitialLoadingVentas = true;

  String? _errorTodas;
  String? _errorCompras;
  String? _errorVentas;

  final ScrollController _scrollControllerTodas = ScrollController();
  final ScrollController _scrollControllerCompras = ScrollController();
  final ScrollController _scrollControllerVentas = ScrollController();

  // Formateadores
  final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 2);
  final NumberFormat _cryptoQuantityFormatter = NumberFormat.decimalPatternDigits(locale: 'es_ES', decimalDigits: 6);
  final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm', 'es_ES');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadHistorialTransacciones(tipo: null, page: 0, isRefreshing: true);
      }
    });

    _scrollControllerTodas.addListener(() => _onScroll(_scrollControllerTodas, null));
    _scrollControllerCompras.addListener(() => _onScroll(_scrollControllerCompras, "COMPRA"));
    _scrollControllerVentas.addListener(() => _onScroll(_scrollControllerVentas, "VENTA"));
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _scrollControllerTodas.dispose();
    _scrollControllerCompras.dispose();
    _scrollControllerVentas.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      return;
    }
    switch (_tabController.index) {
      case 0: // Todas
        if (_todasTransacciones.isEmpty && !_isLoadingMoreTodas && _errorTodas == null) {
          _loadHistorialTransacciones(tipo: null, page: 0, isRefreshing: true);
        }
        break;
      case 1: // Compras
        if (_comprasTransacciones.isEmpty && !_isLoadingMoreCompras && _errorCompras == null) {
          _loadHistorialTransacciones(tipo: "COMPRA", page: 0, isRefreshing: true);
        }
        break;
      case 2: // Ventas
        if (_ventasTransacciones.isEmpty && !_isLoadingMoreVentas && _errorVentas == null) {
          _loadHistorialTransacciones(tipo: "VENTA", page: 0, isRefreshing: true);
        }
        break;
    }
  }

  void _onScroll(ScrollController controller, String? tipo) {
    if (controller.position.pixels >= controller.position.maxScrollExtent - 200) {
      bool canLoadMore = false;
      int nextPage = 0;
      bool isLoadingMoreForTab = false;

      switch (tipo) {
        case "COMPRA":
          canLoadMore = _hasMorePagesCompras;
          nextPage = _currentPageCompras + 1;
          isLoadingMoreForTab = _isLoadingMoreCompras;
          break;
        case "VENTA":
          canLoadMore = _hasMorePagesVentas;
          nextPage = _currentPageVentas + 1;
          isLoadingMoreForTab = _isLoadingMoreVentas;
          break;
        default: // Todas
          canLoadMore = _hasMorePagesTodas;
          nextPage = _currentPageTodas + 1;
          isLoadingMoreForTab = _isLoadingMoreTodas;
          break;
      }
      if (canLoadMore && !isLoadingMoreForTab) {
        print("HistorialScreen: Llegó al final para tipo '$tipo', cargando página $nextPage...");
        _loadHistorialTransacciones(tipo: tipo, page: nextPage);
      }
    }
  }

  Future<void> _loadHistorialTransacciones({String? tipo, required int page, bool isRefreshing = false}) async {
    if (!mounted) return;

    List<TransaccionApiModel> currentList;
    bool currentIsLoadingMore;
    
    switch (tipo) {
      case "COMPRA":
        currentList = _comprasTransacciones;
        currentIsLoadingMore = _isLoadingMoreCompras;
        if (isRefreshing) _isInitialLoadingCompras = true;
        break;
      case "VENTA":
        currentList = _ventasTransacciones;
        currentIsLoadingMore = _isLoadingMoreVentas;
        if (isRefreshing) _isInitialLoadingVentas = true;
        break;
      default: // Todas
        currentList = _todasTransacciones;
        currentIsLoadingMore = _isLoadingMoreTodas;
        if (isRefreshing) _isInitialLoadingTodas = true;
        break;
    }

    if (currentIsLoadingMore && !isRefreshing) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final int? userId = authProvider.getUserIdFromToken();
    
    if (userId == null) {
      print("HistorialScreen: No se pudo obtener el ID del usuario del token para tipo '$tipo'.");
      if (mounted) {
        setState(() {
          switch (tipo) {
            case "COMPRA": _errorCompras = "No se pudo identificar al usuario."; _isLoadingMoreCompras = false; _isInitialLoadingCompras = false; break;
            case "VENTA": _errorVentas = "No se pudo identificar al usuario."; _isLoadingMoreVentas = false; _isInitialLoadingVentas = false; break;
            default: _errorTodas = "No se pudo identificar al usuario."; _isLoadingMoreTodas = false; _isInitialLoadingTodas = false; break;
          }
        });
      }
      return;
    }

    print("HistorialScreen: Cargando historial para Usuario ID $userId, Tipo: '$tipo', Página: $page, Refrescando: $isRefreshing");
    
    setState(() {
      switch (tipo) {
        case "COMPRA": _isLoadingMoreCompras = true; if (page == 0 && isRefreshing) { _comprasTransacciones.clear(); _currentPageCompras = 0; _hasMorePagesCompras = true; _errorCompras = null; } break;
        case "VENTA": _isLoadingMoreVentas = true; if (page == 0 && isRefreshing) { _ventasTransacciones.clear(); _currentPageVentas = 0; _hasMorePagesVentas = true; _errorVentas = null; } break;
        default: _isLoadingMoreTodas = true; if (page == 0 && isRefreshing) { _todasTransacciones.clear(); _currentPageTodas = 0; _hasMorePagesTodas = true; _errorTodas = null; } break;
      }
      if (page == 0 && isRefreshing) {
         if (tipo == null) _isInitialLoadingTodas = true;
         else if (tipo == "COMPRA") _isInitialLoadingCompras = true;
         else if (tipo == "VENTA") _isInitialLoadingVentas = true;
      }
    });

    try {
      final paginatedResponse = await _tradingApiService.obtenerHistorialTransaccionesUsuario(
        page: page, 
        sort: "fechaTransaccion,desc",
        tipo: tipo 
      );

      if (mounted) {
        setState(() {
          List<TransaccionApiModel> targetList;
          if (tipo == "COMPRA") {
            targetList = _comprasTransacciones;
            _currentPageCompras = paginatedResponse.number;
            _hasMorePagesCompras = !paginatedResponse.last;
            _errorCompras = null;
          } else if (tipo == "VENTA") {
            targetList = _ventasTransacciones;
            _currentPageVentas = paginatedResponse.number;
            _hasMorePagesVentas = !paginatedResponse.last;
            _errorVentas = null;
          } else {
            targetList = _todasTransacciones;
            _currentPageTodas = paginatedResponse.number;
            _hasMorePagesTodas = !paginatedResponse.last;
            _errorTodas = null;
          }
          if (page == 0 && isRefreshing) targetList.clear();
          targetList.addAll(paginatedResponse.content);
        });
      }
    } catch (e) {
      print("HistorialScreen: Error en _fetchTransactions para tipo '$tipo': $e");
      if (mounted) {
        setState(() {
          String errorMessage = e.toString().replaceFirst("Exception: ", "");
          if (tipo == "COMPRA") { _errorCompras = errorMessage; if (page == 0) _comprasTransacciones.clear(); }
          else if (tipo == "VENTA") { _errorVentas = errorMessage; if (page == 0) _ventasTransacciones.clear(); }
          else { _errorTodas = errorMessage; if (page == 0) _todasTransacciones.clear(); }
          
          if (page > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al cargar más transacciones: $errorMessage'), backgroundColor: AppColors.errorRed),
            );
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          if (tipo == "COMPRA") { _isLoadingMoreCompras = false; _isInitialLoadingCompras = false; }
          else if (tipo == "VENTA") { _isLoadingMoreVentas = false; _isInitialLoadingVentas = false; }
          else { _isLoadingMoreTodas = false; _isInitialLoadingTodas = false; }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Transacciones'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Compras'),
            Tab(text: 'Ventas'),
          ],
         
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(context, _todasTransacciones, _scrollControllerTodas, _isLoadingMoreTodas, _hasMorePagesTodas, _isInitialLoadingTodas, _errorTodas, null),
          _buildTransactionList(context, _comprasTransacciones, _scrollControllerCompras, _isLoadingMoreCompras, _hasMorePagesCompras, _isInitialLoadingCompras, _errorCompras, "COMPRA"),
          _buildTransactionList(context, _ventasTransacciones, _scrollControllerVentas, _isLoadingMoreVentas, _hasMorePagesVentas, _isInitialLoadingVentas, _errorVentas, "VENTA"),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
      BuildContext context, 
      List<TransaccionApiModel> transacciones,
      ScrollController scrollController,
      bool isLoadingMore,
      bool hasMorePages,
      bool isInitialLoading,
      String? errorMessage,
      String? tipoFiltro
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    if (isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null && transacciones.isEmpty) {
      return _buildErrorWidget(errorMessage, theme, colorScheme, () => _loadHistorialTransacciones(tipo: tipoFiltro, page: 0, isRefreshing: true));
    }
    if (transacciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 48, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text('No hay transacciones ${tipoFiltro != null ? (tipoFiltro == "COMPRA" ? "de compra" : "de venta") : ""} para mostrar.', style: textTheme.titleMedium),
            const SizedBox(height: 16),
            ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refrescar'),
                onPressed: () => _loadHistorialTransacciones(tipo: tipoFiltro, page: 0, isRefreshing: true),
            )
          ],
        ),
      );
    }
            
    return RefreshIndicator(
      onRefresh: () => _loadHistorialTransacciones(tipo: tipoFiltro, page: 0, isRefreshing: true),
      child: ListView.builder(
        controller: scrollController,
        itemCount: transacciones.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == transacciones.length && isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          if (index >= transacciones.length) {
             return const SizedBox.shrink();
          }

          final transaccion = transacciones[index];
          final esCompra = transaccion.tipoTransaccion.toUpperCase() == "COMPRA";
          final colorValor = esCompra ? AppColors.errorRed : AppColors.successGreen;
          final signo = esCompra ? "-" : "+";
          final icono = esCompra 
              ? Icon(Icons.arrow_downward_rounded, color: colorValor, size: 28)
              : Icon(Icons.arrow_upward_rounded, color: colorValor, size: 28);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 1.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorValor.withOpacity(0.1),
                  child: icono,
                ),
                title: Text(
                  '${esCompra ? "Compra" : "Venta"} de ${transaccion.simboloCriptomoneda.toUpperCase()}',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Cripto: ${transaccion.nombreCriptomoneda}'),
                    Text('Cantidad: ${_cryptoQuantityFormatter.format(transaccion.cantidadCripto)}'),
                    Text('Precio U.: ${_currencyFormatter.format(transaccion.precioPorUnidadEUR)}'),
                    Text('Fecha: ${_dateTimeFormatter.format(DateTime.parse(transaccion.fechaTransaccion).toLocal())}'),
                  ],
                ),
                trailing: Text(
                  '$signo${_currencyFormatter.format(transaccion.valorTotalEUR)}',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorValor,
                  ),
                ),
                isThreeLine: true,
                onTap: () {
                  print('Tapped on transaction ID: ${transaccion.idTransaccion}');
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String errorMsg, ThemeData theme, ColorScheme colorScheme, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMsg.replaceFirst("Exception: ", ""), 
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              onPressed: onRetry,
            )
          ],
        ),
      ),
    );
  }
}

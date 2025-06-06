import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import '../../../core/models/cripto_api_model.dart'; 

import '../../../core/services/cripto_api_service.dart';

import '../../providers/auth_provider.dart';

import '../../theme/app_colors.dart'; 
import '../../theme/app_typography.dart'; 

import '../auth/login_screen.dart'; 
import '../cripto_detail/cripto_detail_screen.dart'; 

enum SortCriteria {
  marketCap, 
  priceChange24h, 
}

enum TopNFilter {
  top50,
  top100,
  top250,
}

extension TopNFilterValues on TopNFilter {
  int get value {
    switch (this) {
      case TopNFilter.top50:
        return 50;
      case TopNFilter.top100:
        return 100;
      case TopNFilter.top250:
        return 250;
    }
  }

  String get label {
    switch (this) {
      case TopNFilter.top50:
        return 'Top 50';
      case TopNFilter.top100:
        return 'Top 100';
      case TopNFilter.top250:
        return 'Top 250';
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CryptoApiService _cryptoApiService = CryptoApiService();

  Future<PaginatedCriptoResponse>? _marketListFuture;
  Future<PaginatedCriptoResponse>? _searchResultsFuture;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchTerm = ""; 

  TopNFilter _currentTopNFilter = TopNFilter.top50;
  SortCriteria _currentSortCriteria = SortCriteria.marketCap;

  final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 2);
  final NumberFormat _percentageFormatter = NumberFormat.decimalPercentPattern(locale: 'es_ES', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _fetchMarketList(); 
    _searchController.addListener(_onSearchChanged);
  }

  void _fetchMarketList({bool isRefresh = false}) {
    if (!mounted) return;

    String sortQueryParam;
    if (_currentSortCriteria == SortCriteria.marketCap) {
      sortQueryParam = 'capitalizacion,desc'; 
    } else {
      sortQueryParam = 'cambioPorcentaje24h,desc';
    }

    setState(() {
      _marketListFuture = _cryptoApiService.getCriptomonedasPaginado(
        page: 0, 
        size: _currentTopNFilter.value,
        sort: sortQueryParam,
      );
      if (!_isSearching) {
        _searchResultsFuture = null;
      }
    });
  }

  void _onTopNFilterChanged(TopNFilter? newFilter) {
    if (newFilter != null && newFilter != _currentTopNFilter) {
      if (!mounted) return;
      setState(() {
        _currentTopNFilter = newFilter;
      });
      _fetchMarketList(isRefresh: true);
    }
  }

  void _onSortCriteriaChanged() {
    if (!mounted) return;
    setState(() {
      _currentSortCriteria = _currentSortCriteria == SortCriteria.marketCap
          ? SortCriteria.priceChange24h
          : SortCriteria.marketCap;
    });
    _fetchMarketList(isRefresh: true);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final newSearchTerm = _searchController.text.trim();

      if (newSearchTerm != _searchTerm) { 
        _searchTerm = newSearchTerm; 
        if (_searchTerm.isNotEmpty) {
          _performSearch(_searchTerm);
        } else {
          if (_isSearching) { 
            _clearSearchAndShowMarketList();
          }
        }
      }
    });
  }

  void _performSearch(String term) {
    if (!mounted) return;
    setState(() {
      _isSearching = true; 
      _searchResultsFuture = _cryptoApiService.buscarCriptomonedas(term, page: 0); 
    });
  }
  
  void _clearSearchAndShowMarketList() {
    if (!mounted) return;
    _searchController.clear(); 
    setState(() {
      _isSearching = false;
      _searchTerm = ""; 
      _searchResultsFuture = null; 
    });
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    if (_isSearching && _searchTerm.isNotEmpty) {
      setState(() {
        _searchResultsFuture = _cryptoApiService.buscarCriptomonedas(_searchTerm, page: 0);
      });
    } else {
      _fetchMarketList(isRefresh: true);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Widget _buildMarketFiltersUI(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color filterTextColor = isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final Color filterActiveColor = isDarkMode ? AppColors.primaryLight : AppColors.primaryDark; 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<TopNFilter>(
            value: _currentTopNFilter,
            icon: Icon(Icons.filter_list, color: filterActiveColor),
            elevation: 8,
            style: isDarkMode ? AppTypography.bodyMediumDark.copyWith(color: filterTextColor) : AppTypography.bodyMediumLight.copyWith(color: filterTextColor), 
            underline: Container(height: 2, color: filterActiveColor.withOpacity(0.5)),
            onChanged: _onTopNFilterChanged,
            items: TopNFilter.values.map<DropdownMenuItem<TopNFilter>>((TopNFilter value) {
              return DropdownMenuItem<TopNFilter>(
                value: value,
                child: Text(value.label, style: isDarkMode ? AppTypography.bodyMediumDark.copyWith(color: filterTextColor) : AppTypography.bodyMediumLight.copyWith(color: filterTextColor)), 
              );
            }).toList(),
          ),
          OutlinedButton.icon(
            icon: Icon(
              _currentSortCriteria == SortCriteria.marketCap
                  ? Icons.bar_chart_rounded 
                  : Icons.trending_up,
              size: 18,
              color: filterActiveColor,
            ),
            label: Text(
              _currentSortCriteria == SortCriteria.marketCap ? 'Market Cap' : '% 24h',
              style: isDarkMode ? AppTypography.labelLargeDark.copyWith(color: filterActiveColor) : AppTypography.labelLargeLight.copyWith(color: filterActiveColor),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: filterActiveColor.withOpacity(0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: _onSortCriteriaChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoListItem(CriptoApiModel cripto, bool isDarkMode) {
    final double? priceChangeRaw = cripto.cambioPorcentaje24h; 
    final priceChangeColor = (priceChangeRaw ?? 0.0) >= 0 ? AppColors.accentGreen : AppColors.errorRed; 

    return Card(
       elevation: isDarkMode ? 1 : 2, 
       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
       color: isDarkMode ? AppColors.surfaceDark : AppColors.backgroundLight, 
      child: ListTile(
         contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        leading: cripto.imagen != null && cripto.imagen!.isNotEmpty
            ? CircleAvatar(
                backgroundImage: NetworkImage(cripto.imagen!),
                backgroundColor: Colors.transparent,
                onBackgroundImageError: (exception, stackTrace) {
                  debugPrint("Error cargando imagen para ${cripto.nombre}: $exception");
                },
              )
            : CircleAvatar(
                backgroundColor: (isDarkMode ? AppColors.primaryLight : AppColors.primaryDark).withOpacity(0.15),
                child: Text(
                  cripto.simbolo.isNotEmpty ? cripto.simbolo.substring(0, 1).toUpperCase() : '?',
                  style: (isDarkMode ? AppTypography.titleMediumDark : AppTypography.titleMediumLight).copyWith(
                    color: (isDarkMode ? AppColors.primaryLight : AppColors.primaryDark), 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
        title: Text(
          cripto.nombre,
          style: (isDarkMode ? AppTypography.titleMediumDark : AppTypography.titleMediumLight).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text( 
          cripto.simbolo.toUpperCase(),
          style: isDarkMode ? AppTypography.bodySmallDark.copyWith(color: AppColors.textSecondaryDark) : AppTypography.bodySmallLight.copyWith(color: AppColors.textSecondaryLight),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              cripto.precioActual != null
                  ? _currencyFormatter.format(cripto.precioActual)
                  : 'N/A',
              style: (isDarkMode ? AppTypography.bodyMediumDark : AppTypography.bodyMediumLight).copyWith( 
                fontWeight: FontWeight.bold,
              ),
            ),
            priceChangeRaw != null
              ? Text(
                  _percentageFormatter.format(priceChangeRaw / 100.0),
                  style: (isDarkMode ? AppTypography.bodySmallDark : AppTypography.bodySmallLight).copyWith(
                    color: priceChangeColor,
                    fontWeight: FontWeight.w500
                  ),
                )
              : Text(
                  'N/A',
                  style: (isDarkMode ? AppTypography.bodySmallDark : AppTypography.bodySmallLight).copyWith(
                    color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500
                  ),
                ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CriptoDetailScreen(cryptoId: cripto.id, criptoName: cripto.nombre),
            ),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Future<PaginatedCriptoResponse>? currentFuture =
        _isSearching && _searchTerm.isNotEmpty ? _searchResultsFuture : _marketListFuture;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o símbolo...',
                  border: InputBorder.none,
                  hintStyle: (isDarkMode ? AppTypography.bodyLargeDark : AppTypography.bodyLargeLight).copyWith(
                    color: (isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withOpacity(0.7),
                    fontSize: 18 
                  ),
                ),
                style: (isDarkMode ? AppTypography.bodyLargeDark : AppTypography.bodyLargeLight).copyWith(
                  color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontSize: 18 
                ),
              )
            : Text('Mercado', style: isDarkMode ? AppTypography.titleLargeDark : AppTypography.titleLargeLight), 
        actions: [
          _isSearching
              ? IconButton(
                  icon: Icon(Icons.close, color: isDarkMode ? AppColors.iconDark : AppColors.iconLight),
                  tooltip: 'Limpiar y Salir de Búsqueda',
                  onPressed: _clearSearchAndShowMarketList,
                )
              : IconButton(
                  icon: Icon(Icons.search, color: isDarkMode ? AppColors.iconDark : AppColors.iconLight),
                  tooltip: 'Buscar',
                  onPressed: () {
                    if (!mounted) return;
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
          IconButton(
            icon: Icon(Icons.logout, color: isDarkMode ? AppColors.iconDark : AppColors.iconLight),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await authProvider.logout(context);
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
        backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.backgroundLight, 
      ),
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          if (!_isSearching) _buildMarketFiltersUI(context), 
          if (!_isSearching) Divider(height: 1, thickness: 1, color: isDarkMode ? AppColors.borderDark : AppColors.border),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: FutureBuilder<PaginatedCriptoResponse>(
                future: currentFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && currentFuture != null) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: AppColors.errorRed, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${snapshot.error.toString().replaceFirst("Exception: ", "")}',
                              textAlign: TextAlign.center,
                              style: (isDarkMode ? AppTypography.bodyLargeDark : AppTypography.bodyLargeLight).copyWith(color: AppColors.errorRed),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                              onPressed: _refreshData,
                              style: ElevatedButton.styleFrom(backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight),
                            )
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data!.content.isNotEmpty) {
                    final criptos = snapshot.data!.content;
                    return ListView.builder(
                      itemCount: criptos.length,
                      itemBuilder: (context, index) {
                        final cripto = criptos[index];
                        return _buildCryptoListItem(cripto, isDarkMode); 
                      },
                    );
                  } else if (snapshot.hasData && snapshot.data!.content.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: isDarkMode ? AppColors.iconDark : AppColors.iconLight),
                          const SizedBox(height: 16),
                          Text(
                            _isSearching && _searchTerm.isNotEmpty
                                ? 'No se encontraron resultados para "$_searchTerm"'
                                : 'No hay criptomonedas para mostrar.',
                            style: isDarkMode ? AppTypography.bodyLargeDark.copyWith(color: AppColors.textSecondaryDark) : AppTypography.bodyLargeLight.copyWith(color: AppColors.textSecondaryLight),
                            textAlign: TextAlign.center,
                          ),
                           if (!_isSearching) ...[ 
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refrescar Lista'),
                              onPressed: _refreshData,
                              style: ElevatedButton.styleFrom(backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight),
                            )
                           ]
                        ],
                      ),
                    );
                  } else {
                    return Center(child: Text("Cargando datos del mercado...", style: isDarkMode ? AppTypography.bodyMediumDark.copyWith(color: AppColors.textSecondaryDark) : AppTypography.bodyMediumLight.copyWith(color: AppColors.textSecondaryLight)));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

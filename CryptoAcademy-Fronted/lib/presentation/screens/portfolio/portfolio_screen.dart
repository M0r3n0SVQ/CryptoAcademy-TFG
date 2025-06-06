import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/cartera_model.dart';
import '../../../core/models/portfolio_models.dart';
import '../../../core/services/trading_api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cartera_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final TradingApiService _tradingApiService = TradingApiService();
  Future<PortfolioResponseModel>? _portfolioFuture;

  final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 2);
  final NumberFormat _cryptoQuantityFormatter = NumberFormat.decimalPatternDigits(locale: 'es_ES', decimalDigits: 6);
  final NumberFormat _percentageFormatter = NumberFormat.decimalPercentPattern(locale: 'es_ES', decimalDigits: 2);

  CarteraModel? _carteraSeleccionada;
  bool _isInitialCarteraLoadAttempted = false;

  final _formKeyDialog = GlobalKey<FormState>();
  final TextEditingController _nombreCarteraControllerDialog = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("PortfolioScreen: initState()");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("PortfolioScreen: addPostFrameCallback for _initCarteraAndLoadPortfolio");
      _initCarteraAndLoadPortfolio();
    });
  }

  @override
  void dispose() {
    _nombreCarteraControllerDialog.dispose();
    super.dispose();
  }

  Future<void> _initCarteraAndLoadPortfolio({bool forceRefreshCarteras = false}) async {
    if (!mounted) return;
    print("PortfolioScreen: _initCarteraAndLoadPortfolio called (forceRefreshCarteras: $forceRefreshCarteras)");
    final carteraProvider = Provider.of<CarteraProvider>(context, listen: false);

    if (forceRefreshCarteras || (carteraProvider.carteras.isEmpty && !carteraProvider.isLoading)) {
      print("PortfolioScreen: Carteras no cargadas o se fuerza refresh, intentando fetch...");
      await carteraProvider.fetchCarterasUsuario(forceRefresh: forceRefreshCarteras);
      if (!mounted) return;
    }

    if (_carteraSeleccionada != null && !carteraProvider.carteras.any((c) => c.idCartera == _carteraSeleccionada!.idCartera)) {
      print("PortfolioScreen: Cartera seleccionada previamente ya no existe. Deseleccionando.");
      if(mounted) {
        setState(() {
          _carteraSeleccionada = null;
        });
      }
    }

    if (carteraProvider.carteras.isNotEmpty && _carteraSeleccionada == null) {
      print("PortfolioScreen: Seleccionando la primera cartera disponible.");
      if(mounted) {
        setState(() {
          _carteraSeleccionada = carteraProvider.carteras.first;
        });
      }
    } else if (carteraProvider.carteras.isEmpty) {
      print("PortfolioScreen: No hay carteras disponibles. Limpiando selección.");
      if(mounted) {
        setState(() {
          _carteraSeleccionada = null;
        });
      }
    }

    if (_carteraSeleccionada != null) {
      _loadPortfolioDataForSelectedCartera();
    } else {
      print("PortfolioScreen: El usuario no tiene carteras o ninguna está seleccionada.");
      if (mounted) {
        setState(() {
          _portfolioFuture = null;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isInitialCarteraLoadAttempted = true;
      });
    }
  }

  void _loadPortfolioDataForSelectedCartera() {
    if (_carteraSeleccionada == null) {
      print("PortfolioScreen: No hay cartera seleccionada para cargar portfolio.");
      if (mounted) {
        setState(() {
          _portfolioFuture = Future.value(
            PortfolioResponseModel(
              idCartera: 0,
              nombreCartera: "Ninguna cartera seleccionada",
              saldoVirtualEUR: 0.0,
              items: [],
              valorTotalCriptosEUR: 0.0,
              valorTotalPortfolioEUR: 0.0,
            ),
          );
        });
      }
      return;
    }
    if (!mounted) return;
    print("PortfolioScreen: Cargando portfolio para cartera ID: ${_carteraSeleccionada!.idCartera}");
    setState(() {
      _portfolioFuture = _tradingApiService.obtenerPortfolioPorCartera(_carteraSeleccionada!.idCartera);
    });
  }

  Future<void> _mostrarDialogoCrearOEditarCartera(BuildContext scaffoldContext, CarteraModel? carteraExistente) async {
    final carteraProvider = Provider.of<CarteraProvider>(scaffoldContext, listen: false);
    final bool isEditing = carteraExistente != null;
    _nombreCarteraControllerDialog.text = isEditing ? carteraExistente.nombre : '';

    return showDialog<void>(
      context: scaffoldContext,
      barrierDismissible: !(carteraProvider.isCreatingCartera || carteraProvider.isUpdatingCartera),
      builder: (BuildContext dialogContext) {
        return Consumer<CarteraProvider>(
          builder: (context, provider, child) {
            final bool isLoadingOperation = provider.isCreatingCartera || provider.isUpdatingCartera;
            return AlertDialog(
              title: Text(isEditing ? 'Editar Nombre de Cartera' : 'Crear Nueva Cartera'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKeyDialog,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: _nombreCarteraControllerDialog,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la Cartera',
                          hintText: 'Ej: Mi Cartera Principal',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre no puede estar vacío.';
                          }
                          if (value.trim().length > 50) {
                            return 'El nombre no puede exceder los 50 caracteres.';
                          }
                          return null;
                        },
                        maxLength: 50,
                      ),
                      if (provider.operationErrorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          provider.operationErrorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: isLoadingOperation ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isLoadingOperation ? null : () async {
                    if (_formKeyDialog.currentState!.validate()) {
                      final nombre = _nombreCarteraControllerDialog.text.trim();
                      bool success = false;
                      if (isEditing) {
                        success = await provider.actualizarNombreDeCartera(carteraExistente.idCartera, nombre);
                        if (success && mounted) {
                          if (_carteraSeleccionada?.idCartera == carteraExistente.idCartera) {
                            if (mounted) {
                              setState(() {
                                _carteraSeleccionada = provider.carteras.firstWhere(
                                        (c) => c.idCartera == carteraExistente.idCartera,
                                    orElse: () => carteraExistente.copyWith(nombre: nombre)
                                );
                              });
                            }
                          }
                        }
                      } else {
                        success = await provider.crearNuevaCartera(nombre);
                        if (success && mounted && provider.carteras.isNotEmpty) {
                          if (mounted) {
                            setState(() {
                              _carteraSeleccionada = provider.carteras.firstWhere(
                                      (c) => c.nombre == nombre,
                                  orElse: () => provider.carteras.last
                              );
                            });
                          }
                          _loadPortfolioDataForSelectedCartera();
                        }
                      }

                      if (success) {
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(
                            content: Text('Cartera ${isEditing ? "actualizada" : "creada"} con éxito.'),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                      }
                    }
                  },
                  child: isLoadingOperation
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(isEditing ? 'Guardar Cambios' : 'Crear Cartera'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("PortfolioScreen: build() - Cartera Seleccionada: ${_carteraSeleccionada?.nombre}, InitialLoadAttempted: $_isInitialCarteraLoadAttempted");
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Consumer<CarteraProvider>(
      builder: (context, carteraProvider, child) {
        if (_isInitialCarteraLoadAttempted && _carteraSeleccionada == null && carteraProvider.carteras.isNotEmpty && !carteraProvider.isLoading) {
          print("PortfolioScreen build (Consumer): Cartera seleccionada es null pero hay carteras en provider, seleccionando la primera.");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _carteraSeleccionada = carteraProvider.carteras.first;
              });
              _loadPortfolioDataForSelectedCartera();
            }
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: _carteraSeleccionada != null
                  ? Text('Portfolio: ${_carteraSeleccionada!.nombre}', style: isDarkMode ? AppTypography.titleLargeDark : AppTypography.titleLargeLight)
                  : Text('Mi Portfolio', style: isDarkMode ? AppTypography.titleLargeDark : AppTypography.titleLargeLight),
            ),
            backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.backgroundLight,
            iconTheme: IconThemeData(color: isDarkMode ? AppColors.iconDark : AppColors.iconLight),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: isDarkMode ? AppColors.iconDark : AppColors.iconLight),
                tooltip: 'Refrescar datos',
                onPressed: () async {
                  print("PortfolioScreen: Botón Refrescar presionado.");
                  await _initCarteraAndLoadPortfolio(forceRefreshCarteras: true);
                },
              ),
            ],
          ),
          backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: Column(
            children: [

              if (carteraProvider.isLoading && !_isInitialCarteraLoadAttempted)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2, semanticsLabel: "Cargando carteras")),
                )
              else if (!carteraProvider.isLoading && carteraProvider.errorMessage != null && carteraProvider.carteras.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error al cargar carteras: ${carteraProvider.errorMessage}', style: TextStyle(color: theme.colorScheme.error)),
                )
              else if (!carteraProvider.isLoading && carteraProvider.carteras.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 8.0, 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<CarteraModel>(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                            ),
                            value: _carteraSeleccionada,
                            isExpanded: true,
                            hint: Text('Elige una cartera', style: isDarkMode ? AppTypography.bodyMediumDark : AppTypography.bodyMediumLight),
                            dropdownColor: isDarkMode ? AppColors.surfaceDark : AppColors.backgroundLight,
                            items: carteraProvider.carteras.map((CarteraModel cartera) {
                              return DropdownMenuItem<CarteraModel>(
                                value: cartera,
                                child: Text(
                                    cartera.nombre,
                                    style: isDarkMode ? AppTypography.bodyMediumDark : AppTypography.bodyMediumLight,
                                    overflow: TextOverflow.ellipsis
                                ),
                              );
                            }).toList(),
                            onChanged: (CarteraModel? newValue) {
                              if (newValue != null && newValue != _carteraSeleccionada) {
                                print("PortfolioScreen: Cartera cambiada a ${newValue.nombre}");
                                if(mounted) {
                                  setState(() {
                                    _carteraSeleccionada = newValue;
                                    _portfolioFuture = null;
                                  });
                                }
                                _loadPortfolioDataForSelectedCartera();
                              }
                            },
                          ),
                        ),
                        if (_carteraSeleccionada != null)
                          IconButton(
                            icon: Icon(Icons.edit_note_outlined, color: isDarkMode ? AppColors.iconDark : AppColors.iconLight),
                            tooltip: 'Editar nombre de cartera',
                            onPressed: () {
                              _mostrarDialogoCrearOEditarCartera(context, _carteraSeleccionada);
                            },
                          ),
                      ],
                    ),
                  )
                else if (_isInitialCarteraLoadAttempted && carteraProvider.carteras.isEmpty && !carteraProvider.isLoading)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.account_balance_wallet_outlined, size: 48, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              "No tienes carteras creadas.",
                              style: isDarkMode ? AppTypography.titleMediumDark : AppTypography.titleMediumLight,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Pulsa el botón '+' para añadir tu primera cartera.",
                              style: isDarkMode ? AppTypography.bodyMediumDark.copyWith(color: AppColors.textSecondaryDark) : AppTypography.bodyMediumLight.copyWith(color: AppColors.textSecondaryLight),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    print("PortfolioScreen: RefreshIndicator activado.");
                    if (_carteraSeleccionada != null) {
                      await carteraProvider.fetchCarterasUsuario(forceRefresh: true);
                      if(mounted) _loadPortfolioDataForSelectedCartera();
                    } else {
                      await _initCarteraAndLoadPortfolio(forceRefreshCarteras: true);
                    }
                  },
                  child: (_carteraSeleccionada == null && !carteraProvider.isLoading && _isInitialCarteraLoadAttempted && carteraProvider.carteras.isNotEmpty)
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Por favor, selecciona una cartera para ver el portfolio.",
                        style: (isDarkMode ? AppTypography.titleMediumDark : AppTypography.titleMediumLight).copyWith(color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                      : FutureBuilder<PortfolioResponseModel>(
                    future: _portfolioFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && _portfolioFuture != null && _carteraSeleccionada != null) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        print("PortfolioScreen: Error en FutureBuilder: ${snapshot.error}");
                        return _buildErrorWidget('Error al cargar el portfolio: ${snapshot.error.toString().replaceFirst("Exception: ", "")}', theme, _loadPortfolioDataForSelectedCartera);
                      } else if (snapshot.hasData && _carteraSeleccionada != null) {
                        final portfolio = snapshot.data!;
                        return _buildPortfolioView(portfolio, theme, isDarkMode);
                      } else {
                        if (_carteraSeleccionada != null && _portfolioFuture == null && _isInitialCarteraLoadAttempted) {
                          return const Center(child: Text('Iniciando carga del portfolio...'));
                        }
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _mostrarDialogoCrearOEditarCartera(context, null);
            },
            icon: const Icon(Icons.add),
            label: const Text('Nueva Cartera'),
            backgroundColor: isDarkMode ? AppColors.primaryLight : AppColors.primaryDark,
            foregroundColor: isDarkMode ? AppColors.textPrimaryDark : Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildPortfolioView(PortfolioResponseModel portfolio, ThemeData theme, bool isDarkMode) {
    double summaryLabelFontSize = AppTypography.bodyMediumLight.fontSize ?? 14.0;
    double summaryValueFontSize = AppTypography.bodyLargeLight.fontSize ?? 15.0;
    double totalFontSize = AppTypography.titleSmallDark.fontSize ?? 16.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, (portfolio.items.isNotEmpty ? 96.0 : 16.0) + MediaQuery.of(context).padding.bottom), // Aumentado padding inferior
      children: [
        Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16.0),
          color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPortfolioSummaryRow(
                    'Saldo Fiat (Cartera):',
                    _currencyFormatter.format(portfolio.saldoVirtualEUR),
                    theme,
                    isDarkMode,
                    labelFontSize: 10.0,
                    valueFontSize: summaryValueFontSize
                ),
                _buildPortfolioSummaryRow(
                    'Valor Criptos (Cartera):',
                    _currencyFormatter.format(portfolio.valorTotalCriptosEUR),
                    theme,
                    isDarkMode,
                    labelFontSize: 9.5,
                    valueFontSize: summaryValueFontSize
                ),
                const Divider(height: 24, thickness: 0.5),
                _buildPortfolioSummaryRow(
                    'Valor Total (Cartera):',
                    _currencyFormatter.format(portfolio.valorTotalPortfolioEUR),
                    theme,
                    isDarkMode,
                    isTotal: true,
                    labelFontSize: 10.0,
                    valueFontSize: totalFontSize
                ),
              ],
            ),
          ),
        ),

        if (portfolio.items.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text('Mis Criptomonedas', style: (isDarkMode ? AppTypography.titleLargeDark : AppTypography.titleLargeLight).copyWith(fontWeight: FontWeight.bold)),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: portfolio.items.length,
            itemBuilder: (context, index) {
              final item = portfolio.items[index];
              final priceChangeColor = (item.cambioPorcentaje24h ?? 0) >= 0 ? AppColors.accentGreen : AppColors.errorRed;

              double itemTitleFontSize = AppTypography.bodyLargeDark.fontSize ?? 15.0;
              double itemSubtitleFontSize = AppTypography.bodyMediumDark.fontSize ?? 13.0;
              double itemTrailingValueFontSize = AppTypography.bodyLargeDark.fontSize ?? 15.0;
              double itemTrailingChangeFontSize = AppTypography.bodySmallDark.fontSize ?? 12.0;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  leading: item.imagenUrl != null && item.imagenUrl!.isNotEmpty
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(item.imagenUrl!),
                    backgroundColor: Colors.transparent,
                    onBackgroundImageError: (e,s) => print("Error imagen portfolio: ${item.imagenUrl}"),
                  )
                      : CircleAvatar(
                    backgroundColor: (isDarkMode ? AppColors.primaryLight : AppColors.primaryDark).withOpacity(0.15),
                    child: Text(
                      item.simboloCriptomoneda.isNotEmpty ? item.simboloCriptomoneda.substring(0, 1).toUpperCase() : '?',
                      style: TextStyle(color: isDarkMode ? AppColors.primaryLight : AppColors.primaryDark, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    item.nombreCriptomoneda,
                    style: (isDarkMode ? AppTypography.titleMediumDark : AppTypography.titleMediumLight).copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: itemTitleFontSize
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${_cryptoQuantityFormatter.format(item.cantidadPoseida)} ${item.simboloCriptomoneda.toUpperCase()}',
                    style: (isDarkMode ? AppTypography.bodyMediumDark : AppTypography.bodyMediumLight).copyWith(
                        color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontSize: itemSubtitleFontSize
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _currencyFormatter.format(item.valorTotalTenenciaEUR),
                          style: (isDarkMode ? AppTypography.titleMediumDark : AppTypography.titleMediumLight).copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: itemTrailingValueFontSize
                          ),
                        ),
                      ),
                      if (item.cambioPorcentaje24h != null)
                        Text(
                          '24h: ${_percentageFormatter.format(item.cambioPorcentaje24h! / 100.0)}',
                          style: (isDarkMode ? AppTypography.bodySmallDark : AppTypography.bodySmallLight).copyWith(
                              color: priceChangeColor,
                              fontSize: itemTrailingChangeFontSize
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    print('Tapped on portfolio item: ${item.nombreCriptomoneda}');
                  },
                ),
              );
            },
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 48, color: (isDarkMode ? AppColors.iconDark : AppColors.iconLight).withOpacity(0.7)),
                  const SizedBox(height: 16),
                  Text('No tienes criptomonedas en esta cartera.', style: (isDarkMode ? AppTypography.bodyLargeDark : AppTypography.bodyLargeLight).copyWith(color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                ],
              ),
            ),
          )
        ],
      ],
    );
  }

  Widget _buildPortfolioSummaryRow(String label, String value, ThemeData theme, bool isDarkMode, {bool isTotal = false, double? labelFontSize, double? valueFontSize}) {
    final effectiveLabelFontSize = labelFontSize ?? (isTotal ? AppTypography.titleMediumDark.fontSize : AppTypography.bodyLargeDark.fontSize);
    final effectiveValueFontSize = valueFontSize ?? (isTotal ? AppTypography.titleMediumDark.fontSize : AppTypography.bodyLargeDark.fontSize);

    final labelStyle = (isTotal
        ? (isDarkMode ? AppTypography.titleMediumDark : AppTypography.titleMediumLight)
        : (isDarkMode ? AppTypography.bodyLargeDark : AppTypography.bodyLargeLight)
    ).copyWith(
        fontWeight: isTotal ? FontWeight.bold : null,
        color: isTotal ? null : (isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        fontSize: effectiveLabelFontSize
    );
    final valueStyle = (isTotal
        ? (isDarkMode ? AppTypography.titleMediumDark : AppTypography.titleMediumLight)
        : (isDarkMode ? AppTypography.bodyLargeDark : AppTypography.bodyLargeLight)
    ).copyWith(
        fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
        fontSize: effectiveValueFontSize
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTotal ? 6.0 : 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: labelStyle, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(value, style: valueStyle, textAlign: TextAlign.end),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String errorMsg, ThemeData theme, VoidCallback onRetry) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.errorRed, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMsg,
              textAlign: TextAlign.center,
              style: (isDarkMode ? AppTypography.bodyLargeDark : AppTypography.bodyLargeLight).copyWith(color: AppColors.errorRed),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight),
            )
          ],
        ),
      ),
    );
  }
}

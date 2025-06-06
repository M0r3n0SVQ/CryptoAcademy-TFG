import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../../core/models/cripto_api_model.dart';
import '../../../core/models/market_chart_model.dart';
import '../../../core/models/orden_request_model.dart';
import '../../../core/models/transaccion_api_model.dart';
import '../../../core/models/cartera_model.dart';
import '../../../core/models/portfolio_models.dart';
import '../../../core/services/cripto_api_service.dart';
import '../../../core/services/trading_api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cartera_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class CriptoDetailScreen extends StatefulWidget {
  final String cryptoId;
  final String? criptoName;

  const CriptoDetailScreen({
    super.key,
    required this.cryptoId,
    this.criptoName,
  });

  @override
  State<CriptoDetailScreen> createState() => _CriptoDetailScreenState();
}

class _CriptoDetailScreenState extends State<CriptoDetailScreen> {
  final TradingApiService _tradingApiService = TradingApiService();
  final CryptoApiService _cryptoApiService = CryptoApiService();
  Future<CriptoApiModel>? _cryptoDetailFuture;
  Future<MarketChartData>? _marketChartFuture;

  final _formKeyDialog = GlobalKey<FormState>();
  final TextEditingController _cantidadControllerDialog = TextEditingController();
  bool _isDialogLoading = false;

  CarteraModel? _carteraSeleccionadaDialog;
  List<CarteraModel> _listaCarterasUsuario = [];
  bool _isLoadingCarteras = false;
  String? _errorCarteras;

  double? _cantidadPoseidaDialog;
  bool _isLoadingCantidadPoseida = false;
  String? _errorCantidadPoseida;

  final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 2);
  final NumberFormat _currencyFormatterSmall = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 6);
  final NumberFormat _compactCurrencyFormatter = NumberFormat.compactSimpleCurrency(locale: 'es_ES', decimalDigits: 2);
  final NumberFormat _largeNumberFormatter = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 0);
  final NumberFormat _percentageFormatter = NumberFormat.decimalPercentPattern(locale: 'es_ES', decimalDigits: 2);
  final NumberFormat _cryptoQuantityFormatter = NumberFormat.decimalPatternDigits(locale: 'es_ES', decimalDigits: 8);

  String _selectedChartDays = "7";
  final List<String> _chartDayOptions = ["1", "7", "30", "90", "365"];
  bool _isDateFormattingInitialized = false;
  double? _chartRangePriceChangePercentage;

  @override
  void initState() {
    super.initState();
    _initializeDateFormattingAndLoadData();
    _cargarCarterasUsuario();
  }

  @override
  void dispose() {
    _cantidadControllerDialog.dispose();
    super.dispose();
  }

  Future<void> _initializeDateFormattingAndLoadData() async {
    if (!_isDateFormattingInitialized) {
      try {
        await initializeDateFormatting('es_ES', null);
        _isDateFormattingInitialized = true;
        print('CriptoDetailScreen: Date formatting initialized for es_ES.');
      } catch (e) {
        print('CriptoDetailScreen: Error initializing date formatting: $e');
        if (mounted) setState(() {});
      }
    }
    _loadAllData();
  }

  void _loadAllData() {
    _loadCryptoDetails();
    _loadMarketChartData();
  }

  void _loadCryptoDetails() {
    if (!mounted) return;
    setState(() {
      _cryptoDetailFuture = _cryptoApiService.getCriptomonedaById(widget.cryptoId);
    });
  }

  void _loadMarketChartData({String? days}) {
    if (!mounted) return;

    String daysForApiCall = _selectedChartDays;
    if (days != null) {
      _selectedChartDays = days;
      daysForApiCall = days;
      _chartRangePriceChangePercentage = null;
    }

    print('CriptoDetailScreen: Cargando datos de gráfico para ID: ${widget.cryptoId}, Días API: $daysForApiCall (UI: $_selectedChartDays)');
    setState(() {
      _marketChartFuture = _cryptoApiService.getMarketChartData(widget.cryptoId, dias: daysForApiCall);
    });
  }

  Future<void> _cargarCarterasUsuario() async {
    if (!mounted) return;
    setState(() {
      _isLoadingCarteras = true;
      _errorCarteras = null;
    });
    try {
      final carteraProvider = Provider.of<CarteraProvider>(context, listen: false);
      await carteraProvider.fetchCarterasUsuario(forceRefresh: true);

      if (!mounted) return;

      _listaCarterasUsuario = List.from(carteraProvider.carteras);
      print("CriptoDetailScreen: Carteras cargadas: ${_listaCarterasUsuario.length}");
    } catch (e) {
      print('CriptoDetailScreen: Error al cargar carteras: $e');
      if (mounted) {
        _errorCarteras = e.toString().replaceFirst("Exception: ", "");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCarteras = false;
        });
      }
    }
  }

  Future<void> _cargarCantidadPoseidaParaDialogo(CarteraModel? cartera, String criptoIdActual, Function(VoidCallback) setDialogState) async {
    if (cartera == null) {
      setDialogState(() {
        _cantidadPoseidaDialog = null;
        _isLoadingCantidadPoseida = false;
        _errorCantidadPoseida = null;
      });
      return;
    }

    setDialogState(() {
      _isLoadingCantidadPoseida = true;
      _errorCantidadPoseida = null;
      _cantidadPoseidaDialog = null;
    });

    try {
      final portfolioData = await _tradingApiService.obtenerPortfolioPorCartera(cartera.idCartera);
      if (!mounted) return;

      final itemEncontrado = portfolioData.items.firstWhere(
            (item) => item.idCriptomoneda == criptoIdActual,
        orElse: () => PortfolioItemModel(
          idCriptomoneda: criptoIdActual,
          nombreCriptomoneda: '',
          simboloCriptomoneda: '',
          cantidadPoseida: 0.0,
          valorTotalTenenciaEUR: 0.0,
          precioActualPorUnidadEUR: 0.0,
        ),
      );

      setDialogState(() {
        _cantidadPoseidaDialog = itemEncontrado.cantidadPoseida;
        _isLoadingCantidadPoseida = false;
      });
      print("DialogoOperacion: Cantidad poseída de $criptoIdActual en cartera ${cartera.nombre}: $_cantidadPoseidaDialog");

    } catch (e) {
      print('DialogoOperacion: Error al cargar cantidad poseída: $e');
      if (mounted) {
        setDialogState(() {
          _errorCantidadPoseida = e.toString().replaceFirst("Exception: ", "");
          _isLoadingCantidadPoseida = false;
          _cantidadPoseidaDialog = null;
        });
      }
    }
  }

  Future<void> _mostrarDialogoOperacion({
    required BuildContext screenContext,
    required CriptoApiModel cripto,
    required bool esCompra,
  }) async {
    _cantidadControllerDialog.clear();

    _carteraSeleccionadaDialog = null;
    _cantidadPoseidaDialog = null;
    _isLoadingCantidadPoseida = false;
    _errorCantidadPoseida = null;
    _isDialogLoading = false;


    if (_listaCarterasUsuario.isEmpty && !_isLoadingCarteras) {
      print("DialogoOperacion: Carteras no disponibles, intentando cargar...");
      await _cargarCarterasUsuario();
      if (!mounted) return;
    }

    if (_listaCarterasUsuario.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(screenContext).showSnackBar(
          const SnackBar(content: Text('No tienes carteras para operar. Crea una desde tu perfil.'), backgroundColor: AppColors.warningOrange),
        );
      }
      return;
    }

    if (_listaCarterasUsuario.isNotEmpty) {
      _carteraSeleccionadaDialog = _listaCarterasUsuario.first;
    }

    final authProvider = Provider.of<AuthProvider>(screenContext, listen: false);
    if (authProvider.token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(screenContext).showSnackBar(
          const SnackBar(content: Text('Error: Usuario no autenticado para operar.'), backgroundColor: AppColors.errorRed)
      );
      return;
    }

    return showDialog<void>(
      context: screenContext,
      barrierDismissible: !_isDialogLoading,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (stfContext, setDialogState) {
              if (_carteraSeleccionadaDialog != null && _cantidadPoseidaDialog == null && !_isLoadingCantidadPoseida && _errorCantidadPoseida == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _cargarCantidadPoseidaParaDialogo(_carteraSeleccionadaDialog, cripto.id, setDialogState);
                });
              }

              Future<void> _confirmarOperacion() async {
                if (_formKeyDialog.currentState!.validate()) {
                  if (_carteraSeleccionadaDialog == null) {
                    ScaffoldMessenger.of(stfContext).showSnackBar(
                      const SnackBar(content: Text('Por favor, selecciona una cartera.'), backgroundColor: AppColors.warningOrange),
                    );
                    return;
                  }

                  setDialogState(() { _isDialogLoading = true; });
                  try {
                    String cantidadString = _cantidadControllerDialog.text.replaceAll(',', '.');

                    final orden = OrdenRequestModel(
                      idCartera: _carteraSeleccionadaDialog!.idCartera,
                      idCriptomoneda: cripto.id,
                      cantidad: cantidadString,
                    );

                    TransaccionApiModel transaccionRealizada;
                    String operacionStr = esCompra ? "Compra" : "Venta";

                    if (esCompra) {
                      transaccionRealizada = await _tradingApiService.comprarCripto(orden);
                    } else {
                      transaccionRealizada = await _tradingApiService.venderCripto(orden);
                    }
                    print('$operacionStr realizada: ${transaccionRealizada.idTransaccion}');

                    if (!mounted) return;
                    Navigator.of(dialogContext).pop();

                    ScaffoldMessenger.of(screenContext).showSnackBar(
                      SnackBar(content: Text('$operacionStr realizada con éxito! ID: ${transaccionRealizada.idTransaccion}'), backgroundColor: AppColors.successGreen),
                    );

                    _loadAllData();
                    Provider.of<CarteraProvider>(screenContext, listen: false).fetchCarterasUsuario(forceRefresh: true);

                  } catch (e) {
                    print('Error en operación de ${esCompra ? "compra" : "venta"}: $e');
                    if (stfContext.mounted) {
                      setDialogState(() {});
                    }
                    if (screenContext.mounted) {
                      ScaffoldMessenger.of(screenContext).showSnackBar(
                        SnackBar(content: Text('Error al realizar la ${esCompra ? "compra" : "venta"}: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: AppColors.errorRed),
                      );
                    }
                  } finally {
                    if (stfContext.mounted) {
                      setDialogState(() { _isDialogLoading = false; });
                    } else if (_isDialogLoading) {
                      _isDialogLoading = false;
                    }
                  }
                }
              }

              return AlertDialog(
                title: Text('${esCompra ? "Comprar" : "Vender"} ${cripto.nombre}'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKeyDialog,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Precio actual: ${_currencyFormatter.format(cripto.precioActual ?? 0)}'),
                        const SizedBox(height: 10),

                        if (_isLoadingCarteras)
                          const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2))),
                        if (!_isLoadingCarteras && _errorCarteras != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('Error carteras: $_errorCarteras', style: const TextStyle(color: AppColors.errorRed)),
                          ),
                        if (!_isLoadingCarteras && _errorCarteras == null && _listaCarterasUsuario.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('No tienes carteras disponibles.', style: TextStyle(color: AppColors.warningOrange)),
                          ),

                        if (!_isLoadingCarteras && _errorCarteras == null && _listaCarterasUsuario.isNotEmpty)
                          DropdownButtonFormField<CarteraModel>(
                            decoration: InputDecoration(
                              labelText: 'Seleccionar Cartera',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                            ),
                            value: _carteraSeleccionadaDialog,
                            isExpanded: true,
                            hint: const Text('Elige una cartera'),
                            items: _listaCarterasUsuario.map((CarteraModel cartera) {
                              return DropdownMenuItem<CarteraModel>(
                                value: cartera,
                                child: Text(cartera.nombre, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: _isDialogLoading ? null : (CarteraModel? newValue) {
                              if (newValue != null) {
                                setDialogState(() {
                                  _carteraSeleccionadaDialog = newValue;
                                  _cantidadPoseidaDialog = null;
                                  _errorCantidadPoseida = null;
                                  _isLoadingCantidadPoseida = true;
                                });
                                _cargarCantidadPoseidaParaDialogo(newValue, cripto.id, setDialogState);
                              }
                            },
                            validator: (value) => value == null ? 'Selecciona una cartera' : null,
                          ),
                        const SizedBox(height: 8),

                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          child: _carteraSeleccionadaDialog != null
                              ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Saldo en esta cartera:',
                                  style: TextStyle(fontSize: 13, color: Theme.of(stfContext).colorScheme.onSurfaceVariant),
                                ),
                                Text(
                                  _currencyFormatter.format(_carteraSeleccionadaDialog!.saldoVirtualEUR),
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(stfContext).colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          )
                              : const SizedBox.shrink(),
                        ),

                        if (!esCompra)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: _carteraSeleccionadaDialog == null ? const SizedBox.shrink() :
                            _isLoadingCantidadPoseida
                                ? const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: SizedBox(height:16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                                : _errorCantidadPoseida != null
                                ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Error al cargar poseído: $_errorCantidadPoseida', style: const TextStyle(color: AppColors.warningOrange, fontSize: 12)),
                            )
                                : _cantidadPoseidaDialog != null
                                ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Posees: ${_cryptoQuantityFormatter.format(_cantidadPoseidaDialog)} ${cripto.simbolo.toUpperCase()}',
                                style: TextStyle(fontSize: 13, color: Theme.of(stfContext).colorScheme.onSurfaceVariant),
                              ),
                            )
                                : const SizedBox.shrink(),
                          ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: _cantidadControllerDialog,
                          decoration: InputDecoration(
                            labelText: 'Cantidad de ${cripto.simbolo.toUpperCase()}',
                            hintText: '0.00',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,8}')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Ingresa una cantidad';
                            try {
                              final String valorNormalizado = value.replaceAll(',', '.');
                              final cantidadNum = double.parse(valorNormalizado);

                              if (cantidadNum <= 0) return 'La cantidad debe ser > 0';

                              if (esCompra && _carteraSeleccionadaDialog != null) {
                                final costoEstimado = cantidadNum * (cripto.precioActual ?? 0);
                                if (costoEstimado > _carteraSeleccionadaDialog!.saldoVirtualEUR) {
                                  return 'Saldo insuficiente en cartera.';
                                }
                              }
                              if (!esCompra && _cantidadPoseidaDialog != null && cantidadNum > _cantidadPoseidaDialog!) {
                                return 'Cantidad insuficiente para vender';
                              }
                            } catch (e) {
                              return 'Número inválido';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: _isDialogLoading ? null : () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: _isDialogLoading || _isLoadingCarteras || _listaCarterasUsuario.isEmpty || _carteraSeleccionadaDialog == null
                        ? null
                        : _confirmarOperacion,
                    style: ElevatedButton.styleFrom(backgroundColor: esCompra ? AppColors.accentGreen : AppColors.errorRed),
                    child: _isDialogLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(esCompra ? 'CONFIRMAR COMPRA' : 'CONFIRMAR VENTA'),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<CriptoApiModel>(
          future: _cryptoDetailFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.nombre, overflow: TextOverflow.ellipsis);
            }
            return Text(widget.criptoName ?? 'Detalles');
          },
        ),
      ),
      body: FutureBuilder<CriptoApiModel>(
        future: _cryptoDetailFuture,
        builder: (context, cryptoSnapshot) {
          if (!_isDateFormattingInitialized && cryptoSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 8), Text("Inicializando datos...")],));
          }

          if (cryptoSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (cryptoSnapshot.hasError) {
            return _buildErrorWidget('Error al cargar detalles: ${cryptoSnapshot.error.toString().replaceFirst("Exception: ", "")}', theme, colorScheme, _loadCryptoDetails);
          } else if (cryptoSnapshot.hasData) {
            final cripto = cryptoSnapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeaderSection(cripto, textTheme, colorScheme, _chartRangePriceChangePercentage, _selectedChartDays),
                  const Divider(height: 32, thickness: 1),

                  Text('Estadísticas de Mercado', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildStatisticRow('Capitalización:',
                      cripto.capitalizacion != null
                          ? _compactCurrencyFormatter.format(cripto.capitalizacion)
                          : 'N/A',
                      context),
                  _buildStatisticRow('Volumen (24h):',
                      cripto.volumen24h != null
                          ? _largeNumberFormatter.format(cripto.volumen24h)
                          : 'N/A',
                      context),
                  _buildStatisticRow('Última Actualización:',
                      (cripto.fechaActualizacion?.isNotEmpty ?? false) && _isDateFormattingInitialized
                          ? DateFormat('dd/MM/yyyy HH:mm', 'es_ES').format(DateTime.parse(cripto.fechaActualizacion!).toLocal())
                          : (cripto.fechaActualizacion?.isNotEmpty ?? false ? cripto.fechaActualizacion!.replaceFirst('T', ' ').substring(0,16) : 'N/A'),
                      context),

                  const Divider(height: 32, thickness: 1),
                  Text('Gráfico de Precios (${_selectedChartDays}D)', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  _buildChartTimeRangeSelector(textTheme, colorScheme),
                  const SizedBox(height: 12),
                  _buildPriceChartContainer(colorScheme, textTheme),

                  const SizedBox(height: 32),
                  _buildActionButtons(cripto, context, colorScheme),
                  const SizedBox(height: 16),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No hay datos disponibles.'));
          }
        },
      ),
    );
  }

  Widget _buildHeaderSection(
      CriptoApiModel cripto,
      TextTheme textTheme,
      ColorScheme colorScheme,
      double? chartRangePriceChangePercentage,
      String selectedChartDays
      ) {

    double? displayPercentage;
    bool isPositiveChange;

    if (selectedChartDays == "1" && cripto.cambioPorcentaje24h != null) {
      displayPercentage = cripto.cambioPorcentaje24h;
    } else if (chartRangePriceChangePercentage != null) {
      displayPercentage = chartRangePriceChangePercentage;
    }

    isPositiveChange = displayPercentage != null && displayPercentage >= 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (cripto.imagen != null && cripto.imagen!.isNotEmpty)
          CircleAvatar(
            backgroundImage: NetworkImage(cripto.imagen!),
            radius: 32,
            backgroundColor: Colors.transparent,
            onBackgroundImageError: (e,s) => print("Error al cargar imagen en detalle: ${cripto.imagen}"),
          )
        else
          CircleAvatar(
            radius: 32,
            backgroundColor: colorScheme.secondaryContainer,
            child: Text(
                cripto.simbolo.isNotEmpty ? cripto.simbolo.substring(0, 1).toUpperCase() : '?',
                style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSecondaryContainer)
            ),
          ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cripto.nombre,
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                cripto.simbolo.toUpperCase(),
                style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                cripto.precioActual != null
                    ? (cripto.precioActual! < 0.01 && cripto.precioActual! > 0 ? _currencyFormatterSmall.format(cripto.precioActual!) : _currencyFormatter.format(cripto.precioActual!))
                    : 'N/A',
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (displayPercentage != null)
              Text(
                _percentageFormatter.format(displayPercentage / 100.0),
                style: textTheme.titleSmall?.copyWith(
                  color: isPositiveChange
                      ? AppColors.chartLineUp
                      : AppColors.chartLineDown,
                ),
              )
            else if (selectedChartDays != "1")
              Text(
                "N/A",
                style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
              )
          ],
        ),
      ],
    );
  }

  Widget _buildStatisticRow(String label, String value, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              softWrap: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTimeRangeSelector(TextTheme textTheme, ColorScheme colorScheme) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _chartDayOptions.length,
        itemBuilder: (context, index) {
          final days = _chartDayOptions[index];
          final bool isSelected = days == _selectedChartDays;
          return ChoiceChip(
            label: Text('${days}D'),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                _loadMarketChartData(days: days);
              }
            },
            selectedColor: colorScheme.primary,
            labelStyle: textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            backgroundColor: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                  width: 1.0,
                )
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
      ),
    );
  }

  Widget _buildPriceChartContainer(ColorScheme colorScheme, TextTheme textTheme) {
    if (!_isDateFormattingInitialized) {
      return Container(
        height: 250,
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Error al inicializar el formato de fechas para el gráfico.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onErrorContainer),
        ),
      );
    }

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: FutureBuilder<MarketChartData>(
        future: _marketChartFuture,
        builder: (context, chartSnapshot) {
          if (chartSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          } else if (chartSnapshot.hasError) {
            String originalErrorMessage = chartSnapshot.error.toString();
            String displayErrorMessage;

            if (originalErrorMessage.contains("401") &&
                (originalErrorMessage.toLowerCase().contains("time range") ||
                    originalErrorMessage.toLowerCase().contains("exceeds the allowed time range") ||
                    originalErrorMessage.toLowerCase().contains("históricos están limitados"))) {
              displayErrorMessage = "Los datos históricos están limitados a los últimos 365 días.";
            } else {
              displayErrorMessage = 'Error al cargar datos del gráfico: ${originalErrorMessage.replaceFirst("Exception: ", "")}';
            }
            print("CriptoDetailScreen: Error al cargar datos del gráfico para ${widget.cryptoId}: $originalErrorMessage");
            return _buildErrorWidget(displayErrorMessage, Theme.of(context), colorScheme, () => _loadMarketChartData());
          } else if (chartSnapshot.hasData && chartSnapshot.data!.prices.isNotEmpty) {
            final chartData = chartSnapshot.data!;
            final spots = chartData.prices.map((point) {
              return FlSpot(point.date.millisecondsSinceEpoch.toDouble(), point.price);
            }).toList();
            spots.sort((a, b) => a.x.compareTo(b.x));

            // --- MODIFICADO: Guardar minX y maxX para pasarlos a bottomTitleWidgets ---
            double minX = spots.first.x;
            double maxX = spots.last.x;

            if (spots.length > 1) {
              double firstPrice = spots.first.y;
              double lastPrice = spots.last.y;
              double newPercentageChange = 0;
              if (firstPrice != 0) {
                newPercentageChange = ((lastPrice - firstPrice) / firstPrice) * 100;
              } else {
                newPercentageChange = lastPrice > 0 ? double.maxFinite : 0.0;
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _chartRangePriceChangePercentage != newPercentageChange) {
                  setState(() {
                    _chartRangePriceChangePercentage = newPercentageChange;
                  });
                }
              });
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _chartRangePriceChangePercentage != null) {
                  setState(() {
                    _chartRangePriceChangePercentage = null;
                  });
                }
              });
            }
            // --- MODIFICADO: Pasar minX y maxX ---
            return _actualLineChartWidget(spots, colorScheme, textTheme, minX, maxX);
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _chartRangePriceChangePercentage != null) {
                setState(() {
                  _chartRangePriceChangePercentage = null;
                });
              }
            });
            return Center(child: Text('No hay datos de gráfico disponibles.', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)));
          }
        },
      ),
    );
  }

  // --- MODIFICADO: Aceptar minX y maxX ---
  Widget _actualLineChartWidget(List<FlSpot> spots, ColorScheme colorScheme, TextTheme textTheme, double minX, double maxX) {
    if (spots.isEmpty) {
      return Center(child: Text("No hay puntos para mostrar en el gráfico.", style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)));
    }

    Color lineColor = AppColors.textSecondaryDark;
    if (spots.length > 1) {
      if (spots.last.y > spots.first.y) lineColor = AppColors.chartLineUp;
      else if (spots.last.y < spots.first.y) lineColor = AppColors.chartLineDown;
    }

    double minYValue = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    double maxYValue = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    if (minYValue == maxYValue) {
      minYValue = minYValue * 0.95;
      maxYValue = maxYValue * 1.05;
      if (minYValue == 0 && maxYValue == 0) maxYValue = 1;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 16.0, top: 16.0, bottom: 4.0),
      child: LineChart(
        LineChartData(
          minY: minYValue, // Renombrado para evitar confusión con el parámetro minX
          maxY: maxYValue, // Renombrado
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(color: colorScheme.onSurface.withOpacity(0.1), strokeWidth: 0.5),
            getDrawingVerticalLine: (value) => FlLine(color: colorScheme.onSurface.withOpacity(0.1), strokeWidth: 0.5),
            horizontalInterval: _calculateYAxisInterval(minYValue, maxYValue, targetLabels: 3),
            verticalInterval: _calculateXAxisInterval(spots),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) => leftTitleWidgets(value, meta, textTheme, minYValue, maxYValue),
                interval: _calculateYAxisInterval(minYValue, maxYValue, targetLabels: 3),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                // --- MODIFICADO: Pasar minX y maxX a bottomTitleWidgets ---
                getTitlesWidget: (value, meta) => bottomTitleWidgets(value, meta, textTheme, spots, minX, maxX),
                interval: _calculateXAxisInterval(spots),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: lineColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [lineColor.withOpacity(0.3), lineColor.withOpacity(0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 8.0,
              getTooltipColor: (LineBarSpot spot) => colorScheme.secondaryContainer.withOpacity(0.9),
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  final date = DateTime.fromMillisecondsSinceEpoch(flSpot.x.toInt());

                  String priceText;
                  if (flSpot.y < 0.01 && flSpot.y > 0) {
                    priceText = _currencyFormatterSmall.format(flSpot.y);
                  } else {
                    priceText = _currencyFormatter.format(flSpot.y);
                  }

                  return LineTooltipItem(
                    '$priceText\n',
                    (textTheme.bodyMedium ?? const TextStyle()).copyWith(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: DateFormat('dd MMM yy, HH:mm', 'es_ES').format(date),
                        style: (textTheme.bodySmall ?? const TextStyle()).copyWith(color: colorScheme.onSecondaryContainer.withOpacity(0.8)),
                      ),
                    ],
                    textAlign: TextAlign.left,
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
        ),
        duration: const Duration(milliseconds: 250),
      ),
    );
  }

  double _getNiceInterval(double range, int maxDivisions) {
    if (range == 0) return 1.0;
    if (maxDivisions <= 0) maxDivisions = 1;

    double roughInterval = range / maxDivisions;
    if (roughInterval == 0) return 1.0;

    List<double> niceFractions = [1.0, 2.0, 2.5, 5.0, 10.0];

    double exponent = math.pow(10, (math.log(roughInterval.abs()) / math.ln10).floorToDouble()).toDouble();

    if (roughInterval.abs() < 1 && roughInterval != 0) {
      exponent = math.pow(10, (math.log(roughInterval.abs()) / math.ln10).ceilToDouble() -1 ).toDouble();
    }
    if (exponent == 0 && roughInterval != 0) exponent = 0.000001;
    else if (exponent == 0 && roughInterval == 0) return 1.0;


    double fraction = roughInterval.abs() / exponent;
    double niceFraction = niceFractions.firstWhere((nf) => nf >= fraction, orElse: () => niceFractions.last);

    double niceInterval = niceFraction * exponent;

    if (niceInterval < 1e-7 && niceInterval != 0) {
      return (range / maxDivisions).abs() > 1e-7 ? (range / maxDivisions).abs() : 1e-7;
    } else if (niceInterval == 0 && range !=0) {
      return (range / maxDivisions).abs() > 0 ? (range / maxDivisions).abs() : 1.0;
    }
    return niceInterval.abs();
  }

  double _calculateYAxisInterval(double minY, double maxY, {int targetLabels = 3}) {
    if (minY == maxY) return maxY > 0 ? math.max(maxY / (targetLabels -1), 1e-6) : 1.0;
    double range = maxY - minY;
    if (range == 0) return 1.0;

    int divisions = math.max(1, targetLabels - 1);

    double interval = _getNiceInterval(range, divisions);
    return interval > 0 ? interval : 1.0;
  }

  double _calculateXAxisInterval(List<FlSpot> spots) {
    if (spots.length < 2) return 1;
    // Ajustar el número de divisiones para intentar mostrar más etiquetas, incluyendo la final
    // Por ejemplo, si queremos unas 3-5 etiquetas visibles (inicio, medio, fin)
    int numberOfDesiredLabels = 3; // Puedes ajustar esto
    if (_selectedChartDays == "1") numberOfDesiredLabels = 4; // Más etiquetas para el gráfico de 1 día

    return (spots.last.x - spots.first.x) / math.max(1, numberOfDesiredLabels -1);
  }


  Widget leftTitleWidgets(double value, TitleMeta meta, TextTheme textTheme, double minY, double maxY) {
    final style = textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ) ?? TextStyle(color: Colors.grey[600], fontSize: 10);

    String text;

    double tolerance = (maxY - minY) * 0.05;
    if (tolerance == 0) tolerance = 0.000001;

    bool isMin = (value - minY).abs() < tolerance;
    bool isMax = (value - maxY).abs() < tolerance;
    bool isMid = (value - (minY + (maxY - minY) / 2)).abs() < tolerance && (maxY - minY) > tolerance * 4;

    if (meta.axisPosition == 0 || meta.axisPosition == 0.5 || meta.axisPosition == 1.0 || isMin || isMax || isMid) {
      text = _formatPriceForAxis(value, minY, maxY);
      return SideTitleWidget(axisSide: meta.axisSide, space: 8, child: Text(text, style: style, textAlign: TextAlign.left));
    }

    return Container();
  }

  String _formatPriceForAxis(double value, double minY, double maxY) {
    if (value.abs() < 0.01 && value != 0 && (maxY - minY) < 0.1) {
      return _currencyFormatterSmall.format(value);
    } else if (value.abs() < 1 && value != 0 && (maxY - minY) < 10){
      return NumberFormat.currency(locale: 'es_ES', symbol: '\$', decimalDigits: 4).format(value);
    }
    else {
      return _compactCurrencyFormatter.format(value);
    }
  }

  // --- MODIFICADO: Aceptar y usar minX, maxX ---
  Widget bottomTitleWidgets(double value, TitleMeta meta, TextTheme textTheme, List<FlSpot> spots, double minX, double maxX) {
    if (spots.isEmpty) return Container();

    final style = textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ) ?? TextStyle(color: Colors.grey[600], fontSize: 10);

    String text = '';
    bool showTitle = false;

    // Definir una pequeña tolerancia para comparar doubles
    const double tolerance = 1.0; // Ajusta esta tolerancia según la escala de tus valores X (milisegundos)

    // Mostrar la primera etiqueta
    if ((value - minX).abs() < tolerance || meta.axisPosition == 0.0) {
      showTitle = true;
    }
    // Mostrar la última etiqueta
    else if ((value - maxX).abs() < tolerance || meta.axisPosition == 1.0) {
      showTitle = true;
    }
    // Mostrar una etiqueta intermedia (opcional, ajusta la lógica si es necesario)
    else if (meta.axisPosition > 0.4 && meta.axisPosition < 0.6 && spots.length > 2) { // Cerca del medio
      // Podrías tener una lógica más sofisticada para el punto medio si lo deseas
      showTitle = true;
    }

    if (showTitle) {
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
      text = _formatDateForAxis(date);
    } else {
      return Container(); // No mostrar etiqueta si no cumple las condiciones
    }

    Alignment alignment = Alignment.center;
    if ((value - minX).abs() < tolerance) { // Si es el primer punto
      alignment = Alignment.centerLeft;
    } else if ((value - maxX).abs() < tolerance) { // Si es el último punto
      alignment = Alignment.centerRight;
    }


    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Align(
          alignment: alignment,
          child: Text(text, style: style)
      ),
    );
  }

  String _formatDateForAxis(DateTime date) {
    if (_selectedChartDays == "1") {
      return DateFormat('HH:mm', 'es_ES').format(date);
    } else if (int.tryParse(_selectedChartDays) != null && int.parse(_selectedChartDays) <= 7) {
      return DateFormat('dd MMM', 'es_ES').format(date);
    } else if (int.tryParse(_selectedChartDays) != null && int.parse(_selectedChartDays) <= 90) {
      return DateFormat('dd MMM', 'es_ES').format(date);
    } else {
      return DateFormat('MMM yy', 'es_ES').format(date);
    }
  }

  Widget _buildActionButtons(CriptoApiModel cripto, BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: const Text('COMPRAR'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ),
            onPressed: () {
              _mostrarDialogoOperacion(screenContext: context, cripto: cripto, esCompra: true);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.remove_shopping_cart_outlined),
            label: const Text('VENDER'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ),
            onPressed: () {
              _mostrarDialogoOperacion(screenContext: context, cripto: cripto, esCompra: false);
            },
          ),
        ),
      ],
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
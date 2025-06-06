import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/usuario_details_model.dart';
import '../../../core/services/trading_api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TradingApiService _apiService = TradingApiService();
  Future<UsuarioDetailsModel?>? _userDetailsFuture;
  Future<double?>? _saldoFiatTotalFuture;
  Future<double?>? _valorCriptoTotalFuture;

  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'es_ES');
  final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 2);

  final _formKeyNombre = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  bool _isEditingNombre = false;
  bool _isSavingNombre = false;
  String? _currentNombreUsuario;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData({bool forceUpdateNombreController = false}) async {
    if (!mounted) return;
    print("ProfileScreen: Cargando datos del perfil...");

    final userDetailsFuture = _apiService.getMiPerfilDetails();
    final saldoFiatFuture = _apiService.getMiSaldoFiatTotal();
    final valorCriptoFuture = _apiService.getMiValorCriptoTotal();

    setState(() {
      _userDetailsFuture = userDetailsFuture;
      _saldoFiatTotalFuture = saldoFiatFuture;
      _valorCriptoTotalFuture = valorCriptoFuture;
    });

    try {
      final userDetails = await userDetailsFuture;
      if (mounted && userDetails != null) {
        setState(() {
          _currentNombreUsuario = userDetails.nombre;
          if (forceUpdateNombreController || _nombreController.text.isEmpty) {
            _nombreController.text = userDetails.nombre;
          }
        });
      }
    } catch (e) {
      print("ProfileScreen: Error al cargar detalles para actualizar nombre: $e");
    }
  }

  Future<void> _guardarNuevoNombre() async {
    if (!_formKeyNombre.currentState!.validate()) {
      return;
    }
    if (_isSavingNombre) return;

    setState(() {
      _isSavingNombre = true;
    });

    try {
      final nuevoNombre = _nombreController.text.trim();
      final usuarioActualizado = await _apiService.actualizarMiNombre(nuevoNombre);

      if (mounted && usuarioActualizado != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nombre actualizado con éxito.'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        _loadProfileData(forceUpdateNombreController: true);
        setState(() {
          _isEditingNombre = false;
        });
      } else if (mounted) {
         throw Exception(usuarioActualizado?.toString() ?? "Respuesta inesperada del servidor.");
      }
    } catch (e) {
      print("Error al actualizar nombre: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar nombre: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingNombre = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil', style: isDarkMode ? AppTypography.titleLargeDark : AppTypography.titleLargeLight),
        backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        elevation: 1,
        iconTheme: IconThemeData(color: isDarkMode ? AppColors.iconDark : AppColors.iconLight),
      ),
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _loadProfileData,
        color: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
        backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            _buildUserDetailsSection(isDarkMode),
            const SizedBox(height: 24),
            _buildFinancialSummarySection(isDarkMode),
            const SizedBox(height: 24),
            _buildEditNombreSection(isDarkMode),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetailsSection(bool isDarkMode) {
    return FutureBuilder<UsuarioDetailsModel?>(
      future: _userDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _currentNombreUsuario == null) {
          return Card(
            elevation: 2,
            color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError && _currentNombreUsuario == null) {
          return Card(
            elevation: 2,
            color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error al cargar datos del perfil: ${snapshot.error}', style: TextStyle(color: AppColors.errorRed)),
            ),
          );
        } else if (snapshot.hasData || _currentNombreUsuario != null) {
          final user = snapshot.data ?? UsuarioDetailsModel(id:0, nombre: _currentNombreUsuario ?? "Cargando...", email: "Cargando...", fechaRegistro: "", rol: "");

          String formattedDate = "No disponible";
          if (user.fechaRegistro.isNotEmpty) {
            try {
              DateTime? registeredDate = DateTime.tryParse(user.fechaRegistro);
              if (registeredDate != null) {
                formattedDate = _dateFormatter.format(registeredDate.toLocal());
              }
            } catch (e) {
              print("Error al formatear fecha de registro: ${user.fechaRegistro} - $e");
            }
          }

          return Card(
            elevation: 2,
            color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Información de la Cuenta", style: (isDarkMode ? AppTypography.titleMediumDark : AppTypography.titleMediumLight).copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 20),
                  _buildProfileInfoRow('Nombre:', user.nombre, isDarkMode),
                  _buildProfileInfoRow('Email:', user.email, isDarkMode),
                  _buildProfileInfoRow('Miembro desde:', formattedDate, isDarkMode),
                  _buildProfileInfoRow('Rol:', user.rol.toUpperCase(), isDarkMode),
                ],
              ),
            ),
          );
        } else {
          return Card(
             elevation: 2,
            color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Cargando datos del perfil...'),
            ),
          );
        }
      },
    );
  }

  Widget _buildFinancialSummarySection(bool isDarkMode) {
    double saldoLabelFontSize = 14.0;
    double saldoValueFontSize = 15.0; 

    return Card(
      elevation: 2,
      color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Resumen Financiero Global", style: (isDarkMode ? AppTypography.titleMediumDark : AppTypography.titleMediumLight).copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            FutureBuilder<double?>(
              future: _saldoFiatTotalFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildProfileInfoRow('Saldo Fiat Total:', 'Cargando...', isDarkMode, isLoading: true, labelFontSize: saldoLabelFontSize, valueFontSize: saldoValueFontSize);
                } else if (snapshot.hasError) {
                  return _buildProfileInfoRow('Saldo Fiat Total:', 'Error', isDarkMode, isError: true, labelFontSize: saldoLabelFontSize, valueFontSize: saldoValueFontSize);
                } else if (snapshot.hasData && snapshot.data != null) {
                  return _buildProfileInfoRow(
                    'Saldo Fiat Total:',
                    _currencyFormatter.format(snapshot.data!),
                    isDarkMode,
                    isCurrency: true,
                    labelFontSize: saldoLabelFontSize,
                    valueFontSize: saldoValueFontSize
                  );
                } else {
                  return _buildProfileInfoRow('Saldo Fiat Total:', 'No disponible', isDarkMode, labelFontSize: saldoLabelFontSize, valueFontSize: saldoValueFontSize);
                }
              },
            ),
            FutureBuilder<double?>(
              future: _valorCriptoTotalFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildProfileInfoRow('Valor Cripto Total:', 'Cargando...', isDarkMode, isLoading: true, labelFontSize: saldoLabelFontSize, valueFontSize: saldoValueFontSize);
                } else if (snapshot.hasError) {
                  return _buildProfileInfoRow('Valor Cripto Total:', 'Error', isDarkMode, isError: true, labelFontSize: saldoLabelFontSize, valueFontSize: saldoValueFontSize);
                } else if (snapshot.hasData && snapshot.data != null) {
                  return _buildProfileInfoRow(
                    'Valor Cripto Total:',
                    _currencyFormatter.format(snapshot.data!),
                    isDarkMode,
                    isCurrency: true,
                    labelFontSize: saldoLabelFontSize,
                    valueFontSize: saldoValueFontSize
                  );
                } else {
                  return _buildProfileInfoRow('Valor Cripto Total:', 'No disponible', isDarkMode, labelFontSize: saldoLabelFontSize, valueFontSize: saldoValueFontSize);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditNombreSection(bool isDarkMode) {
    return Card(
      elevation: 2,
      color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKeyNombre,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Actualizar Nombre",
                style: (isDarkMode ? AppTypography.titleMediumDark : AppTypography.titleMediumLight).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nuevo Nombre',
                  hintText: 'Ingresa tu nuevo nombre',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: _isEditingNombre
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _nombreController.text = _currentNombreUsuario ?? '';
                            setState(() {
                              _isEditingNombre = false;
                            });
                          },
                        )
                      : IconButton(
                          icon: Icon(Icons.edit, color: isDarkMode ? AppColors.iconDark : AppColors.iconLight),
                          onPressed: () {
                             _nombreController.text = _currentNombreUsuario ?? '';
                            setState(() {
                              _isEditingNombre = true;
                            });
                          },
                        )
                ),
                readOnly: !_isEditingNombre,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre no puede estar vacío.';
                  }
                  if (value.trim().length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres.';
                  }
                   if (value.trim().length > 50) {
                    return 'El nombre no puede exceder los 50 caracteres.';
                  }
                  return null;
                },
                onTap: () {
                  if (!_isEditingNombre) {
                    setState(() {
                      _isEditingNombre = true;
                    });
                  }
                }
              ),
              const SizedBox(height: 16),
              if (_isEditingNombre)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSavingNombre ? null : _guardarNuevoNombre,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? AppColors.primaryLight : AppColors.primaryDark,
                      foregroundColor: isDarkMode ? AppColors.textPrimaryDark : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isSavingNombre
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Guardar Nombre'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProfileInfoRow(String label, String value, bool isDarkMode, {bool isCurrency = false, bool isLoading = false, bool isError = false, double? labelFontSize, double? valueFontSize}) {
    final effectiveLabelFontSize = labelFontSize ?? (isDarkMode ? AppTypography.bodyLargeDark.fontSize : AppTypography.bodyLargeLight.fontSize);
    final effectiveValueFontSize = valueFontSize ?? (isDarkMode ? AppTypography.bodyLargeDark.fontSize : AppTypography.bodyLargeLight.fontSize);


    TextStyle labelStyle = (isDarkMode ? AppTypography.bodyLargeDark : AppTypography.bodyLargeLight).copyWith(
      color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      fontSize: effectiveLabelFontSize,
    );
    TextStyle valueStyle = (isDarkMode ? AppTypography.bodyLargeDark : AppTypography.bodyLargeLight).copyWith(
      fontWeight: FontWeight.w500,
      fontSize: isCurrency ? (effectiveValueFontSize ?? 17) : effectiveValueFontSize,
      color: isError ? AppColors.errorRed : (isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
    );

    Widget valueWidget = isLoading
        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
        : FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(value, style: valueStyle, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis),
          );

    if (isError) {
        valueWidget = Text(value, style: valueStyle, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis);
    }


    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: labelStyle, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Align(alignment: Alignment.centerRight, child: valueWidget),
          ),
        ],
      ),
    );
  }
}

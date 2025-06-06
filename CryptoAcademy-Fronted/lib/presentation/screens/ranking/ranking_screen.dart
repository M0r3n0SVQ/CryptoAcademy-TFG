import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/ranking_item_model.dart';

import '../../../core/services/cripto_api_service.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late Future<List<RankingItemModel>> _rankingFuture;
  final CryptoApiService _cryptoApiService = CryptoApiService();
  final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _loadRankingData();
  }

  void _loadRankingData() {
    setState(() {
      _rankingFuture = _cryptoApiService.getRanking(limite: 50); // Cargar Top 50 por defecto
    });
  }

  Future<void> _handleRefresh() async {
    print("RankingScreen: Refrescando datos del ranking...");
    _loadRankingData();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking de Usuarios', style: isDarkMode ? AppTypography.titleLargeDark : AppTypography.titleLargeLight),
        backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.backgroundLight,
        iconTheme: IconThemeData(color: isDarkMode ? AppColors.iconDark : AppColors.iconLight),
      ),
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: isDarkMode ? AppColors.primaryLight : AppColors.primaryDark,
        backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.backgroundLight,
        child: FutureBuilder<List<RankingItemModel>>(
          future: _rankingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print("RankingScreen: Error en FutureBuilder: ${snapshot.error}");
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: AppColors.errorRed, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar el ranking: ${snapshot.error.toString().replaceFirst("Exception: ", "")}',
                        textAlign: TextAlign.center,
                        style: (isDarkMode ? AppTypography.bodyLargeDark : AppTypography.bodyLargeLight).copyWith(color: AppColors.errorRed),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        onPressed: _handleRefresh,
                        style: ElevatedButton.styleFrom(backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight),
                      )
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final rankingList = snapshot.data!;
              return ListView.separated(
                itemCount: rankingList.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1, 
                  thickness: 1, 
                  color: (isDarkMode ? AppColors.borderDark : AppColors.border).withOpacity(0.5),
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  final item = rankingList[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (isDarkMode ? AppColors.primaryLight : AppColors.primaryDark).withOpacity(0.8),
                      foregroundColor: isDarkMode ? AppColors.textPrimaryDark : Colors.white,
                      child: Text(
                        item.posicion.toString(),
                        style: isDarkMode ? AppTypography.titleMediumDark.copyWith(color: AppColors.textPrimaryDark) : AppTypography.titleMediumLight.copyWith(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      item.nombreUsuario,
                      style: (isDarkMode ? AppTypography.titleMediumDark : AppTypography.titleMediumLight).copyWith(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      item.emailOculto,
                      style: (isDarkMode ? AppTypography.bodySmallDark : AppTypography.bodySmallLight).copyWith(color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                    trailing: Text(
                      item.valorPortfolioFormateado, 
                      style: (isDarkMode ? AppTypography.bodyLargeDark : AppTypography.bodyLargeLight).copyWith(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              );
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.leaderboard_outlined, size: 48, color: isDarkMode ? AppColors.iconDark.withOpacity(0.7) : AppColors.iconLight.withOpacity(0.7)),
                    const SizedBox(height: 16),
                    Text(
                      'El ranking está vacío o no hay datos para mostrar.',
                      style: isDarkMode ? AppTypography.bodyLargeDark.copyWith(color: AppColors.textSecondaryDark) : AppTypography.bodyLargeLight.copyWith(color: AppColors.textSecondaryLight),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: Text("Cargando ranking...", style: isDarkMode ? AppTypography.bodyMediumDark : AppTypography.bodyMediumLight));
            }
          },
        ),
      ),
    );
  }
}

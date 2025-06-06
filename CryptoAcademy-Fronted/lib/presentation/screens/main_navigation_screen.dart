import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cryptoacademy_app/presentation/providers/auth_provider.dart';
import 'package:cryptoacademy_app/presentation/theme/app_colors.dart';

import 'package:cryptoacademy_app/presentation/screens/home/home_screen.dart';
import 'package:cryptoacademy_app/presentation/screens/portfolio/portfolio_screen.dart';
import 'package:cryptoacademy_app/presentation/screens/historial/historial_transacciones_screen.dart';
import 'package:cryptoacademy_app/presentation/screens/ranking/ranking_screen.dart';
import 'package:cryptoacademy_app/presentation/screens/profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    PortfolioScreen(),
    HistorialTransaccionesScreen(), // Nueva pantalla de Historial
    RankingScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    print('MainNavigationScreen: Pestaña seleccionada: $index');
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    print('MainNavigationScreen: initState() llamado.');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('MainNavigationScreen: addPostFrameCallback() para _checkLoginMessage.');
      _checkLoginMessage();
    });
  }

  void _checkLoginMessage() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final message = authProvider.loginSuccessMessage;

    if (message != null && message.isNotEmpty) {
      print('MainNavigationScreen: Mostrando SnackBar de éxito: $message');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.successGreen,
        ),
      );
      authProvider.clearLoginSuccessMessage();
    } else {
      print('MainNavigationScreen: No hay mensaje de login para mostrar.');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('MainNavigationScreen: build() ejecutado. Índice seleccionado: $_selectedIndex');

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Portafolio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Ranking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Theme.of(context).bottomAppBarTheme.color ?? Theme.of(context).colorScheme.surface,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
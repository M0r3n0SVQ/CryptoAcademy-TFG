// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importa tus proveedores
import 'presentation/providers/auth_provider.dart'; // Asegúrate que la ruta es correcta
import 'presentation/providers/cartera_provider.dart'; // Asegúrate que la ruta es correcta

// Importa tus pantallas
import 'presentation/screens/auth/login_screen.dart';   // Asegúrate que la ruta es correcta
import 'presentation/screens/main_navigation_screen.dart'; // Asegúrate que la ruta es correcta
// SplashScreen ya no es necesaria para este flujo si no hay auto-login
// import 'presentation/screens/splash_screen.dart'; 

// Importa tu tema
import 'presentation/theme/app_theme.dart';           // Asegúrate que la ruta es correcta

class CryptoAcademyApp extends StatelessWidget {
  const CryptoAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Log para verificar que el método build de CryptoAcademyApp se está llamando.
    print("CryptoAcademyApp: Build method INVOCADO"); 
    
    return MaterialApp(
      title: 'Crypto Academy TFG',
      debugShowCheckedModeBanner: false, // Quita la cinta de "Debug" en la esquina superior derecha
      
      // Configuración del Tema de la Aplicación
      themeMode: ThemeMode.system, // El tema se adaptará a la configuración del sistema (claro/oscuro)
      theme: AppTheme.lightTheme,     // Tu tema claro personalizado definido en app_theme.dart
      darkTheme: AppTheme.darkTheme,  // Tu tema oscuro personalizado definido en app_theme.dart
      
      // La pantalla de inicio (home) se decide dinámicamente basada en el estado de autenticación.
      // Se usa un Consumer<AuthProvider> para escuchar los cambios en AuthProvider.
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Log para depurar el estado del AuthProvider cada vez que el Consumer se reconstruye.
          print('App.dart Consumer<AuthProvider>: Builder INVOCADO. isAuthenticated: ${authProvider.isAuthenticated}');
          
          if (authProvider.isAuthenticated) {
            // Si el usuario está autenticado (después de un login manual exitoso)

            // Intenta cargar las carteras del usuario si aún no se han cargado.
            // Esto asegura que las carteras se intenten cargar después de que
            // el usuario haya sido autenticado exitosamente.
            final carteraProvider = Provider.of<CarteraProvider>(context, listen: false);
            if (carteraProvider.carteras.isEmpty && 
                !carteraProvider.isLoading && 
                carteraProvider.errorMessage == null) {
              
              // Usar WidgetsBinding.instance.addPostFrameCallback para llamar a una función
              // DESPUÉS de que el frame actual se haya construido. Esto es importante para
              // evitar errores como "setState() or markNeedsBuild() called during build"
              // si fetchCarterasUsuario causa una notificación que reconstruye widgets.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Verificar de nuevo si el widget (context) sigue montado antes de la llamada asíncrona
                // y antes de interactuar con el Provider, especialmente si hay operaciones async.
                if (context.mounted) { 
                    print('App.dart Consumer (Authenticated): Disparando fetchCarterasUsuario desde App.dart');
                    // No necesitamos 'await' aquí si no vamos a hacer nada inmediatamente después
                    // que dependa de que las carteras se hayan cargado. CarteraProvider notificará
                    // a sus propios listeners (si los hay) cuando los datos estén listos.
                    carteraProvider.fetchCarterasUsuario();
                }
              });
            }

            print('App.dart Consumer: Usuario autenticado, mostrando MainNavigationScreen.');
            // Navega a la pantalla principal que contiene la BottomNavigationBar
            return const MainNavigationScreen(); 
          } else {
            // Si no está autenticado (estado inicial de la app o después de un logout),
            // siempre muestra LoginScreen.
            print('App.dart Consumer: Usuario NO autenticado, mostrando LoginScreen.');
            return const LoginScreen(); // Navega a la pantalla de login
          }
        },
      ),
      // Rutas nombradas para una navegación más avanzada si las necesitas en el futuro.
      // Permiten navegar a pantallas específicas usando un nombre en lugar de construir la ruta manualmente.
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainNavigationScreen(),
        // Ejemplo para una ruta de detalle que podría requerir pasar argumentos:
        // '/crypto-detail': (context) {
        //   // Así se obtendrían los argumentos si navegas con Navigator.pushNamed(context, '/crypto-detail', arguments: 'bitcoin');
        //   final String cryptoId = ModalRoute.of(context)!.settings.arguments as String;
        //   return CryptoDetailScreen(cryptoId: cryptoId);
        // },
      },
    );
  }
}

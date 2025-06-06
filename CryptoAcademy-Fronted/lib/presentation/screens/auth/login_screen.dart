// lib/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/login_request_model.dart';
import '../../../core/models/login_response_model.dart';
import '../../../core/services/auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart'; 
import '../main_navigation_screen.dart'; 
import 'register_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus(); 

    if (_formKey.currentState!.validate()) {
      print('LoginScreen: [FORM VALIDATED] Formulario validado.');
      setState(() {
        _isLoading = true;
      });

      final loginRequest = LoginRequestModel(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print('LoginScreen: [REQUEST CREATED] Modelo de petición creado: Email: ${loginRequest.email}');
      LoginResponseModel? responseModel;

      try {
        print('LoginScreen: [TRYING] ANTES de llamar a _authService.login()');
        responseModel = await _authService.login(loginRequest);
        print('LoginScreen: [SUCCESS] DESPUÉS de llamar a _authService.login(). Respuesta obtenida.');
        
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        if (mounted && responseModel != null && responseModel.success) {
          print('LoginScreen: [SUCCESS] Login Exitoso! Token: ${responseModel.token}');
          
          await authProvider.login(responseModel.token, context); 
          print('LoginScreen: AuthProvider notificado, token guardado y carteras solicitadas (si aplica).');
          
          if (mounted) {  
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
              (Route<dynamic> route) => false, 
            );
            print('LoginScreen: Navegación explícita a MainNavigationScreen realizada.');
          }

        } else if (mounted && responseModel != null && !responseModel.success) {
           print('LoginScreen: [LOGIN FAILED] El backend devolvió success:false. Mensaje: ${responseModel.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseModel.message.isNotEmpty ? responseModel.message : 'Credenciales incorrectas.'),
                backgroundColor: AppColors.errorRed,
              ),
            );
        } else if (mounted && responseModel == null) {
           print('LoginScreen: [WARN] _authService.login() devolvió null sin lanzar excepción.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Respuesta inesperada del servidor.'),
                backgroundColor: AppColors.warningOrange,
              ),
            );
        }

      } catch (e, s) {
        print('LoginScreen: [CATCH] Error en el proceso de login: ${e.toString()}');
        print('LoginScreen: [CATCH] StackTrace: $s');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Creedenciales inválidas.'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      } finally {
        print('LoginScreen: [FINALLY] Bloque finally ejecutado.');
        if (mounted) { 
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      print('LoginScreen: [FORM INVALID] Formulario no válido.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    print("LoginScreen [FULL]: Build method called!");

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'CryptoAcademy',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inicia sesión para continuar',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant), 
                  ),
                  const SizedBox(height: 40),

                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'tuemail@example.com',
                      prefixIcon: Icon(Icons.email_outlined, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Ingresa un email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'Ingresa tu contraseña',
                      prefixIcon: Icon(Icons.lock_outline, color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login,
                          child: const Text('INICIAR SESIÓN'),
                        ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes una cuenta?',
                        style: textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : () {
                          print('LoginScreen: Botón Regístrate presionado.');
                           Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          'Regístrate',
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
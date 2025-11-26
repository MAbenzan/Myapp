import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart'; // Agregado para UserType

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoginMode = true;
  bool _showResetPassword = false;
  UserType _selectedUserType = UserType.normal; // Agregado
  final _resetEmailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Por favor ingrese un email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }
    if (!_isLoginMode && value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  Future<void> _handleEmailPasswordAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    bool success = false;

    try {
      if (_isLoginMode) {
        success = await authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        // Registro
        success = await authService.registerUser(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _emailController.text.split('@')[0],
          userType: _selectedUserType, // Usar tipo seleccionado
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isLoginMode
                  ? 'Sesión iniciada correctamente'
                  : 'Cuenta creada correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Si es login exitoso, navegar a home
        if (_isLoginMode) {
          // Esperar un momento para que el AuthService se actualice
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } else {
          // Si es registro exitoso, cambiar a modo login
          setState(() {
            _isLoginMode = true;
            _passwordController.clear();
          });
        }
      }
    } catch (e) {
      // Los errores se manejan automáticamente en AuthService
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      bool success;
      if (_isLoginMode) {
        // Modo login - usar signInWithGoogle sin tipo de usuario
        success = await authService.signInWithGoogle();
      } else {
        // Modo registro - usar signInWithGoogle con tipo de usuario
        success = await authService.signInWithGoogle(
          userType: _selectedUserType,
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isLoginMode
                  ? 'Sesión iniciada con Google'
                  : 'Cuenta creada con Google',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Si es login exitoso con Google, navegar a home
        if (_isLoginMode) {
          // Esperar un momento para que el AuthService se actualice
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } else {
          // Si es registro exitoso con Google, cambiar a modo login
          setState(() {
            _isLoginMode = true;
            _passwordController.clear();
          });
        }
      }
    } catch (e) {
      // Los errores se manejan automáticamente en AuthService
    }
  }

  Future<void> _handlePasswordReset() async {
    if (_resetEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingrese su email')),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final success = await authService.resetPassword(
        _resetEmailController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de recuperación enviado'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _showResetPassword = false;
          _resetEmailController.clear();
        });
      }
    } catch (e) {
      // Los errores se manejan automáticamente en AuthService
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _showResetPassword = false;
      _selectedUserType = UserType.normal; // Resetear a tipo normal
      _formKey.currentState?.reset();
    });
  }

  void _toggleResetPassword() {
    setState(() {
      _showResetPassword = !_showResetPassword;
      _resetEmailController.text = _emailController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool googleEnabled = !kIsWeb ||
        (const String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '')
            .isNotEmpty);
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthService>(
          builder: (context, authService, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),

                    // Logo o título
                    const Text(
                      'AppFind',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _showResetPassword
                          ? 'Recuperar Contraseña'
                          : _isLoginMode
                          ? 'Bienvenido de nuevo'
                          : 'Crear cuenta nueva',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Mostrar errores
                    if (authService.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authService.errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: authService.clearError,
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_showResetPassword) ...[
                      // Formulario de recuperación de contraseña
                      TextFormField(
                        controller: _resetEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed:
                            authService.isLoading ? null : _handlePasswordReset,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.orange,
                        ),
                        child:
                            authService.isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Enviar Email de Recuperación'),
                      ),
                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: _toggleResetPassword,
                        child: const Text('Volver al login'),
                      ),
                    ] else ...[
                      // Formulario de login/registro
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: _validatePassword,
                      ),

                      if (!_isLoginMode) ...[
                        const SizedBox(height: 16),

                        // Selección de tipo de cuenta
                        const Text(
                          'Tipo de cuenta:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),

                        RadioGroup<UserType>(
                          groupValue: _selectedUserType,
                          onChanged: (UserType? value) {
                            setState(() {
                              _selectedUserType = value!;
                            });
                          },
                          child: Column(
                            children: [
                              RadioListTile<UserType>(
                                title: const Text('Cuenta Normal'),
                                subtitle: const Text('Para usuarios regulares'),
                                value: UserType.normal,
                              ),
                              RadioListTile<UserType>(
                                title: const Text('Cuenta de Negocio'),
                                subtitle: const Text(
                                  'Para empresas y negocios',
                                ),
                                value: UserType.business,
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Botón principal (Login/Registro)
                      ElevatedButton(
                        onPressed:
                            authService.isLoading
                                ? null
                                : _handleEmailPasswordAuth,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor:
                              _isLoginMode ? Colors.blue : Colors.green,
                        ),
                        child:
                            authService.isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  _isLoginMode
                                      ? 'Iniciar Sesión'
                                      : 'Crear Cuenta',
                                ),
                      ),

                      const SizedBox(height: 16),

                      // Divider
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'O',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Botón de Google Sign-In
                      OutlinedButton.icon(
                        onPressed: authService.isLoading || !googleEnabled
                            ? null
                            : _handleGoogleSignIn,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        icon: Image.network(
                          'https://developers.google.com/identity/images/g-logo.png',
                          height: 20,
                          width: 20,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.login, color: Colors.red),
                        ),
                        label: Text(
                          _isLoginMode
                              ? 'Iniciar sesión con Google'
                              : 'Registrarse con Google',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Enlaces de navegación
                      if (_isLoginMode) ...[
                        TextButton(
                          onPressed: _toggleResetPassword,
                          child: const Text('¿Olvidaste tu contraseña?'),
                        ),
                        const SizedBox(height: 8),
                      ],

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLoginMode
                                ? '¿No tienes cuenta? '
                                : '¿Ya tienes cuenta? ',
                          ),
                          TextButton(
                            onPressed: _toggleMode,
                            child: Text(
                              _isLoginMode ? 'Regístrate' : 'Inicia sesión',
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'user_service.dart';

// Clase para validaciones de entrada
class AuthValidation {
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'El email es requerido';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Ingresa un email válido';
    }

    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'El nombre es requerido';
    }

    if (name.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }

    return null;
  }

  static String? validateBusinessName(String? businessName) {
    if (businessName == null || businessName.trim().isEmpty) {
      return 'El nombre del negocio es requerido';
    }

    if (businessName.trim().length < 2) {
      return 'El nombre del negocio debe tener al menos 2 caracteres';
    }

    return null;
  }
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  UserModel? _userModel;

  // Cache para evitar llamadas repetidas
  DateTime? _lastUserModelUpdate;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  UserModel? get userModel => _userModel;
  String? get userEmail => _currentUser?.email;
  String? get userName => _userModel?.name ?? _currentUser?.displayName;
  String? get userPhotoUrl =>
      _userModel?.profileImageUrl ?? _currentUser?.photoURL;
  UserType? get userType => _userModel?.userType;
  bool get isBusiness => _userModel?.isBusiness ?? false;
  bool get isNormalUser => _userModel?.isNormalUser ?? true;

  AuthService() {
    // Escuchar cambios en el estado de autenticación de Firebase
    _auth.authStateChanges().listen((User? user) async {
      try {
        _currentUser = user;
        _isAuthenticated = user != null;

        if (user != null) {
          // Cargar datos del usuario desde Firestore con cache
          await _loadUserModelWithCache();
        } else {
          _userModel = null;
          _lastUserModelUpdate = null;
        }

        notifyListeners();
      } catch (e) {
        debugPrint('Error en authStateChanges: $e');
        _setError('Error al cargar datos del usuario');
      }
    });

    // Inicializar Google Sign-In
    _initializeGoogleSignIn();
  }

  // Método para cargar el modelo de usuario con cache
  Future<void> _loadUserModelWithCache() async {
    try {
      debugPrint('DEBUG AuthService: Iniciando _loadUserModelWithCache()');

      // Verificar si el cache es válido
      if (_userModel != null &&
          _lastUserModelUpdate != null &&
          DateTime.now().difference(_lastUserModelUpdate!) < _cacheTimeout) {
        debugPrint('DEBUG AuthService: Usando cache válido');
        return; // Usar cache
      }

      debugPrint(
        'DEBUG AuthService: Cache no válido, cargando desde UserService...',
      );

      // Cargar desde Firestore
      _userModel = await UserService.getCurrentUser();
      _lastUserModelUpdate = DateTime.now();

      if (_userModel != null) {
        debugPrint(
          'DEBUG AuthService: UserModel cargado exitosamente: ${_userModel!.name}',
        );
      } else {
        debugPrint('DEBUG AuthService: UserModel es null después de la carga');
      }

      // Notificar a los listeners después de cargar
      notifyListeners();
    } catch (e) {
      debugPrint('DEBUG AuthService: ERROR al cargar modelo de usuario: $e');
      debugPrint('DEBUG AuthService: Stack trace: ${StackTrace.current}');

      // Establecer userModel como null en caso de error
      _userModel = null;
      _lastUserModelUpdate = null;

      // Notificar a los listeners del error
      notifyListeners();
    }
  }

  // Método para invalidar cache
  void invalidateUserCache() {
    _lastUserModelUpdate = null;
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      if (kIsWeb) {
        const String clientId = String.fromEnvironment(
          'GOOGLE_CLIENT_ID',
          defaultValue: '',
        );
        const String serverClientId = String.fromEnvironment(
          'GOOGLE_SERVER_CLIENT_ID',
          defaultValue: '',
        );

        if (clientId.isEmpty) {
          debugPrint(
            'Error initializing Google Sign-In: ClientID no configurado para web. '
            'Proporcione GOOGLE_CLIENT_ID con --dart-define o añada la meta tag en web/index.html.',
          );
          return;
        }

        await _googleSignIn.initialize(
          clientId: clientId,
          serverClientId: serverClientId.isEmpty ? null : serverClientId,
        );
      } else {
        await _googleSignIn.initialize();
      }
    } catch (e) {
      debugPrint('Error initializing Google Sign-In: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Método de login original (mantener compatibilidad)
  Future<bool> login() async {
    return await signInWithEmailAndPassword('demo@example.com', 'password');
  }

  // Registro con email y contraseña (método original para compatibilidad)
  Future<bool> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await registerUser(
      email: email,
      password: password,
      name: email.split('@')[0], // Usar parte del email como nombre por defecto
      userType: UserType.normal, // Tipo normal por defecto
    );
  }

  // Registro completo con tipo de usuario
  Future<bool> registerUser({
    required String email,
    required String password,
    required String name,
    required UserType userType,
    String? profileImageUrl,
    // Campos específicos para negocios
    String? businessName,
    String? businessCategory,
    String? businessDescription,
    String? businessAddress,
    double? businessLatitude,
    double? businessLongitude,
  }) async {
    try {
      debugPrint('DEBUG: Iniciando registro para $email con tipo $userType');
      _setLoading(true);
      _setError(null);

      // Validaciones de entrada
      final emailError = AuthValidation.validateEmail(email);
      if (emailError != null) {
        _setError(emailError);
        return false;
      }

      final passwordError = AuthValidation.validatePassword(password);
      if (passwordError != null) {
        _setError(passwordError);
        return false;
      }

      final nameError = AuthValidation.validateName(name);
      if (nameError != null) {
        _setError(nameError);
        return false;
      }

      // Validaciones específicas para negocios
      if (userType == UserType.business) {
        final businessNameError = AuthValidation.validateBusinessName(
          businessName,
        );
        if (businessNameError != null) {
          _setError(businessNameError);
          return false;
        }

        if (businessCategory == null || businessCategory.trim().isEmpty) {
          _setError('La categoría del negocio es requerida');
          return false;
        }
      }

      // Crear cuenta en Firebase Auth
      debugPrint('DEBUG: Creando cuenta en Firebase Auth');
      UserCredential result = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Timeout al crear cuenta en Firebase Auth');
            },
          );

      debugPrint('DEBUG: Cuenta creada en Firebase Auth');
      _currentUser = result.user;

      if (_currentUser != null) {
        // Crear perfil de usuario en Firestore
        debugPrint('DEBUG: Creando perfil en Firestore');

        // Construir el modelo de usuario
        final newUser = UserModel(
          id: _currentUser!.uid,
          name: name,
          email: email,
          profileImageUrl: profileImageUrl,
          userType: userType,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          businessProfile:
              userType == UserType.business
                  ? BusinessProfile(
                    businessName: businessName,
                    businessCategory: businessCategory,
                    businessDescription: businessDescription,
                    businessAddress: businessAddress,
                    businessLatitude: businessLatitude,
                    businessLongitude: businessLongitude,
                    businessImages: [],
                    businessRating: 0.0,
                    businessReviewCount: 0,
                  )
                  : null,
          userProfile:
              userType == UserType.normal
                  ? const UserProfile(
                    favoriteBusinesses: [],
                    writtenReviews: [],
                  )
                  : null,
        );

        bool userCreated = await UserService.saveUser(newUser);

        debugPrint('DEBUG: Resultado creación perfil: $userCreated');
        if (userCreated) {
          // Cargar el modelo de usuario creado
          debugPrint('DEBUG: Cargando modelo de usuario');
          _userModel = await UserService.getCurrentUser();
          debugPrint('DEBUG: Modelo cargado: ${_userModel?.name}');
          _isAuthenticated = true;
          debugPrint('DEBUG: Registro completado exitosamente');
          return true;
        } else {
          // Si falla la creación del perfil, eliminar la cuenta de Auth
          debugPrint('DEBUG: Error en creación de perfil, eliminando cuenta');
          await _currentUser!.delete();
          _currentUser = null;
          _setError('Error al crear el perfil de usuario');
          return false;
        }
      }

      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login con email y contraseña
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      // Validaciones de entrada
      final emailError = AuthValidation.validateEmail(email);
      if (emailError != null) {
        _setError(emailError);
        return false;
      }

      final passwordError = AuthValidation.validatePassword(password);
      if (passwordError != null) {
        _setError(passwordError);
        return false;
      }

      UserCredential result = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Tiempo de espera agotado. Verifica tu conexión a internet.',
              );
            },
          );

      _currentUser = result.user;
      _isAuthenticated = _currentUser != null;
      return _isAuthenticated;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login con Google - API actualizada para v7
  Future<bool> signInWithGoogle({UserType? userType}) async {
    try {
      _setLoading(true);
      _setError(null);

      if (kIsWeb) {
        const String clientId = String.fromEnvironment(
          'GOOGLE_CLIENT_ID',
          defaultValue: '',
        );
        if (clientId.isEmpty) {
          _setError(
            'Google Sign-In en web requiere configurar GOOGLE_CLIENT_ID.',
          );
          return false;
        }
      }

      // Verificar si la plataforma soporta autenticación
      if (_googleSignIn.supportsAuthenticate()) {
        final GoogleSignInAccount googleUser =
            await _googleSignIn.authenticate();

        // Obtener las credenciales de autenticación
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        // Crear credencial de Firebase solo con idToken
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        // Iniciar sesión en Firebase
        UserCredential result = await _auth.signInWithCredential(credential);

        _currentUser = result.user;

        if (_currentUser != null) {
          // Verificar si el usuario ya existe en Firestore
          _userModel = await UserService.getCurrentUser();

          if (_userModel == null && userType != null) {
            // Usuario nuevo, crear perfil
            final newUser = UserModel(
              id: _currentUser!.uid,
              name: _currentUser!.displayName ?? 'Usuario',
              email: _currentUser!.email!,
              profileImageUrl: _currentUser!.photoURL,
              userType: userType,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              businessProfile:
                  userType == UserType.business
                      ? const BusinessProfile(
                        businessImages: [],
                        businessRating: 0.0,
                        businessReviewCount: 0,
                      )
                      : null,
              userProfile:
                  userType == UserType.normal
                      ? const UserProfile(
                        favoriteBusinesses: [],
                        writtenReviews: [],
                      )
                      : null,
            );

            bool userCreated = await UserService.saveUser(newUser);

            if (userCreated) {
              _userModel = await UserService.getCurrentUser();
            }
          }

          _isAuthenticated = true;
          return true;
        }

        return false;
      } else {
        _setError('Google Sign-In no está soportado en esta plataforma');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Error con Google Sign-In: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Recuperación de contraseña
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _setLoading(true);
      _setError(null);

      // Cerrar sesión en Google si está conectado
      if (_googleSignIn.supportsAuthenticate()) {
        await _googleSignIn.signOut();
      }

      // Cerrar sesión en Firebase
      await _auth.signOut();

      _currentUser = null;
      _userModel = null;
      _isAuthenticated = false;

      // Notificar a los listeners del cambio de estado
      notifyListeners();
    } catch (e) {
      _setError('Error al cerrar sesión: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar modelo de usuario local
  void updateUserModel(UserModel userModel) {
    _userModel = userModel;
    notifyListeners();
  }

  // Desconectar completamente (revocar permisos)
  Future<void> disconnect() async {
    try {
      _setLoading(true);
      _setError(null);

      // Desconectar Google
      if (_googleSignIn.supportsAuthenticate()) {
        await _googleSignIn.disconnect();
      }

      // Cerrar sesión en Firebase
      await _auth.signOut();

      _currentUser = null;
      _userModel = null;
      _isAuthenticated = false;

      // Notificar a los listeners del cambio de estado
      notifyListeners();
    } catch (e) {
      _setError('Error al desconectar: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Obtener mensajes de error legibles
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontró una cuenta con este email.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este email.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El formato del email no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada temporalmente.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta de nuevo en unos minutos.';
      case 'operation-not-allowed':
        return 'Esta operación no está permitida. Contacta al soporte.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet e intenta de nuevo.';
      case 'invalid-credential':
        return 'Las credenciales proporcionadas no son válidas.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con este email usando un método diferente.';
      case 'requires-recent-login':
        return 'Por seguridad, necesitas iniciar sesión de nuevo.';
      case 'credential-already-in-use':
        return 'Estas credenciales ya están siendo usadas por otra cuenta.';
      case 'invalid-verification-code':
        return 'El código de verificación no es válido.';
      case 'invalid-verification-id':
        return 'El ID de verificación no es válido.';
      case 'session-cookie-expired':
        return 'Tu sesión ha expirado. Inicia sesión de nuevo.';
      case 'quota-exceeded':
        return 'Se ha excedido el límite de solicitudes. Intenta más tarde.';
      default:
        return 'Error de autenticación: ${e.message ?? 'Error desconocido'}';
    }
  }

  // Limpiar errores
  void clearError() {
    _setError(null);
  }
}

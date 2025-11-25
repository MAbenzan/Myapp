import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream del estado de autenticación
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map((User? user) {
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    });
  }

  // Usuario actual
  UserModel? get currentUser {
    final user = _auth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  // Registro con email y password
  Future<UserModel?> signUpWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Login con email y password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Login con Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Usuario canceló

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return UserModel.fromFirebaseUser(userCredential.user!);
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw _handleAuthException(e);
      }
      throw 'Error al iniciar sesión con Google: $e';
    }
  }

  // Logout
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  // Manejo de errores
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}

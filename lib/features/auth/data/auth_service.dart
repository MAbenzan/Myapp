import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/user_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../business/domain/business_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream del estado de autenticación
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) return null;

      // Intentar obtener datos extra de Firestore
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromJson(doc.data()!);
        }
      } catch (e) {
        // Si falla, retornar usuario básico
      }

      return UserModel.fromFirebaseUser(user);
    });
  }

  // Usuario actual
  Future<UserModel?> get currentUser async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
    } catch (e) {
      // Si falla, retornar usuario básico
    }
    return UserModel.fromFirebaseUser(user);
  }

  // Registro con email y password
  Future<UserModel?> signUpWithEmail(
    String email,
    String password, {
    UserType userType = UserType.client,
    String? businessName,
  }) async {
    try {
      // 1. Crear usuario en Auth
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String? businessId;

      // 2. Si es negocio, crear documento de negocio
      if (userType == UserType.business) {
        if (businessName == null || businessName.isEmpty) {
          throw 'El nombre del negocio es requerido';
        }

        final businessRef = _firestore.collection('businesses').doc();
        businessId = businessRef.id;

        final newBusiness = BusinessModel(
          id: businessId,
          name: businessName,
          description: '',
          imageUrl: '',
          rating: 0,
          reviewCount: 0,
          category: 'Restaurante', // Default, luego se edita
          address: '',
          isOpen: false,
          distance: 0,
          isPublished: false, // Importante: No publicado aún
        );

        // Convertir BusinessModel a Map (necesitamos agregar toJson a BusinessModel o hacerlo manual)
        // Por ahora manual para asegurar los campos
        await businessRef.set({
          'id': newBusiness.id,
          'name': newBusiness.name,
          'description': newBusiness.description,
          'imageUrl': newBusiness.imageUrl,
          'rating': newBusiness.rating,
          'reviewCount': newBusiness.reviewCount,
          'category': newBusiness.category,
          'address': newBusiness.address,
          'isOpen': newBusiness.isOpen,
          'distance': newBusiness.distance,
          'isPublished': newBusiness.isPublished,
          'profileCompleteness': 0,
        });
      }

      // 3. Crear documento de usuario en Firestore
      final newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        userType: userType,
        businessId: businessId,
        displayName:
            businessName, // Usar nombre de negocio como display name inicial si es negocio
      );

      await _firestore
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toJson());

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error en el registro: $e';
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

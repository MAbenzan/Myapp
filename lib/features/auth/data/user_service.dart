import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/user_model.dart';
import '../../business/domain/business_model.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Guardar usuario en Firestore (sin await para no bloquear)
  static Future<bool> saveUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toJson())
          .timeout(const Duration(seconds: 10));
      return true;
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  // Guardar negocio en Firestore
  static Future<bool> saveBusiness(BusinessModel business) async {
    try {
      await _firestore
          .collection('businesses')
          .doc(business.id)
          .set({
            'id': business.id,
            'name': business.name,
            'description': business.description,
            'imageUrl': business.imageUrl,
            'rating': business.rating,
            'reviewCount': business.reviewCount,
            'category': business.category,
            'address': business.address,
            'isOpen': business.isOpen,
            'distance': business.distance,
            'isPublished': business.isPublished,
            'profileCompleteness': 0,
            'menu': [],
            'services': [],
            'gallery': [],
            'reviews': [],
          })
          .timeout(const Duration(seconds: 10));
      return true;
    } catch (e) {
      print('Error saving business: $e');
      return false;
    }
  }

  // Obtener usuario actual
  static Future<UserModel?> getCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
}

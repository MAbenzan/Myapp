import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/domain/user_model.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Toggle favorite status
  Future<void> toggleFavorite(String userId, String businessId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final userDoc = await userRef.get();

    if (!userDoc.exists) return;

    final user = UserModel.fromJson(userDoc.data()!);
    final favorites = List<String>.from(user.favorites);

    if (favorites.contains(businessId)) {
      favorites.remove(businessId);
    } else {
      favorites.add(businessId);
    }

    await userRef.update({'favorites': favorites});
  }

  // Get user favorites stream
  Stream<List<String>> getUserFavoritesStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) return [];
      final user = UserModel.fromJson(snapshot.data()!);
      return user.favorites;
    });
  }
}

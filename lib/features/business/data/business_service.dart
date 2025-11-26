import 'package:cloud_firestore/cloud_firestore.dart';
import '../../business/domain/business_model.dart';

class BusinessService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get business by ID
  Stream<BusinessModel> getBusinessStream(String businessId) {
    return _firestore.collection('businesses').doc(businessId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) {
        throw Exception('Negocio no encontrado');
      }
      return BusinessModel.fromJson(snapshot.data()!);
    });
  }

  // --- Menu Management ---

  // Add Menu Item
  Future<void> addMenuItem(String businessId, MenuItem item) async {
    final businessRef = _firestore.collection('businesses').doc(businessId);

    await businessRef.update({
      'menu': FieldValue.arrayUnion([item.toJson()]),
    });
  }

  // Update Menu Item
  Future<void> updateMenuItem(
    String businessId,
    MenuItem oldItem,
    MenuItem newItem,
  ) async {
    final businessRef = _firestore.collection('businesses').doc(businessId);

    final batch = _firestore.batch();

    batch.update(businessRef, {
      'menu': FieldValue.arrayRemove([oldItem.toJson()]),
    });

    batch.update(businessRef, {
      'menu': FieldValue.arrayUnion([newItem.toJson()]),
    });

    await batch.commit();
  }

  // Delete Menu Item
  Future<void> deleteMenuItem(String businessId, MenuItem item) async {
    final businessRef = _firestore.collection('businesses').doc(businessId);

    await businessRef.update({
      'menu': FieldValue.arrayRemove([item.toJson()]),
    });
  }

  // --- Services Management ---

  // Add Service Item
  Future<void> addServiceItem(String businessId, ServiceItem item) async {
    final businessRef = _firestore.collection('businesses').doc(businessId);

    await businessRef.update({
      'services': FieldValue.arrayUnion([item.toJson()]),
    });
  }

  // Update Service Item
  Future<void> updateServiceItem(
    String businessId,
    ServiceItem oldItem,
    ServiceItem newItem,
  ) async {
    final businessRef = _firestore.collection('businesses').doc(businessId);

    final batch = _firestore.batch();

    batch.update(businessRef, {
      'services': FieldValue.arrayRemove([oldItem.toJson()]),
    });

    batch.update(businessRef, {
      'services': FieldValue.arrayUnion([newItem.toJson()]),
    });

    await batch.commit();
  }

  // Delete Service Item
  Future<void> deleteServiceItem(String businessId, ServiceItem item) async {
    final businessRef = _firestore.collection('businesses').doc(businessId);

    await businessRef.update({
      'services': FieldValue.arrayRemove([item.toJson()]),
    });
  }

  // --- Gallery Management ---

  // Add Gallery Image
  Future<void> addGalleryImage(String businessId, String imageUrl) async {
    final businessRef = _firestore.collection('businesses').doc(businessId);

    await businessRef.update({
      'gallery': FieldValue.arrayUnion([imageUrl]),
    });
  }

  // Remove Gallery Image
  Future<void> removeGalleryImage(String businessId, String imageUrl) async {
    final businessRef = _firestore.collection('businesses').doc(businessId);

    await businessRef.update({
      'gallery': FieldValue.arrayRemove([imageUrl]),
    });
  }

  // Update Business Profile Info
  Future<void> updateBusinessProfile(
    String businessId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('businesses').doc(businessId).update(data);
  }
}

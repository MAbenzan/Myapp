enum UserType { client, business }

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final UserType userType;
  final String? businessId; // Solo para usuarios tipo 'business'
  final List<String> favorites; // IDs de negocios favoritos
  final String? description; // Descripción del usuario

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.userType = UserType.client,
    this.businessId,
    this.favorites = const [],
    this.description,
  });

  bool get isBusinessOwner => userType == UserType.business;

  // Factory constructor para crear desde Firebase User
  factory UserModel.fromFirebaseUser(
    dynamic firebaseUser, {
    UserType userType = UserType.client,
    String? businessId,
    List<String> favorites = const [],
    String? description,
  }) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      userType: userType,
      businessId: businessId,
      favorites: favorites,
      description: description,
    );
  }

  // Serialización a JSON (para Firestore)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'userType': userType.name,
      'businessId': businessId,
      'favorites': favorites,
      'description': description,
    };
  }

  // Deserialización desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      userType: json['userType'] == 'business'
          ? UserType.business
          : UserType.client,
      businessId: json['businessId'],
      favorites:
          (json['favorites'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      description: json['description'],
    );
  }
}

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String role; // 'user' o 'business'

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.role = 'user',
  });

  // Factory constructor para crear desde Firebase User
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
    );
  }

  // Serialización a JSON (para Firestore)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role,
    };
  }

  // Deserialización desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      role: json['role'] ?? 'user',
    );
  }
}

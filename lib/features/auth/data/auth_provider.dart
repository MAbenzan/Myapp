import 'package:flutter/material.dart';
import '../data/auth_service.dart';
import '../domain/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}

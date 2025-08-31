import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      _currentUser = await _authService.getUserProfile(uid);
      notifyListeners();
    } catch (e) {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        _currentUser = AppUser(
          uid: firebaseUser.uid,
          displayName: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          photoURL: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    String? gender,
    DateTime? dateOfBirth,
    double? height,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
        gender: gender,
        dateOfBirth: dateOfBirth,
        height: height,
      );
      
      if (userCredential?.user != null) {
        await _loadUserProfile(userCredential!.user!.uid);
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _setLoading(false);
    return false;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential?.user != null) {
        await _loadUserProfile(userCredential!.user!.uid);
        _setLoading(false);
        return true;
      }
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('Exception: ')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }
      
      _errorMessage = errorMessage;
    }
    
    _setLoading(false);
    return false;
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential?.user != null) {
        await _loadUserProfile(userCredential!.user!.uid);
        _setLoading(false);
        return true;
      } else {
        _setLoading(false);
        return false;
      }
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('Exception: ')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }
      
      _errorMessage = errorMessage;
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<bool> updateProfile({
    String? displayName,
    String? gender,
    DateTime? dateOfBirth,
    double? height,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = _currentUser!.copyWith(
        displayName: displayName,
        gender: gender,
        dateOfBirth: dateOfBirth,
        height: height,
      );

      await _authService.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> checkAuthState() async {
    return await _authService.isLoggedIn();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
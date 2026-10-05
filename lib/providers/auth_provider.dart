import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class User {
  final String uid;
  final String name;
  final String email;

  User({
    required this.uid,
    required this.name,
    required this.email,
  });
}

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'Please fill in all fields';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!email.contains('@')) {
        _errorMessage = 'Invalid email format';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Firebase login
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = User(
        uid: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? email.split('@')[0],
        email: userCredential.user!.email ?? email,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e.code);
      print('Firebase Auth Error - Code: ${e.code}, Message: ${e.message}');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      print('Login Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        _errorMessage = 'Please fill in all fields';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!email.contains('@')) {
        _errorMessage = 'Invalid email format';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'Password must be at least 6 characters';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Firebase signup
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      _currentUser = User(
        uid: userCredential.user!.uid,
        name: name,
        email: userCredential.user!.email ?? email,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e.code);
      print('Firebase Auth Error - Code: ${e.code}, Message: ${e.message}');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Signup failed: ${e.toString()}';
      print('Signup Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'too-many-requests':
        return 'Too many login attempts. Try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'unknown':
        return 'Unknown error. Please check your Firebase configuration';
      default:
        return 'Firebase error: $code';
    }
  }
}

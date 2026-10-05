import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final Map<String, dynamic> preferences;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.preferences = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'preferences': preferences,
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      preferences: map['preferences'] as Map<String, dynamic>? ?? {},
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
    );
  }
}

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userId => _currentUser?.uid;

  // Initialize user from Firebase Auth
  Future<void> initializeUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fbUser = _auth.currentUser;
      if (fbUser != null) {
        await _loadUserFromFirestore(fbUser.uid);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize user: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user data from Firestore
  Future<void> _loadUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        // Create new user document
        final fbUser = _auth.currentUser;
        if (fbUser != null) {
          _currentUser = UserModel(
            uid: uid,
            name: fbUser.displayName ?? 'User',
            email: fbUser.email ?? '',
            createdAt: DateTime.now(),
          );
          await _saveUserToFirestore(_currentUser!);
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load user: ${e.toString()}';
      rethrow;
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserToFirestore(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(
            user.toMap(),
            SetOptions(merge: true),
          );
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save user: ${e.toString()}';
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String name,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_currentUser == null) {
        throw Exception('No user logged in');
      }

      final updatedUser = _currentUser!.copyWith(
        name: name,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
      );

      await _saveUserToFirestore(updatedUser);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update user preferences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      if (_currentUser == null) {
        throw Exception('No user logged in');
      }

      final updatedPrefs = {..._currentUser!.preferences, ...preferences};
      final updatedUser = _currentUser!.copyWith(preferences: updatedPrefs);

      await _saveUserToFirestore(updatedUser);
    } catch (e) {
      _errorMessage = 'Failed to update preferences: ${e.toString()}';
      rethrow;
    }
  }

  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}

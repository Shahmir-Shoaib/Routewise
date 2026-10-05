import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle_model.dart';

class VehiclesProvider extends ChangeNotifier {
  List<Vehicle> _userVehicles = [];
  Vehicle? _selectedVehicle;
  bool _isLoading = false;
  String? _errorMessage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Vehicle> get userVehicles => _userVehicles;
  Vehicle? get selectedVehicle => _selectedVehicle;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load user's vehicles from Firestore
  Future<void> loadUserVehicles(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .get();

      _userVehicles =
          snapshot.docs.map((doc) => Vehicle.fromMap(doc.data())).toList();

      if (_userVehicles.isNotEmpty) {
        _selectedVehicle = _userVehicles[0];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load vehicles: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Add a new vehicle
  Future<void> addVehicle(Vehicle vehicle, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicle.id);

      await docRef.set(vehicle.toMap());

      _userVehicles.add(vehicle);
      _selectedVehicle ??= vehicle;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add vehicle: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update vehicle
  Future<void> updateVehicle(Vehicle vehicle, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicle.id)
          .update(vehicle.toMap());

      final index = _userVehicles.indexWhere((v) => v.id == vehicle.id);
      if (index != -1) {
        _userVehicles[index] = vehicle;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update vehicle: ${e.toString()}';
      rethrow;
    }
  }

  // Delete vehicle
  Future<void> deleteVehicle(String vehicleId, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .delete();

      _userVehicles.removeWhere((v) => v.id == vehicleId);

      if (_selectedVehicle?.id == vehicleId) {
        _selectedVehicle = _userVehicles.isNotEmpty ? _userVehicles[0] : null;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete vehicle: ${e.toString()}';
      rethrow;
    }
  }

  // Select a vehicle
  void selectVehicle(Vehicle vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  // Get vehicle by ID
  Vehicle? getVehicleById(String vehicleId) {
    try {
      return _userVehicles.firstWhere((v) => v.id == vehicleId);
    } catch (e) {
      return null;
    }
  }
}

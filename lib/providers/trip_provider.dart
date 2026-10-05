import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle_model.dart';

class TripProvider with ChangeNotifier {
  Vehicle? _selectedVehicle;
  double _fuelAverage = 0.0;
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Vehicle? get selectedVehicle => _selectedVehicle;
  double get fuelAverage => _fuelAverage;
  bool get isLoading => _isLoading;

  void selectVehicle(Vehicle vehicle) {
    _selectedVehicle = vehicle;
    _fuelAverage = vehicle.defaultAverage;
    notifyListeners();
  }

  void setSelectedVehicle(String vehicleName) {
    _selectedVehicle = Vehicle(
      name: vehicleName,
      defaultAverage: _fuelAverage,
    );
    notifyListeners();
  }

  void setFuelAverage(double value) {
    _fuelAverage = value;
    notifyListeners();
  }

  void updateFuelAverage(double value) {
    _fuelAverage = value;
    notifyListeners();
  }

  Future<void> saveTrip(Map<String, dynamic> tripData, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Add timestamp to trip data
      tripData['createdAt'] = FieldValue.serverTimestamp();
      tripData['userId'] = userId;

      // Save to Firestore
      await _firestore.collection('trips').add(tripData);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserTrips(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await _firestore.collection('trips').doc(tripId).delete();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}

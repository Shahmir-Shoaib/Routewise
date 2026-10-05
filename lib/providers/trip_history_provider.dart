import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompletedTrip {
  final String id;
  final String source;
  final String destination;
  final String vehicleName;
  final double distance;
  final double estimatedTime; // in hours
  final double actualTime; // in hours
  final double estimatedCost; // fuel + toll
  final double actualCost; // fuel + toll
  final DateTime startTime;
  final DateTime endTime;
  final double averageSpeed;
  final int stopsCount;
  final String notes;

  CompletedTrip({
    required this.id,
    required this.source,
    required this.destination,
    required this.vehicleName,
    required this.distance,
    required this.estimatedTime,
    required this.actualTime,
    required this.estimatedCost,
    required this.actualCost,
    required this.startTime,
    required this.endTime,
    required this.averageSpeed,
    this.stopsCount = 0,
    this.notes = '',
  });

  // Getters for analysis
  double get timeSavings => estimatedTime - actualTime;
  double get costSavings => estimatedCost - actualCost;
  double get timeSavingsPercentage =>
      (timeSavings / estimatedTime * 100).clamp(-100, 100);
  double get costSavingsPercentage =>
      (costSavings / estimatedCost * 100).clamp(-100, 100);
  bool get wasFaster => actualTime < estimatedTime;
  bool get wasCheaper => actualCost < estimatedCost;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source': source,
      'destination': destination,
      'vehicleName': vehicleName,
      'distance': distance,
      'estimatedTime': estimatedTime,
      'actualTime': actualTime,
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'averageSpeed': averageSpeed,
      'stopsCount': stopsCount,
      'notes': notes,
    };
  }

  static CompletedTrip fromMap(Map<String, dynamic> map) {
    return CompletedTrip(
      id: map['id'] as String,
      source: map['source'] as String,
      destination: map['destination'] as String,
      vehicleName: map['vehicleName'] as String,
      distance: map['distance'] as double,
      estimatedTime: map['estimatedTime'] as double,
      actualTime: map['actualTime'] as double,
      estimatedCost: map['estimatedCost'] as double,
      actualCost: map['actualCost'] as double,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      averageSpeed: map['averageSpeed'] as double,
      stopsCount: map['stopsCount'] as int? ?? 0,
      notes: map['notes'] as String? ?? '',
    );
  }
}

class TripHistoryProvider extends ChangeNotifier {
  List<CompletedTrip> _trips = [];
  bool _isLoading = false;
  String? _errorMessage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters
  List<CompletedTrip> get trips => List.unmodifiable(_trips);
  int get tripCount => _trips.length;
  bool get hasTrips => _trips.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Sorting and filtering
  List<CompletedTrip> _filtered = [];
  bool get hasFilteredTrips => _filtered.isNotEmpty;
  List<CompletedTrip> get filteredTrips => List.unmodifiable(_filtered);

  // Statistics
  double _totalDistance = 0;
  double _totalTime = 0; // in hours
  double _totalCost = 0;
  double _averageSpeed = 0;
  int _totalStops = 0;

  double get totalDistance => _totalDistance;
  double get totalTime => _totalTime;
  double get totalCost => _totalCost;
  double get averageSpeed => _averageSpeed;
  int get totalStops => _totalStops;

  /// Load completed trips from Firestore
  Future<void> loadTripsFromFirestore(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('completedTrips')
          .orderBy('startTime', descending: true)
          .get();

      _trips = snapshot.docs
          .map((doc) => CompletedTrip.fromMap(doc.data()))
          .toList();

      _updateStatistics();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load trips: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Add a completed trip to Firestore
  Future<void> addTrip(CompletedTrip trip, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('completedTrips')
          .doc(trip.id)
          .set(trip.toMap());

      _trips.insert(0, trip);
      _updateStatistics();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add trip: ${e.toString()}';
      rethrow;
    }
  }

  /// Remove a trip from Firestore
  Future<void> removeTrip(String tripId, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('completedTrips')
          .doc(tripId)
          .delete();

      _trips.removeWhere((trip) => trip.id == tripId);
      _updateStatistics();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to remove trip: ${e.toString()}';
      rethrow;
    }
  }

  /// Clear all trip history from Firestore
  Future<void> clearHistory(String userId) async {
    try {
      final batch = _firestore.batch();
      for (var trip in _trips) {
        batch.delete(
          _firestore
              .collection('users')
              .doc(userId)
              .collection('completedTrips')
              .doc(trip.id),
        );
      }
      await batch.commit();

      _trips.clear();
      _filtered.clear();
      _updateStatistics();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to clear history: ${e.toString()}';
      rethrow;
    }
  }

  /// Get trip by ID
  CompletedTrip? getTripById(String tripId) {
    try {
      return _trips.firstWhere((trip) => trip.id == tripId);
    } catch (e) {
      return null;
    }
  }

  /// Get trips by vehicle name
  List<CompletedTrip> getTripsByVehicle(String vehicleName) {
    return _trips.where((trip) => trip.vehicleName == vehicleName).toList();
  }

  /// Get trips by date range
  List<CompletedTrip> getTripsByDateRange(DateTime start, DateTime end) {
    return _trips
        .where((trip) =>
            trip.startTime.isAfter(start) && trip.startTime.isBefore(end))
        .toList();
  }

  /// Filter trips by criteria
  void filterTrips({
    String? vehicleName,
    DateTime? startDate,
    DateTime? endDate,
    double? minDistance,
    double? maxDistance,
  }) {
    _filtered = _trips.where((trip) {
      // Vehicle filter
      if (vehicleName != null && trip.vehicleName != vehicleName) return false;

      // Date range filter
      if (startDate != null && trip.startTime.isBefore(startDate)) return false;
      if (endDate != null && trip.startTime.isAfter(endDate)) return false;

      // Distance filters
      if (minDistance != null && trip.distance < minDistance) return false;
      if (maxDistance != null && trip.distance > maxDistance) return false;

      return true;
    }).toList();

    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _filtered = List.from(_trips);
    notifyListeners();
  }

  /// Sort trips
  void sortTrips(String sortBy) {
    switch (sortBy) {
      case 'date_asc':
        _trips.sort((a, b) => a.startTime.compareTo(b.startTime));
        break;
      case 'date_desc':
        _trips.sort((a, b) => b.startTime.compareTo(a.startTime));
        break;
      case 'distance_asc':
        _trips.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case 'distance_desc':
        _trips.sort((a, b) => b.distance.compareTo(a.distance));
        break;
      case 'cost_asc':
        _trips.sort((a, b) => a.actualCost.compareTo(b.actualCost));
        break;
      case 'cost_desc':
        _trips.sort((a, b) => b.actualCost.compareTo(a.actualCost));
        break;
      case 'time_saved':
        _trips.sort((a, b) => b.timeSavings.compareTo(a.timeSavings));
        break;
      case 'cost_saved':
        _trips.sort((a, b) => b.costSavings.compareTo(a.costSavings));
        break;
    }
    notifyListeners();
  }

  /// Get best trips by criteria
  CompletedTrip? getFastestTrip() {
    if (_trips.isEmpty) return null;
    return _trips.reduce((a, b) => a.averageSpeed > b.averageSpeed ? a : b);
  }

  CompletedTrip? getCheapestTrip() {
    if (_trips.isEmpty) return null;
    return _trips.reduce((a, b) => a.actualCost < b.actualCost ? a : b);
  }

  CompletedTrip? getMostEconomicalTrip() {
    if (_trips.isEmpty) return null;
    // Most economical = lowest cost per km
    return _trips.reduce((a, b) {
      double costPerKmA = a.actualCost / a.distance;
      double costPerKmB = b.actualCost / b.distance;
      return costPerKmA < costPerKmB ? a : b;
    });
  }

  /// Get average metrics
  double getAverageDistance() {
    if (_trips.isEmpty) return 0;
    return _totalDistance / _trips.length;
  }

  double getAverageTime() {
    if (_trips.isEmpty) return 0;
    return _totalTime / _trips.length;
  }

  double getAverageCost() {
    if (_trips.isEmpty) return 0;
    return _totalCost / _trips.length;
  }

  double getAverageSpeedValue() {
    if (_trips.isEmpty) return 0;
    return _trips.fold(0.0, (sum, trip) => sum + trip.averageSpeed) /
        _trips.length;
  }

  /// Calculate total savings
  double getTotalTimeSavings() {
    return _trips.fold(0, (sum, trip) => sum + trip.timeSavings);
  }

  double getTotalCostSavings() {
    return _trips.fold(0, (sum, trip) => sum + trip.costSavings);
  }

  /// Get trips for last N days
  List<CompletedTrip> getRecentTrips(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _trips.where((trip) => trip.startTime.isAfter(cutoffDate)).toList();
  }

  /// Update statistics
  void _updateStatistics() {
    _totalDistance = _trips.fold(0, (sum, trip) => sum + trip.distance);
    _totalTime = _trips.fold(0, (sum, trip) => sum + trip.actualTime);
    _totalCost = _trips.fold(0, (sum, trip) => sum + trip.actualCost);
    _totalStops = _trips.fold(0, (sum, trip) => sum + trip.stopsCount);

    if (_trips.isNotEmpty) {
      _averageSpeed = _trips.fold(0.0, (sum, trip) => sum + trip.averageSpeed) /
          _trips.length;
    } else {
      _averageSpeed = 0;
    }
  }

  /// Load trips from storage (mock implementation - kept for backward compatibility)
  Future<void> loadTripsFromStorage() async {
    // Deprecated: use loadTripsFromFirestore instead
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Save trips to storage (mock implementation - kept for backward compatibility)
  Future<void> saveTripsToStorage() async {
    // Deprecated: trips are now auto-saved to Firestore
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Export trip data as JSON
  List<Map<String, dynamic>> exportAsJson() {
    return _trips.map((trip) => trip.toMap()).toList();
  }
}

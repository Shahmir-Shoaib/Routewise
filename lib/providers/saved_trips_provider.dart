import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavedTrip {
  final String id;
  final String name;
  final String source;
  final String destination;
  final String preferredVehicle;
  final DateTime savedDate;
  final int timesUsed;
  final String notes;
  final bool isFavorite;

  SavedTrip({
    required this.id,
    required this.name,
    required this.source,
    required this.destination,
    required this.preferredVehicle,
    required this.savedDate,
    this.timesUsed = 0,
    this.notes = '',
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'source': source,
      'destination': destination,
      'preferredVehicle': preferredVehicle,
      'savedDate': savedDate.toIso8601String(),
      'timesUsed': timesUsed,
      'notes': notes,
      'isFavorite': isFavorite,
    };
  }

  static SavedTrip fromMap(Map<String, dynamic> map) {
    return SavedTrip(
      id: map['id'] as String,
      name: map['name'] as String,
      source: map['source'] as String,
      destination: map['destination'] as String,
      preferredVehicle: map['preferredVehicle'] as String,
      savedDate: DateTime.parse(map['savedDate'] as String),
      timesUsed: map['timesUsed'] as int? ?? 0,
      notes: map['notes'] as String? ?? '',
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }

  SavedTrip copyWith({
    String? id,
    String? name,
    String? source,
    String? destination,
    String? preferredVehicle,
    DateTime? savedDate,
    int? timesUsed,
    String? notes,
    bool? isFavorite,
  }) {
    return SavedTrip(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      preferredVehicle: preferredVehicle ?? this.preferredVehicle,
      savedDate: savedDate ?? this.savedDate,
      timesUsed: timesUsed ?? this.timesUsed,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class SavedTripsProvider extends ChangeNotifier {
  List<SavedTrip> _savedTrips = [];
  bool _isLoading = false;
  String? _errorMessage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters
  List<SavedTrip> get savedTrips => List.unmodifiable(_savedTrips);
  int get savedTripCount => _savedTrips.length;
  bool get hasSavedTrips => _savedTrips.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get all favorite trips
  List<SavedTrip> get favoriteTrips =>
      _savedTrips.where((trip) => trip.isFavorite).toList();

  bool get hasFavorites => favoriteTrips.isNotEmpty;

  /// Load saved trips from Firestore
  Future<void> loadTripsFromFirestore(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('savedTrips')
          .orderBy('savedDate', descending: true)
          .get();

      _savedTrips =
          snapshot.docs.map((doc) => SavedTrip.fromMap(doc.data())).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load trips: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Save a new trip to Firestore
  Future<SavedTrip> addSavedTrip({
    required String userId,
    required String name,
    required String source,
    required String destination,
    required String preferredVehicle,
    String notes = '',
  }) async {
    try {
      final trip = SavedTrip(
        id: 'saved_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        source: source,
        destination: destination,
        preferredVehicle: preferredVehicle,
        savedDate: DateTime.now(),
        timesUsed: 0,
        notes: notes,
        isFavorite: false,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('savedTrips')
          .doc(trip.id)
          .set(trip.toMap());

      _savedTrips.insert(0, trip);
      notifyListeners();
      return trip;
    } catch (e) {
      _errorMessage = 'Failed to save trip: ${e.toString()}';
      rethrow;
    }
  }

  /// Delete a saved trip from Firestore
  Future<void> deleteTrip(String tripId, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('savedTrips')
          .doc(tripId)
          .delete();

      _savedTrips.removeWhere((trip) => trip.id == tripId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete trip: ${e.toString()}';
      rethrow;
    }
  }

  /// Update a saved trip in Firestore
  Future<void> updateTrip(
    String tripId,
    String userId, {
    String? name,
    String? notes,
  }) async {
    try {
      final index = _savedTrips.indexWhere((trip) => trip.id == tripId);
      if (index != -1) {
        final updatedTrip = _savedTrips[index].copyWith(
          name: name,
          notes: notes,
        );

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('savedTrips')
            .doc(tripId)
            .update(updatedTrip.toMap());

        _savedTrips[index] = updatedTrip;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update trip: ${e.toString()}';
      rethrow;
    }
  }

  /// Toggle favorite status in Firestore
  Future<void> toggleFavorite(String tripId, String userId) async {
    try {
      final index = _savedTrips.indexWhere((trip) => trip.id == tripId);
      if (index != -1) {
        final updatedTrip = _savedTrips[index].copyWith(
          isFavorite: !_savedTrips[index].isFavorite,
        );

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('savedTrips')
            .doc(tripId)
            .update({'isFavorite': updatedTrip.isFavorite});

        _savedTrips[index] = updatedTrip;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to toggle favorite: ${e.toString()}';
      rethrow;
    }
  }

  /// Mark trip as used (increment counter) in Firestore
  Future<void> markAsUsed(String tripId, String userId) async {
    try {
      final index = _savedTrips.indexWhere((trip) => trip.id == tripId);
      if (index != -1) {
        final updatedTrip = _savedTrips[index].copyWith(
          timesUsed: _savedTrips[index].timesUsed + 1,
        );

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('savedTrips')
            .doc(tripId)
            .update({'timesUsed': updatedTrip.timesUsed});

        _savedTrips[index] = updatedTrip;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to mark as used: ${e.toString()}';
      rethrow;
    }
  }

  /// Get trip by ID
  SavedTrip? getTripById(String tripId) {
    try {
      return _savedTrips.firstWhere((trip) => trip.id == tripId);
    } catch (e) {
      return null;
    }
  }

  /// Get trips by source and destination
  List<SavedTrip> getTripsByRoute(String source, String destination) {
    return _savedTrips
        .where(
            (trip) => trip.source == source && trip.destination == destination)
        .toList();
  }

  /// Get trips by vehicle
  List<SavedTrip> getTripsByVehicle(String vehicleName) {
    return _savedTrips
        .where((trip) => trip.preferredVehicle == vehicleName)
        .toList();
  }

  /// Search saved trips
  List<SavedTrip> searchTrips(String query) {
    final lowerQuery = query.toLowerCase();
    return _savedTrips
        .where((trip) =>
            trip.name.toLowerCase().contains(lowerQuery) ||
            trip.source.toLowerCase().contains(lowerQuery) ||
            trip.destination.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Check if a trip already exists
  bool tripExists(String source, String destination) {
    return _savedTrips.any(
        (trip) => trip.source == source && trip.destination == destination);
  }

  /// Get most used trips
  List<SavedTrip> getMostUsedTrips({int limit = 5}) {
    final sorted = List<SavedTrip>.from(_savedTrips);
    sorted.sort((a, b) => b.timesUsed.compareTo(a.timesUsed));
    return sorted.take(limit).toList();
  }

  /// Get recently saved trips
  List<SavedTrip> getRecentTrips({int limit = 5}) {
    final sorted = List<SavedTrip>.from(_savedTrips);
    sorted.sort((a, b) => b.savedDate.compareTo(a.savedDate));
    return sorted.take(limit).toList();
  }

  /// Clear all saved trips from Firestore
  Future<void> clearAll(String userId) async {
    try {
      final batch = _firestore.batch();
      for (var trip in _savedTrips) {
        batch.delete(
          _firestore
              .collection('users')
              .doc(userId)
              .collection('savedTrips')
              .doc(trip.id),
        );
      }
      await batch.commit();

      _savedTrips.clear();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to clear trips: ${e.toString()}';
      rethrow;
    }
  }

  /// Sort trips
  void sortTrips(String sortBy) {
    switch (sortBy) {
      case 'name_asc':
        _savedTrips.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        _savedTrips.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'date_asc':
        _savedTrips.sort((a, b) => a.savedDate.compareTo(b.savedDate));
        break;
      case 'date_desc':
        _savedTrips.sort((a, b) => b.savedDate.compareTo(a.savedDate));
        break;
      case 'usage_asc':
        _savedTrips.sort((a, b) => a.timesUsed.compareTo(b.timesUsed));
        break;
      case 'usage_desc':
        _savedTrips.sort((a, b) => b.timesUsed.compareTo(a.timesUsed));
        break;
    }
    notifyListeners();
  }

  /// Export trips as JSON
  List<Map<String, dynamic>> exportAsJson() {
    return _savedTrips.map((trip) => trip.toMap()).toList();
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalSaved': _savedTrips.length,
      'totalFavorites': favoriteTrips.length,
      'totalUsage': _savedTrips.fold(0, (sum, trip) => sum + trip.timesUsed),
      'mostUsedTrip': _savedTrips.isNotEmpty
          ? _savedTrips.reduce((a, b) => a.timesUsed > b.timesUsed ? a : b).name
          : null,
      'uniqueVehicles':
          _savedTrips.map((trip) => trip.preferredVehicle).toSet().length,
      'uniqueRoutes': _savedTrips
          .map((trip) => '${trip.source}-${trip.destination}')
          .toSet()
          .length,
    };
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
}

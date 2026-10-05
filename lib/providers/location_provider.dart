import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'dart:async';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? bearing;
  final double? speed;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.bearing,
    this.speed,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'bearing': bearing,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static LocationData fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      accuracy: map['accuracy'] as double?,
      altitude: map['altitude'] as double?,
      bearing: map['bearing'] as double?,
      speed: map['speed'] as double?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

class LocationProvider extends ChangeNotifier {
  LocationData? _currentLocation;
  bool _isTrackingEnabled = false;
  String?
      _permissionStatus; // 'granted', 'denied', 'notRequested', 'deniedForever'
  double _distanceToDestination = 0;
  double _estimatedTimeRemaining = 0; // in minutes
  StreamSubscription<Position>? _positionStreamSubscription;
  String? _trackingError;

  // Getters
  LocationData? get currentLocation => _currentLocation;
  bool get isTrackingEnabled => _isTrackingEnabled;
  String? get permissionStatus => _permissionStatus;
  double get distanceToDestination => _distanceToDestination;
  double get estimatedTimeRemaining => _estimatedTimeRemaining;
  bool get hasLocation => _currentLocation != null;
  String? get trackingError => _trackingError;

  // Initialize with mock location (Islamabad, Pakistan)
  LocationProvider() {
    _currentLocation = LocationData(
      latitude: 33.6844,
      longitude: 73.0479,
      accuracy: 5.0,
      altitude: 500.0,
      bearing: 45.0,
      speed: 0.0,
      timestamp: DateTime.now(),
    );
    _permissionStatus = 'notRequested';
  }

  /// Request location permission with real geolocator
  Future<void> requestLocationPermission() async {
    try {
      _trackingError = null;

      // Check if location services are enabled
      final serviceEnabled = await LocationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _permissionStatus = 'serviceDisabled';
        _trackingError = 'Location services are disabled on this device';
        notifyListeners();
        return;
      }

      // Request permission
      final permission = await LocationService.requestLocationPermission();

      if (permission == LocationPermission.denied) {
        _permissionStatus = 'denied';
        _trackingError = 'Location permission was denied';
      } else if (permission == LocationPermission.deniedForever) {
        _permissionStatus = 'deniedForever';
        _trackingError =
            'Location permission is permanently denied. Open app settings to enable.';
      } else if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _permissionStatus = 'granted';
        _trackingError = null;

        // Try to get current position immediately
        await _getInitialPosition();
      }

      notifyListeners();
    } catch (e) {
      _permissionStatus = 'error';
      _trackingError = 'Error requesting location permission: $e';
      notifyListeners();
    }
  }

  /// Get initial position (one-time)
  Future<void> _getInitialPosition() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        updateLocation(
          position.latitude,
          position.longitude,
          accuracy: position.accuracy,
          altitude: position.altitude,
          bearing: position.heading,
          speed: position.speed,
        );
      }
    } catch (e) {
      print('Error getting initial position: $e');
    }
  }

  /// Start real-time GPS location tracking
  Future<void> startTracking() async {
    try {
      // Verify permission is granted
      final isGranted = await LocationService.isLocationPermissionGranted();
      if (!isGranted) {
        _trackingError = 'Location permission not granted';
        notifyListeners();
        return;
      }

      _isTrackingEnabled = true;
      _trackingError = null;
      notifyListeners();

      // Get initial position
      await _getInitialPosition();

      // Start streaming location updates
      _positionStreamSubscription?.cancel();
      _positionStreamSubscription = LocationService()
          .getPositionStream(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // Update every 5 meters
      )
          .listen(
        (Position position) {
          if (_isTrackingEnabled) {
            updateLocation(
              position.latitude,
              position.longitude,
              accuracy: position.accuracy,
              altitude: position.altitude,
              bearing: position.heading,
              speed: position.speed,
            );
            // Add to history for tracking the route
            if (_currentLocation != null) {
              addToHistory(_currentLocation!);
            }
          }
        },
        onError: (e) {
          _trackingError = 'Location tracking error: $e';
          _isTrackingEnabled = false;
          notifyListeners();
        },
        cancelOnError: false,
      );
    } catch (e) {
      _trackingError = 'Error starting location tracking: $e';
      _isTrackingEnabled = false;
      notifyListeners();
    }
  }

  /// Stop tracking location
  void stopTracking() {
    _isTrackingEnabled = false;
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _trackingError = null;
    notifyListeners();
  }

  /// Update current location
  void updateLocation(double latitude, double longitude,
      {double? accuracy, double? altitude, double? bearing, double? speed}) {
    _currentLocation = LocationData(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      bearing: bearing,
      speed: speed,
      timestamp: DateTime.now(),
    );
    notifyListeners();
  }

  /// Calculate distance between two coordinates (Haversine formula)
  /// Returns distance in kilometers
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// Set destination location and calculate distance/ETA
  void setDestination(double destLat, double destLon,
      {required double estimatedTravelTime}) {
    if (_currentLocation != null) {
      _distanceToDestination = calculateDistance(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        destLat,
        destLon,
      );
      _estimatedTimeRemaining = estimatedTravelTime;
      notifyListeners();
    }
  }

  /// Update destination metrics (called periodically during trip)
  void updateDestinationMetrics(double destLat, double destLon,
      {required double estimatedTravelTime}) {
    if (_currentLocation != null) {
      final newDistance = calculateDistance(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        destLat,
        destLon,
      );

      // Calculate progress percentage
      if (_distanceToDestination > 0) {
        final progressPercentage =
            (((_distanceToDestination - newDistance) / _distanceToDestination) *
                    100)
                .clamp(0.0, 100.0);
        _distanceToDestination = newDistance;
        _estimatedTimeRemaining =
            (estimatedTravelTime * ((100 - progressPercentage) / 100))
                .clamp(0.0, estimatedTravelTime);
      }
      notifyListeners();
    }
  }

  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  /// Get bearing (direction) to destination
  double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double y = math.sin(dLon) * math.cos(_degreesToRadians(lat2));
    final double x = (math.cos(_degreesToRadians(lat1)) *
            math.sin(_degreesToRadians(lat2))) -
        (math.sin(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.cos(dLon));

    double bearing = math.atan2(y, x);
    bearing = (bearing * 180 / 3.141592653589793 + 360) % 360;
    return bearing;
  }

  /// Check if location permission is granted
  bool get isPermissionGranted => _permissionStatus == 'granted';

  /// Get location history (for future implementation)
  List<LocationData> locationHistory = [];

  /// Add location to history
  void addToHistory(LocationData location) {
    locationHistory.add(location);
    // Keep only last 100 locations
    if (locationHistory.length > 100) {
      locationHistory.removeAt(0);
    }
  }

  /// Clear location history
  void clearHistory() {
    locationHistory.clear();
    notifyListeners();
  }

  /// Mock reset for testing
  void resetToDefaultLocation() {
    _currentLocation = LocationData(
      latitude: 33.6844,
      longitude: 73.0479,
      accuracy: 5.0,
      altitude: 500.0,
      bearing: 45.0,
      speed: 0.0,
      timestamp: DateTime.now(),
    );
    _isTrackingEnabled = false;
    _distanceToDestination = 0;
    _estimatedTimeRemaining = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}

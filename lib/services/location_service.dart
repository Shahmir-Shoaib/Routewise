import 'package:geolocator/geolocator.dart';
import 'dart:async';

/// Service for handling real-time location tracking using Geolocator
class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permission
  static Future<LocationPermission> requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      return await Geolocator.requestPermission();
    } else if (permission == LocationPermission.deniedForever) {
      // Permission is denied forever, open app settings
      await Geolocator.openLocationSettings();
      return LocationPermission.denied;
    }

    return permission;
  }

  /// Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Get current position (one-time)
  static Future<Position?> getCurrentPosition() async {
    try {
      // Request permission if needed
      final permission = await requestLocationPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Get last known position
  static Future<Position?> getLastKnownPosition() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      return position;
    } catch (e) {
      print('Error getting last known position: $e');
      return null;
    }
  }

  /// Start real-time location tracking stream
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilter = 10, // Update every 10 meters
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        timeLimit: const Duration(seconds: 5),
      ),
    );
  }

  /// Calculate distance between two coordinates in meters
  static Future<double> getDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Get bearing between two coordinates
  static double getBearing({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Open location settings (for when permission is denied)
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}

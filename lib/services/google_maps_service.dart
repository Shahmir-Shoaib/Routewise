import 'dart:convert';
import 'package:http/http.dart' as http;

/// Data class for route information
class RouteData {
  final String name;
  final double distance;
  final double estimatedTime;
  final double fuelCost;
  final double tollCharges;
  final double totalCost;
  final bool isRecommended;
  final String encodedPolyline;
  final String startAddress;
  final String endAddress;

  RouteData({
    required this.name,
    required this.distance,
    required this.estimatedTime,
    required this.fuelCost,
    required this.tollCharges,
    required this.totalCost,
    required this.isRecommended,
    required this.encodedPolyline,
    required this.startAddress,
    required this.endAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'distance': distance,
      'estimatedTime': estimatedTime,
      'fuelCost': fuelCost,
      'tollCharges': tollCharges,
      'totalCost': totalCost,
      'isRecommended': isRecommended,
      'encodedPolyline': encodedPolyline,
      'startAddress': startAddress,
      'endAddress': endAddress,
    };
  }
}

/// Data class for route metrics
class RouteMetrics {
  final double distanceKm;
  final double estimatedTimeHours;
  final double fuelNeededLiters;
  final double fuelCostPKR;
  final double tollChargesPKR;
  final double totalCostPKR;
  final double averageSpeedKmh;

  RouteMetrics({
    required this.distanceKm,
    required this.estimatedTimeHours,
    required this.fuelNeededLiters,
    required this.fuelCostPKR,
    required this.tollChargesPKR,
    required this.totalCostPKR,
    required this.averageSpeedKmh,
  });
}

class GoogleMapsService {
  // Replace with your actual Google Maps API key
  static const String _googleMapsApiKey = 'AIzaSyBJDnxzhtjPrnjLMGKTr42I30iDImtF80c';

  /// Get directions between two locations
  static Future<Map<String, dynamic>?> getDirections({
    required String origin,
    required String destination,
  }) async {
    try {
      final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${Uri.encodeComponent(origin)}'
          '&destination=${Uri.encodeComponent(destination)}'
          '&key=$_googleMapsApiKey';

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'OK' && json['routes'] != null) {
          return json['routes'][0];
        }
      }
      return null;
    } catch (e) {
      print('Error getting directions: $e');
      return null;
    }
  }

  /// Get distance between two locations
  static Future<Map<String, dynamic>?> getDistance({
    required String origin,
    required String destination,
  }) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/distancematrix/json?'
          'origins=${Uri.encodeComponent(origin)}'
          '&destinations=${Uri.encodeComponent(destination)}'
          '&key=$_googleMapsApiKey';

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'OK' && json['rows'] != null) {
          return json['rows'][0];
        }
      }
      return null;
    } catch (e) {
      print('Error getting distance: $e');
      return null;
    }
  }

  /// Search for places by text query
  static Future<List<dynamic>?> searchPlaces(String query) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/textsearch/json?'
          'query=${Uri.encodeComponent(query)}'
          '&key=$_googleMapsApiKey';

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'OK') {
          return json['results'];
        }
      }
      return null;
    } catch (e) {
      print('Error searching places: $e');
      return null;
    }
  }

  /// Get autocomplete predictions for a place query
  static Future<List<dynamic>?> getPlacePredictions(String input) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
          'input=${Uri.encodeComponent(input)}'
          '&key=$_googleMapsApiKey';

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'OK') {
          return json['predictions'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting place predictions: $e');
      return null;
    }
  }

  /// Get place details
  static Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/details/json?'
          'place_id=$placeId'
          '&key=$_googleMapsApiKey';

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'OK') {
          return json['result'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }

  /// Calculate multiple routes and return route data
  static Future<List<RouteData>> calculateRoutes({
    required String origin,
    required String destination,
    required double fuelAverage,
  }) async {
    try {
      final directionsData = await getDirections(
        origin: origin,
        destination: destination,
      );

      if (directionsData == null) {
        throw Exception('No routes found');
      }

      List<RouteData> routes = [];

      // Get first route for now - could be extended to handle multiple
      final legs = directionsData['legs'] ?? [];
      if (legs.isEmpty) return routes;

      final leg = legs[0];
      final distanceInMeters = leg['distance']?['value'] ?? 0;
      final distanceInKm = distanceInMeters / 1000;
      final durationInSeconds = leg['duration']?['value'] ?? 0;
      final durationInHours = durationInSeconds / 3600;

      // Calculate fuel cost (example: PKR 300 per liter)
      const fuelPricePerLiter = 300.0;
      final fuelNeeded = distanceInKm / fuelAverage;
      final fuelCost = fuelNeeded * fuelPricePerLiter;

      // Estimate toll charges (example calculation)
      final tollCharges = distanceInKm > 100 ? distanceInKm * 5 : 0.0;

      routes.add(
        RouteData(
          name: 'Route 1',
          distance: distanceInKm,
          estimatedTime: durationInHours,
          fuelCost: fuelCost,
          tollCharges: tollCharges,
          totalCost: fuelCost + tollCharges,
          isRecommended: true,
          encodedPolyline: directionsData['overview_polyline']?['points'] ?? '',
          startAddress: leg['start_address'] ?? '',
          endAddress: leg['end_address'] ?? '',
        ),
      );

      return routes;
    } catch (e) {
      print('Error calculating routes: $e');
      throw Exception('Failed to calculate routes: $e');
    }
  }

  /// Get cost breakdown for a route
  static RouteMetrics getRouteMetrics({
    required double distanceKm,
    required double estimatedHours,
    required double fuelAverage,
    required double tollCharges,
  }) {
    const fuelPricePerLiter = 300.0;
    final fuelNeeded = distanceKm / fuelAverage;
    final fuelCost = fuelNeeded * fuelPricePerLiter;
    final totalCost = fuelCost + tollCharges;
    final averageSpeed = distanceKm / estimatedHours;

    return RouteMetrics(
      distanceKm: distanceKm,
      estimatedTimeHours: estimatedHours,
      fuelNeededLiters: fuelNeeded,
      fuelCostPKR: fuelCost,
      tollChargesPKR: tollCharges,
      totalCostPKR: totalCost,
      averageSpeedKmh: averageSpeed,
    );
  }
}

import '../models/route_model.dart';
import '../models/vehicle_model.dart';
import 'google_maps_service.dart';

class RouteService {
  // Get routes using Google Maps API with fallback to mock data
  Future<List<Route>> getRoutes(
    String source,
    String destination,
    Vehicle? vehicle,
    double fuelAverage,
  ) async {
    try {
      // Try to get routes from Google Maps API
      final googleRoutes = await GoogleMapsService.calculateRoutes(
        origin: source,
        destination: destination,
        fuelAverage: fuelAverage,
      );

      // Convert Google Maps routes to Route model
      return googleRoutes.asMap().entries.map((entry) {
        final index = entry.key;
        final googleRoute = entry.value;
        return Route(
          id: '${index + 1}',
          name: googleRoute.name,
          source: source,
          destination: destination,
          distance: googleRoute.distance,
          estimatedTime: googleRoute.estimatedTime,
          fuelCost: googleRoute.fuelCost,
          tollCharges: googleRoute.tollCharges,
          route: [googleRoute.startAddress, googleRoute.endAddress],
          tollBooths: [], // Would need additional API call to get toll booths
          encodedPolyline: googleRoute.encodedPolyline,
          isRecommended: index == 0, // First route is recommended
        );
      }).toList();
    } catch (e) {
      print('Google Maps API error: $e. Falling back to mock data.');
      // Fallback to mock data if Google Maps API fails
      return _getMockRoutes(source, destination, fuelAverage);
    }
  }

  // Mock route data - fallback when API is unavailable
  Future<List<Route>> _getMockRoutes(
    String source,
    String destination,
    double fuelAverage,
  ) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate mock routes based on source and destination
    final routes = [
      Route(
        id: '1',
        name: 'Shortest Route',
        source: source,
        destination: destination,
        distance: 245.5,
        estimatedTime: 4.5,
        fuelCost: _calculateFuelCost(245.5, fuelAverage),
        tollCharges: 450,
        route: ['M-11', 'N-5'],
        tollBooths: ['Attock Toll', 'Hazro Toll'],
        isRecommended: false,
        encodedPolyline: '',
      ),
      Route(
        id: '2',
        name: 'Fastest Route',
        source: source,
        destination: destination,
        distance: 280.2,
        estimatedTime: 3.8,
        fuelCost: _calculateFuelCost(280.2, fuelAverage),
        tollCharges: 650,
        route: ['M-11', 'Motorway'],
        tollBooths: ['Attock Toll', 'Chakbeli Toll', 'Peshawar Toll'],
        isRecommended: false,
        encodedPolyline: '',
      ),
      Route(
        id: '3',
        name: 'Most Economical',
        source: source,
        destination: destination,
        distance: 235.8,
        estimatedTime: 5.2,
        fuelCost: _calculateFuelCost(235.8, fuelAverage),
        tollCharges: 250,
        route: ['N-5', 'Local Roads'],
        tollBooths: ['Hazro Toll'],
        isRecommended: true,
        encodedPolyline: '',
      ),
    ];

    return routes;
  }

  double _calculateFuelCost(double distance, double fuelAverage) {
    const fuelPricePerLiter = 280.0; // Pakistani rupees
    final litersRequired = distance / fuelAverage;
    return litersRequired * fuelPricePerLiter;
  }

  // Validate that source and destination are not the same
  bool validateRouteInput(String source, String destination) {
    return source.isNotEmpty &&
        destination.isNotEmpty &&
        source.toLowerCase() != destination.toLowerCase();
  }
}

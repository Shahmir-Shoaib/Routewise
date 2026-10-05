import '../models/route_model.dart';
import '../models/vehicle_model.dart';

class AIRecommendationService {
  // AI recommendation algorithm based on vehicle type and fuel average
  Route recommendBestRoute(
    List<Route> routes,
    Vehicle? vehicle,
    double fuelAverage,
  ) {
    if (routes.isEmpty) {
      throw Exception('No routes available');
    }

    // If user has selected a specific vehicle type
    if (vehicle != null) {
      return _recommendByVehicleType(routes, vehicle, fuelAverage);
    }

    // Default: recommend most economical route
    return _recommendMostEconomical(routes);
  }

  Route _recommendByVehicleType(
    List<Route> routes,
    Vehicle vehicle,
    double fuelAverage,
  ) {
    switch (vehicle.name.toLowerCase()) {
      case 'bike':
        // Bikes are economical, prefer shortest distance
        return _recommendMostEconomical(routes);
      case 'car':
        // Cars need balance between time and cost
        return _recommendBalanced(routes);
      case 'suv':
        // SUVs consume more fuel, heavily prefer economical
        return _recommendMostEconomical(routes);
      case 'bus':
        // Buses follow fixed routes, recommend fastest reliable route
        return _recommendFastest(routes);
      default:
        return _recommendMostEconomical(routes);
    }
  }

  Route _recommendMostEconomical(List<Route> routes) {
    return routes.reduce(
        (best, current) => current.fuelCost < best.fuelCost ? current : best);
  }

  Route _recommendFastest(List<Route> routes) {
    return routes.reduce((best, current) =>
        current.estimatedTime < best.estimatedTime ? current : best);
  }

  Route _recommendBalanced(List<Route> routes) {
    // Score based on cost and time: lower is better
    double calculateScore(Route route) {
      // Normalize values and combine
      final costScore = route.fuelCost / 10000; // normalize cost
      final timeScore = route.estimatedTime / 10; // normalize time
      return (costScore * 0.6) + (timeScore * 0.4); // 60% cost, 40% time
    }

    Route best = routes[0];
    double bestScore = calculateScore(best);

    for (var route in routes.skip(1)) {
      final score = calculateScore(route);
      if (score < bestScore) {
        best = route;
        bestScore = score;
      }
    }

    return best;
  }

  // Get recommendations as a sorted list
  List<Route> getRecommendationsList(
    List<Route> routes,
    Vehicle? vehicle,
    double fuelAverage,
  ) {
    final recommended = recommendBestRoute(routes, vehicle, fuelAverage);

    // Sort: recommended first, then by cost
    final sorted = [...routes];
    sorted.sort((a, b) {
      if (a.id == recommended.id) return -1;
      if (b.id == recommended.id) return 1;
      return a.fuelCost.compareTo(b.fuelCost);
    });

    return sorted;
  }
}

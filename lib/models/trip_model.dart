import 'route_model.dart';
import 'vehicle_model.dart';

class Trip {
  final String id;
  final String source;
  final String destination;
  final Vehicle? vehicle;
  final double fuelAverage;
  final List<Route> availableRoutes;
  final Route? selectedRoute;
  final DateTime createdAt;

  Trip({
    required this.id,
    required this.source,
    required this.destination,
    this.vehicle,
    required this.fuelAverage,
    required this.availableRoutes,
    this.selectedRoute,
    required this.createdAt,
  });

  double get totalFuelCost {
    if (selectedRoute == null) return 0;
    return selectedRoute!.fuelCost;
  }

  double get totalTime {
    if (selectedRoute == null) return 0;
    return selectedRoute!.estimatedTime;
  }

  double get totalDistance {
    if (selectedRoute == null) return 0;
    return selectedRoute!.distance;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source': source,
      'destination': destination,
      'vehicle': vehicle?.toMap(),
      'fuelAverage': fuelAverage,
      'availableRoutes': availableRoutes.map((r) => r.toMap()).toList(),
      'selectedRoute': selectedRoute?.toMap(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

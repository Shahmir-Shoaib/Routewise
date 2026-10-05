import 'package:flutter/material.dart' hide Route;
import '../models/route_model.dart';
import '../models/vehicle_model.dart';
import '../services/route_service.dart';
import '../services/ai_recommendation_service.dart';

class RouteProvider extends ChangeNotifier {
  final RouteService _routeService = RouteService();
  final AIRecommendationService _aiService = AIRecommendationService();

  String _source = '';
  String _destination = '';
  List<Route> _availableRoutes = [];
  Route? _selectedRoute;
  bool _isLoading = false;
  String? _errorMessage;

  String get source => _source;
  String get destination => _destination;
  List<Route> get availableRoutes => _availableRoutes;
  Route? get selectedRoute => _selectedRoute;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setSource(String source) {
    _source = source;
    notifyListeners();
  }

  void setDestination(String destination) {
    _destination = destination;
    notifyListeners();
  }

  Future<bool> searchRoutes(Vehicle? vehicle, double fuelAverage) async {
    if (!_routeService.validateRouteInput(_source, _destination)) {
      _errorMessage = 'Please enter valid source and destination';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _availableRoutes = [];
    _selectedRoute = null;
    notifyListeners();

    try {
      final routes = await _routeService.getRoutes(
        _source,
        _destination,
        vehicle,
        fuelAverage,
      );

      // Get AI recommendations
      final recommendedRoute = _aiService.recommendBestRoute(
        routes,
        vehicle,
        fuelAverage,
      );

      // Mark the recommended route
      _availableRoutes = routes.map((r) {
        if (r.id == recommendedRoute.id) {
          return Route(
            id: r.id,
            name: r.name,
            source: r.source,
            destination: r.destination,
            distance: r.distance,
            estimatedTime: r.estimatedTime,
            fuelCost: r.fuelCost,
            tollCharges: r.tollCharges,
            route: r.route,
            tollBooths: r.tollBooths,
            isRecommended: true,
            encodedPolyline: r.encodedPolyline,
          );
        }
        return r;
      }).toList();

      _selectedRoute = recommendedRoute;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to search routes: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void selectRoute(Route route) {
    _selectedRoute = route;
    notifyListeners();
  }

  void reset() {
    _source = '';
    _destination = '';
    _availableRoutes = [];
    _selectedRoute = null;
    _errorMessage = null;
    notifyListeners();
  }
}

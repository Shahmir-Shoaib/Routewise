class Route {
  final String id;
  final String name;
  final String source;
  final String destination;
  final double distance;
  final double estimatedTime; // in hours
  final double fuelCost;
  final double tollCharges; // new field
  final List<String> route;
  final List<String> tollBooths; // new field
  final bool isRecommended;

  /// Encoded polyline returned by Google Directions API.
  /// Used for drawing the route on Google Maps.
  final String encodedPolyline;

  Route({
    required this.id,
    required this.name,
    required this.source,
    required this.destination,
    required this.distance,
    required this.estimatedTime,
    required this.fuelCost,
    required this.tollCharges,
    required this.route,
    required this.tollBooths,
    this.isRecommended = false,
    this.encodedPolyline = '',
  });

  double get totalCost => fuelCost + tollCharges;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'source': source,
      'destination': destination,
      'distance': distance,
      'estimatedTime': estimatedTime,
      'fuelCost': fuelCost,
      'tollCharges': tollCharges,
      'route': route,
      'tollBooths': tollBooths,
      'isRecommended': isRecommended,
      'encodedPolyline': encodedPolyline,
    };
  }

  factory Route.fromMap(Map<String, dynamic> map) {
    return Route(
      id: map['id'],
      name: map['name'],
      source: map['source'],
      destination: map['destination'],
      distance: (map['distance'] as num).toDouble(),
      estimatedTime: (map['estimatedTime'] as num).toDouble(),
      fuelCost: (map['fuelCost'] as num).toDouble(),
      tollCharges: (map['tollCharges'] as num?)?.toDouble() ?? 0.0,
      route: List<String>.from(map['route'] ?? const []),
      tollBooths: List<String>.from(map['tollBooths'] ?? []),
      isRecommended: map['isRecommended'] ?? false,
      encodedPolyline: map['encodedPolyline'] ?? '',
    );
  }
}

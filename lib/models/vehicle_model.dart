class Vehicle {
  final String id;
  final String name;
  final double defaultAverage; // km per liter

  Vehicle({
    String? id,
    required this.name,
    required this.defaultAverage,
  }) : id = id ?? 'vehicle_${DateTime.now().millisecondsSinceEpoch}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'defaultAverage': defaultAverage,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      name: map['name'],
      defaultAverage: map['defaultAverage'],
    );
  }
}

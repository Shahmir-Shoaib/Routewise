import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeeder {
  static Future<void> seedFirestoreForUser(String userId) async {
    final firestore = FirebaseFirestore.instance;

    await _seedUserProfile(userId, firestore);
    await _seedVehicles(userId, firestore);
    await _seedSavedTrips(userId, firestore);
    await _seedCompletedTrips(userId, firestore);
    await _seedRootTrips(userId, firestore);
  }

  static Future<void> _seedUserProfile(
      String userId, FirebaseFirestore firestore) async {
    final userDoc = firestore.collection('users').doc(userId);

    await userDoc.set(
      {
        'uid': userId,
        'name': 'RouteWise Test User',
        'email': 'testuser@example.com',
        'photoUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
        'preferences': {
          'themeMode': 'light',
          'defaultFuelUnit': 'km/l',
          'showTollEstimates': true,
        },
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> _seedVehicles(
      String userId, FirebaseFirestore firestore) async {
    final vehicles = [
      {
        'id': 'vehicle_sedan_1',
        'name': 'Honda Civic',
        'defaultAverage': 15.0,
      },
      {
        'id': 'vehicle_suv_1',
        'name': 'Toyota RAV4',
        'defaultAverage': 12.0,
      },
    ];

    for (final vehicle in vehicles) {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicle['id'] as String)
          .set(vehicle);
    }
  }

  static Future<void> _seedSavedTrips(
      String userId, FirebaseFirestore firestore) async {
    final now = DateTime.now();
    final savedTrips = [
      {
        'id': 'saved_trip_commute',
        'name': 'Commute to Office',
        'source': 'Downtown',
        'destination': 'Office Park',
        'preferredVehicle': 'Honda Civic',
        'savedDate': now.subtract(const Duration(days: 10)).toIso8601String(),
        'timesUsed': 18,
        'notes': 'Morning commute via the river road.',
        'isFavorite': true,
      },
      {
        'id': 'saved_trip_mall',
        'name': 'Shopping at City Mall',
        'source': 'Home',
        'destination': 'City Mall',
        'preferredVehicle': 'Toyota RAV4',
        'savedDate': now.subtract(const Duration(days: 4)).toIso8601String(),
        'timesUsed': 5,
        'notes': 'Avoid the toll highway when traffic is bad.',
        'isFavorite': false,
      },
    ];

    for (final savedTrip in savedTrips) {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('savedTrips')
          .doc(savedTrip['id'] as String)
          .set(savedTrip);
    }
  }

  static Future<void> _seedCompletedTrips(
      String userId, FirebaseFirestore firestore) async {
    final now = DateTime.now();
    final completedTrips = [
      {
        'id': 'completed_trip_airport',
        'source': 'Home',
        'destination': 'Airport',
        'vehicleName': 'Honda Civic',
        'distance': 32.4,
        'estimatedTime': 0.75,
        'actualTime': 0.70,
        'estimatedCost': 4.50,
        'actualCost': 4.10,
        'startTime': now.subtract(const Duration(days: 2)).toIso8601String(),
        'endTime': now
            .subtract(const Duration(days: 2))
            .add(const Duration(minutes: 42))
            .toIso8601String(),
        'averageSpeed': 46.3,
        'stopsCount': 0,
        'notes': 'Took the toll route and saved 5 minutes.',
      },
      {
        'id': 'completed_trip_weekend',
        'source': 'Office Park',
        'destination': 'Lakeview Resort',
        'vehicleName': 'Toyota RAV4',
        'distance': 120.8,
        'estimatedTime': 2.25,
        'actualTime': 2.15,
        'estimatedCost': 16.80,
        'actualCost': 15.90,
        'startTime': now.subtract(const Duration(days: 7)).toIso8601String(),
        'endTime': now
            .subtract(const Duration(days: 7))
            .add(const Duration(hours: 2, minutes: 9))
            .toIso8601String(),
        'averageSpeed': 56.2,
        'stopsCount': 2,
        'notes': 'Smooth drive with one coffee stop.',
      },
    ];

    for (final trip in completedTrips) {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('completedTrips')
          .doc(trip['id'] as String)
          .set(trip);
    }
  }

  static Future<void> _seedRootTrips(
      String userId, FirebaseFirestore firestore) async {
    final trips = [
      {
        'id': 'trip_airport_fastest',
        'source': 'Home',
        'destination': 'Airport',
        'vehicle': {
          'id': 'vehicle_sedan_1',
          'name': 'Honda Civic',
          'defaultAverage': 15.0,
        },
        'fuelAverage': 15.0,
        'availableRoutes': [
          {
            'id': 'route_1',
            'name': 'Fastest Route',
            'source': 'Home',
            'destination': 'Airport',
            'distance': 32.4,
            'estimatedTime': 0.65,
            'fuelCost': 3.80,
            'tollCharges': 1.40,
            'route': ['Main St', 'River Rd', 'Airport Hwy'],
            'tollBooths': ['East Toll Plaza'],
            'isRecommended': true,
            'encodedPolyline': '',
          },
          {
            'id': 'route_2',
            'name': 'Economy Route',
            'source': 'Home',
            'destination': 'Airport',
            'distance': 35.0,
            'estimatedTime': 0.80,
            'fuelCost': 3.90,
            'tollCharges': 0.00,
            'route': ['Main St', 'Country Rd', 'Airport Blvd'],
            'tollBooths': [],
            'isRecommended': false,
            'encodedPolyline': '',
          },
        ],
        'selectedRoute': {
          'id': 'route_1',
          'name': 'Fastest Route',
          'source': 'Home',
          'destination': 'Airport',
          'distance': 32.4,
          'estimatedTime': 0.65,
          'fuelCost': 3.80,
          'tollCharges': 1.40,
          'route': ['Main St', 'River Rd', 'Airport Hwy'],
          'tollBooths': ['East Toll Plaza'],
          'isRecommended': true,
          'encodedPolyline': '',
        },
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'trip_mall_slow',
        'source': 'Home',
        'destination': 'City Mall',
        'vehicle': {
          'id': 'vehicle_suv_1',
          'name': 'Toyota RAV4',
          'defaultAverage': 12.0,
        },
        'fuelAverage': 12.0,
        'availableRoutes': [
          {
            'id': 'route_3',
            'name': 'Toll Route',
            'source': 'Home',
            'destination': 'City Mall',
            'distance': 28.2,
            'estimatedTime': 0.70,
            'fuelCost': 3.20,
            'tollCharges': 1.00,
            'route': ['Valley Rd', 'Expressway', 'Mall Rd'],
            'tollBooths': ['North Toll Plaza'],
            'isRecommended': true,
            'encodedPolyline': '',
          },
          {
            'id': 'route_4',
            'name': 'Scenic Route',
            'source': 'Home',
            'destination': 'City Mall',
            'distance': 31.0,
            'estimatedTime': 0.90,
            'fuelCost': 3.70,
            'tollCharges': 0.00,
            'route': ['Valley Rd', 'Countryside Ave', 'Mall Rd'],
            'tollBooths': [],
            'isRecommended': false,
            'encodedPolyline': '',
          },
        ],
        'selectedRoute': {
          'id': 'route_3',
          'name': 'Toll Route',
          'source': 'Home',
          'destination': 'City Mall',
          'distance': 28.2,
          'estimatedTime': 0.70,
          'fuelCost': 3.20,
          'tollCharges': 1.00,
          'route': ['Valley Rd', 'Expressway', 'Mall Rd'],
          'tollBooths': ['North Toll Plaza'],
          'isRecommended': true,
          'encodedPolyline': '',
        },
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final trip in trips) {
      await firestore.collection('trips').doc(trip['id'] as String).set(trip);
    }
  }
}

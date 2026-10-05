# Live Location Tracking Integration Guide

## Quick Start

Your app now has full GPS location tracking capability. Here's how to use it in your existing screens.

## 1. Enable Location at App Startup

Add this to your `main.dart` or splash screen:

```dart
import 'package:provider/provider.dart';
import 'package:routewise/providers/location_provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    // Get location provider
    final locationProvider = context.read<LocationProvider>();
    
    // Request location permission
    await locationProvider.requestLocationPermission();
    
    // Check if permission is granted
    if (locationProvider.permissionStatus == 'granted') {
      print('Location permission granted');
    } else {
      print('Location permission: ${locationProvider.permissionStatus}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
```

---

## 2. Update Trip Tracking Screen

Replace the simulation with real GPS tracking:

```dart
class TripTrackingScreen extends StatefulWidget {
  final RouteData route;

  const TripTrackingScreen({required this.route});

  @override
  State<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends State<TripTrackingScreen> {
  @override
  void initState() {
    super.initState();
    _startLiveTracking();
  }

  Future<void> _startLiveTracking() async {
    final locationProvider = context.read<LocationProvider>();
    
    // Verify permission
    if (locationProvider.permissionStatus != 'granted') {
      await locationProvider.requestLocationPermission();
    }

    // If permission still not granted, show error
    if (locationProvider.permissionStatus != 'granted') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              locationProvider.trackingError ?? 'Location permission required',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                // Open app settings if permission denied forever
                if (locationProvider.permissionStatus == 'deniedForever') {
                  LocationService.openAppSettings();
                }
              },
            ),
          ),
        );
      }
      return;
    }

    // Start tracking
    await locationProvider.startTracking();
    
    // Set destination (extracted from route)
    locationProvider.setDestination(
      route.destinationLatitude,  // You'll need to add these to RouteData
      route.destinationLongitude,
      estimatedTravelTime: route.estimatedTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${route.name} - Live Tracking'),
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          final location = locationProvider.currentLocation;

          if (location == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Acquiring GPS location...'),
                ],
              ),
            );
          }

          // Display error if any
          if (locationProvider.trackingError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(locationProvider.trackingError!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _startLiveTracking,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Current Location Card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _LocationInfoRow(
                          label: 'Latitude',
                          value: location.latitude.toStringAsFixed(6),
                          icon: Icons.location_on,
                        ),
                        _LocationInfoRow(
                          label: 'Longitude',
                          value: location.longitude.toStringAsFixed(6),
                          icon: Icons.location_on,
                        ),
                        _LocationInfoRow(
                          label: 'Accuracy',
                          value: '${location.accuracy?.toStringAsFixed(1) ?? 'N/A'} m',
                          icon: Icons.adjust,
                        ),
                        _LocationInfoRow(
                          label: 'Speed',
                          value: '${(location.speed ?? 0).toStringAsFixed(1)} km/h',
                          icon: Icons.speed,
                        ),
                        if (location.altitude != null)
                          _LocationInfoRow(
                            label: 'Altitude',
                            value: '${location.altitude?.toStringAsFixed(1) ?? 'N/A'} m',
                            icon: Icons.terrain,
                          ),
                      ],
                    ),
                  ),
                ),

                // Trip Progress
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Trip Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: 1 - (locationProvider.distanceToDestination / 
                              route.distance).clamp(0, 1),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Distance Remaining',
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '${locationProvider.distanceToDestination.toStringAsFixed(2)} km',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Time Remaining',
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '${locationProvider.estimatedTimeRemaining.toStringAsFixed(0)} min',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Location History (optional)
                if (locationProvider.locationHistory.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Route History: ${locationProvider.locationHistory.length} points',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tracking your exact route for post-trip analysis',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _endTrip(context),
        label: const Text('End Trip'),
        icon: const Icon(Icons.stop),
      ),
    );
  }

  void _endTrip(BuildContext context) {
    final locationProvider = context.read<LocationProvider>();
    
    // Save location history
    final history = locationProvider.locationHistory;
    print('Trip ended with ${history.length} location points');
    
    // Stop tracking
    locationProvider.stopTracking();
    
    // Save to database
    _saveTripData(context, history);
    
    // Navigate back
    Navigator.pop(context);
  }

  void _saveTripData(BuildContext context, List<LocationData> history) {
    // Save route points to Firestore for future analysis
    final tripProvider = context.read<TripProvider>();
    
    // You can save the location history along with the trip
    print('Saving ${history.length} location points to database');
  }

  @override
  void dispose() {
    // Stop tracking when leaving screen
    context.read<LocationProvider>().stopTracking();
    super.dispose();
  }
}

/// Helper widget for location info display
class _LocationInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _LocationInfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
```

---

## 3. Route Input/Selection Screen

Get user's current location for auto-fill:

```dart
class RouteInputScreen extends StatefulWidget {
  @override
  State<RouteInputScreen> createState() => _RouteInputScreenState();
}

class _RouteInputScreenState extends State<RouteInputScreen> {
  @override
  void initState() {
    super.initState();
    _initializeOrigin();
  }

  Future<void> _initializeOrigin() async {
    final locationProvider = context.read<LocationProvider>();
    
    // Get current position
    final position = await LocationService.getCurrentPosition();
    
    if (position != null && mounted) {
      // Pre-fill origin with current location
      _originController.text = 
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      
      // Update provider
      locationProvider.updateLocation(
        position.latitude,
        position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan Your Route')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _originController,
              decoration: InputDecoration(
                labelText: 'Origin',
                hintText: 'Fetching your current location...',
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _initializeOrigin,
                ),
              ),
            ),
            // ... rest of form
          ],
        ),
      ),
    );
  }
}
```

---

## 4. Home Screen - Show Live Location

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          final location = locationProvider.currentLocation;

          return Column(
            children: [
              // Live location badge
              if (location != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    border: Border.all(color: AppColors.secondary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.secondary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Live Location: ${location.latitude.toStringAsFixed(4)}, '
                        '${location.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              // ... rest of screen
            ],
          );
        },
      ),
    );
  }
}
```

---

## 5. Update RouteData Model

If not already present, add coordinates to your `RouteData` model:

```dart
class RouteData {
  final String name;
  final double distance;
  final double estimatedTime;
  final double fuelCost;
  final double tollCharges;
  final double totalCost;
  
  // Add these for GPS tracking
  final double originLatitude;
  final double originLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  
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
    required this.originLatitude,
    required this.originLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.isRecommended,
    required this.encodedPolyline,
    required this.startAddress,
    required this.endAddress,
  });
}
```

---

## 6. Automatic ETA Updates During Trip

Add to your trip tracking to update ETA as you move:

```dart
Future<void> _updateTripMetrics(LocationProvider locationProvider) async {
  // This is called periodically as location updates come in
  locationProvider.updateDestinationMetrics(
    route.destinationLatitude,
    route.destinationLongitude,
    estimatedTravelTime: route.estimatedTime,
  );
}
```

---

## Testing Checklist

- [ ] Location permission requested on app start
- [ ] Current location shown on route input screen
- [ ] GPS accuracy and speed displayed during trip
- [ ] Distance to destination updates as you move
- [ ] ETA counts down correctly
- [ ] Location history tracked (can be viewed after trip)
- [ ] Trip stops tracking when screen closes
- [ ] Works on real device with GPS

---

## Performance Tips

1. **Battery**: Stop tracking when not in a trip
2. **Accuracy**: Use `.best` for tracking, `.medium` for background
3. **Updates**: Every 5 meters or 2 seconds is balanced
4. **History**: Automatically limited to 100 last positions
5. **Memory**: Location history cleared when trip ends


# Live Location Tracking - Quick Reference Card

## 🚀 One-Minute Setup

### Android
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

```kotlin
// android/app/build.gradle.kts
minSdk = 21
```

### iOS
```xml
<!-- ios/Runner/Info.plist (inside <dict>) -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>RouteWise needs your location to track your route and provide accurate ETA</string>
```

---

## 💻 Code Snippets

### Request Location Permission
```dart
import 'package:routewise/providers/location_provider.dart';

final locationProvider = context.read<LocationProvider>();
await locationProvider.requestLocationPermission();

if (locationProvider.permissionStatus == 'granted') {
  print('Permission granted!');
} else {
  print('Permission denied: ${locationProvider.permissionStatus}');
  print('Error: ${locationProvider.trackingError}');
}
```

### Start Tracking
```dart
// Start GPS tracking
await locationProvider.startTracking();

// Set where you're going
locationProvider.setDestination(
  33.7298,  // destination latitude
  74.3382,  // destination longitude
  estimatedTravelTime: 1.5,  // hours
);
```

### Get Current Location
```dart
Consumer<LocationProvider>(
  builder: (context, provider, _) {
    final location = provider.currentLocation;
    if (location == null) return Text('Loading...');
    
    return Column(
      children: [
        Text('Lat: ${location.latitude}'),
        Text('Lng: ${location.longitude}'),
        Text('Speed: ${location.speed} km/h'),
        Text('Accuracy: ${location.accuracy} m'),
      ],
    );
  },
)
```

### Get Trip Progress
```dart
Consumer<LocationProvider>(
  builder: (context, provider, _) {
    return Column(
      children: [
        Text('Distance Left: ${provider.distanceToDestination.toStringAsFixed(1)} km'),
        Text('Time Left: ${provider.estimatedTimeRemaining.toStringAsFixed(0)} min'),
      ],
    );
  },
)
```

### Stop Tracking
```dart
locationProvider.stopTracking();
```

### Handle Permissions Error
```dart
if (provider.trackingError != null) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Location Error'),
      content: Text(provider.trackingError!),
      actions: [
        TextButton(
          onPressed: () => LocationService.openAppSettings(),
          child: Text('Open Settings'),
        ),
      ],
    ),
  );
}
```

---

## 📊 Available Data

```dart
LocationData location = provider.currentLocation!;

// Position
location.latitude       // double
location.longitude      // double

// Quality
location.accuracy       // double (meters)
location.altitude       // double (meters above sea level)

// Movement
location.speed          // double (km/h)
location.bearing        // double (0-360°, direction)

// Metadata
location.timestamp      // DateTime
```

---

## ⚙️ Configuration

### Location Update Frequency
In `LocationProvider.startTracking()`:

```dart
LocationService().getPositionStream(
  accuracy: LocationAccuracy.best,     // .high, .medium, .low
  distanceFilter: 5,                   // meters (5, 10, 20, 50)
)
```

**Accuracy vs Battery**
| Accuracy | Error Range | Battery |
|----------|------------|---------|
| best | ~5m | Very High |
| high | ~25m | High |
| medium | ~100m | Medium |
| low | ~500m | Low |

**Distance Filter**
- 5m: Very responsive, high GPS usage
- 10m: Balanced (recommended)
- 20-50m: Less responsive, saves battery

---

## 🔄 Full Trip Workflow

```dart
// 1. Request permission (do once at startup)
await locationProvider.requestLocationPermission();

// 2. Start trip
await locationProvider.startTracking();

// 3. Set destination
locationProvider.setDestination(
  destLat, destLon,
  estimatedTravelTime: 1.5,
);

// 4. Display location in UI (uses Consumer)
// Location updates automatically every 5 meters or in real-time

// 5. Update ETA as user moves
// This happens automatically in the provider

// 6. End trip
locationProvider.stopTracking();

// 7. Access location history
List<LocationData> history = locationProvider.locationHistory;
// Each point: latitude, longitude, accuracy, speed, timestamp
```

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| "Permission denied" | Add permissions to AndroidManifest.xml |
| "Location services disabled" | Show user: "Enable location in device settings" |
| No location updates | Ensure outside for GPS signal, test on real device |
| Very inaccurate (> 1km) | Wait longer, move around, go outside |
| High battery drain | Increase distanceFilter to 20-50m |
| App crashes | Run `flutter clean`, `flutter pub get`, rebuild |

---

## 🎯 Permission Status Values

```dart
provider.permissionStatus

// Values:
'notRequested'     // Permission not yet asked
'granted'          // User allowed location access ✅
'denied'           // User denied (can ask again)
'deniedForever'    // User denied permanently (open settings)
'serviceDisabled'  // Location disabled on device
'error'            // Something went wrong
```

---

## 🗺️ Location History

```dart
// Access all tracked points
List<LocationData> history = provider.locationHistory;

// Each point has:
point.latitude
point.longitude
point.accuracy
point.speed
point.timestamp
point.altitude

// Clear history when trip ends
provider.clearHistory();

// Save to database
for (var point in history) {
  var map = point.toMap();
  // Save to Firestore: db.collection('trips').add(map)
}
```

---

## 📱 Testing

```dart
// In your code, add this for quick testing:
Future<void> testLocation() async {
  print('Testing location service...');
  
  // Test 1: Services enabled?
  final enabled = await LocationService.isLocationServiceEnabled();
  print('Services enabled: $enabled');
  
  // Test 2: Permission granted?
  final granted = await LocationService.isLocationPermissionGranted();
  print('Permission granted: $granted');
  
  // Test 3: Get position
  final position = await LocationService.getCurrentPosition();
  if (position != null) {
    print('Position: ${position.latitude}, ${position.longitude}');
  } else {
    print('Could not get position');
  }
  
  // Test 4: Calculate distance
  final distance = await LocationService.getDistance(
    startLatitude: 33.6844,
    startLongitude: 73.0479,
    endLatitude: 33.7298,
    endLongitude: 74.3382,
  );
  print('Distance: ${distance / 1000} km');
}
```

---

## 🎬 Common Scenarios

### Scenario 1: User Starts App
```dart
// In splash screen or main
await locationProvider.requestLocationPermission();
// User sees permission dialog
// App ready to track routes
```

### Scenario 2: User Plans Route
```dart
// In route selection screen
final position = await LocationService.getCurrentPosition();
if (position != null) {
  _originField.text = '${position.latitude}, ${position.longitude}';
  // Pre-filled with current location!
}
```

### Scenario 3: User Starts Trip
```dart
// In trip tracking screen
await locationProvider.startTracking();
locationProvider.setDestination(destLat, destLon, estimatedTravelTime: 1.5);
// Live updates showing distance and time remaining
// ETA updates as user moves
```

### Scenario 4: Trip Ends
```dart
// When user finishes or leaves screen
locationProvider.stopTracking();
var history = locationProvider.locationHistory;
// Save history to database for analysis
// Show trip summary
```

---

## ✅ Files You Created

1. **lib/services/location_service.dart** - GPS operations
2. **lib/providers/location_provider.dart** - Enhanced for real GPS
3. **LIVE_LOCATION_TRACKING.md** - Full setup guide
4. **PLATFORM_CONFIG_REFERENCE.md** - Exact configs to add
5. **LOCATION_TRACKING_INTEGRATION.md** - Screen code examples
6. **LOCATION_TRACKING_SUMMARY.md** - Implementation overview

---

## 🚨 Important Notes

- ⚠️ Always stop tracking when trip ends to save battery
- ⚠️ Test on real device, not simulator (GPS is limited on simulator)
- ⚠️ Request permission early in app lifecycle
- ⚠️ Handle permission denied case gracefully
- ⚠️ Consider battery impact when tuning accuracy

---

## 🎉 You're Ready!

All code is ready. Just:
1. Add platform configs (10 min)
2. Update screens with tracking code (30 min)  
3. Test on real device (15 min)
4. Deploy! 🚀


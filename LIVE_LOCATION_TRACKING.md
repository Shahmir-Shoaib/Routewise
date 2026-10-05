# Live Location Tracking Setup Guide

## Overview

Your RouteWise app now supports **real live location tracking** using the Geolocator package. This guide walks you through the setup process for both Android and iOS.

## What's Been Implemented

### New Components

1. **LocationService** (`lib/services/location_service.dart`)
   - Handles all GPS operations using Geolocator
   - Manages permissions and location updates
   - Provides one-time position and streaming updates

2. **Enhanced LocationProvider** (`lib/providers/location_provider.dart`)
   - Integrated with real GPS tracking
   - Automatic permission handling
   - Real-time location stream management
   - Error handling with user feedback

### Key Features

✅ Real-time GPS location updates every 2 seconds or 5 meters (whichever comes first)
✅ Accurate distance and direction calculations
✅ Automatic permission management
✅ Error handling and user feedback
✅ Location history tracking
✅ ETA and distance to destination updates

---

## Android Setup

### 1. Update `android/app/build.gradle.kts`

Ensure the minimum SDK is at least 21:

```gradle
android {
    compileSdk 34  // or higher
    
    defaultConfig {
        minSdk = 21  // Must be at least 21 for geolocator
        targetSdk = 34
    }
}
```

### 2. Update `android/app/src/main/AndroidManifest.xml`

Add location permissions:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Location Permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- For background location tracking (optional) -->
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    
    <application>
        <!-- Your app config -->
    </application>
</manifest>
```

### 3. Android 12+ (API 31+) Special Handling

For Android 12 and above, update `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
    <!-- Declare location access intent filter -->
    <intent-filter>
        <action android:name="android.location.ACCESS_FINE_LOCATION" />
    </intent-filter>
</application>
```

### 4. Gradle Properties

Ensure `android/gradle.properties` includes:

```properties
android.useAndroidX=true
org.gradle.jvmargs=-Xmx2048m
```

---

## iOS Setup

### 1. Update `ios/Runner/Info.plist`

Add location usage descriptions:

```xml
<dict>
    <!-- ... other keys ... -->
    
    <!-- Location Permissions -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>RouteWise needs your location to track your route and provide accurate ETA estimates</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>RouteWise needs your location to track your route and provide accurate ETA estimates</string>
    
    <key>NSLocationAlwaysUsageDescription</key>
    <string>RouteWise needs background location access to track your route</string>
    
    <!-- Bluetooth (if you use it) -->
    <key>NSBluetoothAlwaysAndWhenInUseUsageDescription</key>
    <string>RouteWise uses Bluetooth to connect to your car's system for better navigation</string>
</dict>
```

### 2. Update Podfile (if needed)

Ensure the minimum deployment target is 11.0 or higher:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_LOCATION=1',
      ]
    end
  end
end
```

### 3. Enable Background Location (Optional)

If you need background location tracking, add to `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

---

## Usage in Your Screens

### Example: Trip Tracking Screen

```dart
import 'package:provider/provider.dart';
import 'package:routewise/providers/location_provider.dart';

class TripTrackingScreen extends StatefulWidget {
  @override
  State<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends State<TripTrackingScreen> {
  @override
  void initState() {
    super.initState();
    _initializeLocationTracking();
  }

  Future<void> _initializeLocationTracking() async {
    final locationProvider = context.read<LocationProvider>();
    
    // Request permission
    await locationProvider.requestLocationPermission();
    
    if (locationProvider.permissionStatus == 'granted') {
      // Start tracking
      await locationProvider.startTracking();
      
      // Set destination (example)
      locationProvider.setDestination(
        33.7298,  // Destination latitude
        74.3382,  // Destination longitude
        estimatedTravelTime: 1.5,  // hours
      );
    } else {
      // Handle permission denied
      _showPermissionDialog(locationProvider);
    }
  }

  void _showPermissionDialog(LocationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: Text(provider.trackingError ?? 'Unable to access location'),
        actions: [
          TextButton(
            onPressed: () {
              if (provider.permissionStatus == 'serviceDisabled') {
                LocationService.openLocationSettings();
              } else if (provider.permissionStatus == 'deniedForever') {
                LocationService.openAppSettings();
              }
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Tracking')),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          if (locationProvider.currentLocation == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final location = locationProvider.currentLocation!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Current Location
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current Location',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text('Latitude: ${location.latitude.toStringAsFixed(6)}'),
                        Text('Longitude: ${location.longitude.toStringAsFixed(6)}'),
                        Text('Accuracy: ${location.accuracy?.toStringAsFixed(1)}m'),
                        Text('Speed: ${location.speed?.toStringAsFixed(1)}km/h'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Trip Metrics
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Trip Progress',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text('Distance to Destination: '
                            '${locationProvider.distanceToDestination.toStringAsFixed(1)}km'),
                        Text('Estimated Time: '
                            '${locationProvider.estimatedTimeRemaining.toStringAsFixed(1)} min'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<LocationProvider>().stopTracking();
        },
        child: const Icon(Icons.stop),
      ),
    );
  }

  @override
  void dispose() {
    context.read<LocationProvider>().stopTracking();
    super.dispose();
  }
}
```

### Example: Initial Trip Setup

```dart
// Request location permission early in your app
Future<void> requestLocationOnAppStart() async {
  final locationProvider = context.read<LocationProvider>();
  await locationProvider.requestLocationPermission();
  
  if (locationProvider.permissionStatus == 'granted') {
    // Get user's current location immediately
    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      print('Current location: ${position.latitude}, ${position.longitude}');
      // Use this to pre-fill origin location in route planning
    }
  }
}
```

---

## Error Handling

The LocationProvider now provides error information:

```dart
Consumer<LocationProvider>(
  builder: (context, provider, _) {
    if (provider.trackingError != null) {
      return ErrorBanner(
        message: provider.trackingError!,
        onRetry: () => provider.requestLocationPermission(),
      );
    }
    return YourContent();
  },
)
```

### Permission Status Values

- `'notRequested'` - Permission dialog not shown yet
- `'granted'` - Location access granted
- `'denied'` - User denied permission
- `'deniedForever'` - User denied permission permanently (must open settings)
- `'serviceDisabled'` - Location services disabled on device
- `'error'` - An error occurred

---

## Common Issues & Solutions

### Issue: "Permission denied" on Android

**Solution**: Make sure you've added permissions to `AndroidManifest.xml` and the app is being tested on a device/emulator with location enabled.

### Issue: Slow location updates

**Solution**: The update interval is set to 2 seconds with 5-meter distance filter. Adjust in `startTracking()`:

```dart
LocationService().getPositionStream(
  accuracy: LocationAccuracy.best,
  distanceFilter: 10,  // Increase for less frequent updates
  updateInterval: const Duration(seconds: 5),  // Increase for longer intervals
)
```

### Issue: "Location services disabled" message

**Solution**: User must enable location services in device settings.

### Issue: High battery drain

**Solution**: 
- Increase `distanceFilter` to 20-50 meters
- Increase `updateInterval` to 5-10 seconds
- Use `LocationAccuracy.medium` instead of `.best`
- Call `stopTracking()` when not needed

### Issue: Inaccurate location on emulator

**Solution**: 
- Use Android Emulator's "Extended Controls" > "Location" to simulate movement
- Or use mock location app on real device
- Production devices will have accurate GPS

---

## Location History & Route Tracking

The LocationProvider now automatically maintains location history:

```dart
// Access location history
final history = locationProvider.locationHistory;

// Clear history when trip ends
locationProvider.clearHistory();

// Save to database for trip replay
for (var location in history) {
  var locationMap = location.toMap();
  // Save to Firestore or local database
}
```

---

## Battery Optimization Tips

1. **Stop tracking when not needed**
   ```dart
   locationProvider.stopTracking();
   ```

2. **Use appropriate accuracy**
   - `LocationAccuracy.best` - Maximum accuracy (highest battery drain)
   - `LocationAccuracy.high` - Good balance
   - `LocationAccuracy.medium` - Less accurate but saves battery
   - `LocationAccuracy.low` - Minimum accuracy (lowest battery drain)

3. **Increase distance filter**
   - Default: 5 meters
   - For fuel efficiency tracking: 20-50 meters

4. **Increase update interval**
   - Default: 2 seconds
   - For less critical tracking: 5-10 seconds

---

## Testing Location Tracking

### On Android Emulator

1. Open Android Emulator Extended Controls (right panel)
2. Go to "Location"
3. Enter coordinates and simulate movement

### On iOS Simulator

1. In Xcode, go to Debug > Simulate Location
2. Select a preset location or create custom route

### On Real Device

1. Enable location services in device settings
2. Make sure app has location permission
3. Test in a real vehicle with actual GPS

---

## Next Steps

1. ✅ Install dependencies (already done)
2. ✅ Create LocationService (already done)
3. ✅ Update LocationProvider (already done)
4. 📋 Configure Android manifest
5. 📋 Configure iOS Info.plist
6. 📋 Update trip screens to use real location tracking
7. 📋 Test on real device

For questions or issues, check the [Flutter Geolocator documentation](https://pub.dev/packages/geolocator).

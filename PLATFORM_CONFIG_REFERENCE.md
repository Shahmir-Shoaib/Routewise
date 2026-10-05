# Platform Configuration Reference

This file contains the exact code snippets to add to your platform-specific configuration files.

## Android Configuration

### Update: `android/app/src/main/AndroidManifest.xml`

Add these permissions inside the `<manifest>` tag (BEFORE the `<application>` tag):

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add these location permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <!-- Optional: for background location tracking -->
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    
    <application>
        <!-- Your existing application configuration -->
    </application>
</manifest>
```

### Update: `android/app/build.gradle.kts`

Ensure minimum SDK is 21:

```kotlin
android {
    compileSdk 34
    
    defaultConfig {
        applicationId = "com.routewise.app"
        minSdk = 21  // ← Make sure this is 21 or higher
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }
}
```

---

## iOS Configuration

### Update: `ios/Runner/Info.plist`

Add these keys inside the root `<dict>` tag:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... other existing keys ... -->
    
    <!-- Location Usage Descriptions -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>RouteWise needs your location to track your route and provide accurate navigation and ETA estimates while you're actively using the app</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>RouteWise needs your location to track your route and provide accurate navigation and ETA estimates</string>
    
    <key>NSLocationAlwaysUsageDescription</key>
    <string>RouteWise needs background location access to continue tracking your route and fuel consumption even when the app is in the background</string>
    
    <!-- If using background location -->
    <key>UIBackgroundModes</key>
    <array>
        <string>location</string>
    </array>
    
    <!-- Other existing keys ... -->
</dict>
</plist>
```

### Update: `ios/Podfile` (if custom configuration needed)

If you need to specify deployment target, ensure it's 11.0 or higher:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # Ensure minimum deployment target
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
```

---

## Web Configuration (Flutter Web)

For web, location requires HTTPS in production. In development, add to your `web/index.html`:

```html
<script>
  if (!window.location.protocol === 'https:' && window.location.hostname !== 'localhost') {
    console.warn('Geolocation requires HTTPS in production');
  }
</script>
```

---

## Verification Checklist

### Android
- [ ] Added `ACCESS_FINE_LOCATION` permission
- [ ] Added `ACCESS_COARSE_LOCATION` permission
- [ ] Set `minSdk = 21` in build.gradle.kts
- [ ] Tested on device/emulator

### iOS
- [ ] Added `NSLocationWhenInUseUsageDescription`
- [ ] Added `NSLocationAlwaysAndWhenInUseUsageDescription`
- [ ] Deployment target is 11.0+
- [ ] Tested on simulator/device

### Code
- [ ] Created `lib/services/location_service.dart`
- [ ] Updated `lib/providers/location_provider.dart`
- [ ] Imported `LocationService` in screens where needed
- [ ] Called `requestLocationPermission()` before starting trip

---

## After Configuration

Run the following commands:

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# For Android
flutter run

# For iOS
cd ios
pod install
cd ..
flutter run

# Or build for Android
flutter build apk

# Or build for iOS
flutter build ios
```

---

## Testing the Implementation

### Test Script

```dart
import 'package:routewise/services/location_service.dart';
import 'package:routewise/providers/location_provider.dart';

// Quick test to verify location tracking works
void testLocationTracking() async {
  // 1. Check if location services are enabled
  final enabled = await LocationService.isLocationServiceEnabled();
  print('Location services enabled: $enabled');
  
  // 2. Request permission
  final permission = await LocationService.requestLocationPermission();
  print('Permission: $permission');
  
  // 3. Get current position
  final position = await LocationService.getCurrentPosition();
  if (position != null) {
    print('Current position: ${position.latitude}, ${position.longitude}');
  }
  
  // 4. Get distance calculation
  final distance = await LocationService.getDistance(
    startLatitude: position?.latitude ?? 33.6844,
    startLongitude: position?.longitude ?? 73.0479,
    endLatitude: 33.7298,
    endLongitude: 74.3382,
  );
  print('Distance to destination: ${distance / 1000} km');
}
```

---

## Troubleshooting Checklist

### "Permission Denied" on Android
- [ ] Check `AndroidManifest.xml` has location permissions
- [ ] Device location is enabled in settings
- [ ] App has location permission granted in app settings
- [ ] `minSdk` is 21 or higher

### "Permission Denied" on iOS
- [ ] Check `Info.plist` has location usage descriptions
- [ ] User allowed location access when prompted
- [ ] Location services enabled on device
- [ ] Go to Settings > RouteWise and check location permission

### Location not updating
- [ ] Check `isTrackingEnabled` is true in LocationProvider
- [ ] Device has GPS signal (outdoors, clear sky)
- [ ] Test on real device (simulators have limited accuracy)
- [ ] Check `distanceFilter` isn't set too high (default 5m is good)

### App crashes with geolocator
- [ ] Run `flutter clean`
- [ ] Delete `pubspec.lock`
- [ ] Run `flutter pub get`
- [ ] Rebuild app


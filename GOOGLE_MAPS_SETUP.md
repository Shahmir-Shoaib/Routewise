# Google Maps API Setup Guide for RouteWise

## Overview
RouteWise now integrates Google Maps API for real route calculation, distance matrix, and place suggestions. This guide will help you set up your Google Maps API key.

## Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Click on the project dropdown and select **"NEW PROJECT"**
3. Enter project name: `RouteWise` (or your preference)
4. Click **CREATE**
5. Wait for the project to be created and select it

## Step 2: Enable Required APIs

Enable the following APIs for your project:

1. **Maps SDK for Android**
   - Search "Maps SDK for Android"
   - Click **ENABLE**

2. **Maps SDK for iOS**
   - Search "Maps SDK for iOS"
   - Click **ENABLE**

3. **Google Maps Platform**
   - Search "Directions API"
   - Click **ENABLE**
   - Search "Distance Matrix API"
   - Click **ENABLE**
   - Search "Places API"
   - Click **ENABLE**

## Step 3: Create API Key

1. Go to **Credentials** in the left sidebar
2. Click **+ CREATE CREDENTIALS**
3. Select **API Key**
4. Copy your API key (you'll need this)

### Restrict Your API Key (Recommended)

For security, restrict your key:

1. Click on your newly created API key
2. Under **Application restrictions**, select "Android apps" or "iOS apps"
3. Add your app's package name:
   - Android: `com.example.routewise` (or your package name)
   - iOS: `com.example.routewise` (or your bundle ID)
4. Click **SAVE**

## Step 4: Add API Key to Flutter App

### Android Setup

1. Open `android/app/src/main/AndroidManifest.xml`
2. Add this inside the `<application>` tag:

```xml
<application>
    ...
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_GOOGLE_MAPS_API_KEY" />
    ...
</application>
```

### iOS Setup

1. Open `ios/Runner/GeneratedPluginRegistrant.m`
2. Or add to `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(as: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Web Setup (if needed)

1. Open `web/index.html`
2. Add before closing `</head>` tag:

```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_GOOGLE_MAPS_API_KEY"></script>
```

## Step 5: Update RouteWise Code

Open `lib/services/google_maps_service.dart` and replace:

```dart
static const String _googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
```

With your actual API key:

```dart
static const String _googleMapsApiKey = 'AIzaSyD...';
```

## Step 6: Run `flutter pub get`

In your project root:

```bash
flutter pub get
```

## Step 7: Test the Integration

1. Run your app on an emulator or physical device:
   ```bash
   flutter run
   ```

2. Navigate to the **Vehicle Selection** → **Route Input** screens
3. Enter a source and destination
4. The app should now fetch real routes from Google Maps API

## Troubleshooting

### "Failed to initialize Maps" Error
- Ensure your API key is correctly added to AndroidManifest.xml or AppDelegate.swift
- Check that APIs are enabled in Google Cloud Console
- Clear app cache and rebuild

### "No routes found" Error
- Verify source and destination are valid location names
- Try with city names (e.g., "Islamabad" instead of exact address)
- Check API quotas in Google Cloud Console

### API Key Not Working
- Go back to Google Cloud Console
- Check if the API key restrictions match your app's package name
- Ensure billing is enabled for your Google Cloud project

## Costs

**Note**: Google Maps API calls are subject to billing after free tier quota:
- **Directions API**: $5 per 1000 requests
- **Distance Matrix API**: $5 per 1000 requests
- **Places API**: $7 per 1000 requests
- **First 28,500 calls/month are free**

Monitor your usage in Google Cloud Console to avoid unexpected charges.

## Features Now Available

✅ **Real Route Calculation** - Multiple optimized routes between locations
✅ **Distance & Time Estimation** - Accurate travel time and distance
✅ **Place Autocomplete** - Search for locations with suggestions  
✅ **Route Polylines** - Display exact routes on map
✅ **Cost Breakdown** - Fuel, toll, and total cost calculations

## Next Steps

- Integrate Google Maps widget for visual route display
- Add real-time traffic conditions
- Implement toll booth detection
- Add route optimization by time/cost/distance
- Store frequently used routes locally

For more info: [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)

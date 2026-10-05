# Google Maps Integration - Complete Guide

## What's Been Integrated

✅ **Google Maps API Service** - Backend API calls for routes, directions, and places
✅ **Google Maps Widget** - Reusable map component for displaying routes
✅ **Enhanced Route Service** - Automatic Google Maps integration with fallback to mock data
✅ **Setup Documentation** - Complete step-by-step setup guide

## Files Added/Modified

### New Files Created:
1. **`lib/services/google_maps_service.dart`**
   - Core service for Google Maps API calls
   - Methods: `getDirections()`, `getDistance()`, `searchPlaces()`, `calculateRoutes()`
   - Data classes: `RouteData`, `RouteMetrics`
   - Fallback mechanisms for failed API calls

2. **`lib/widgets/google_map_widget.dart`**
   - Reusable Google Maps widget component
   - Helper classes: `MapMarkerBuilder`, `MapPolylineBuilder`, `MapCameraHelper`
   - Supports markers, polylines, and camera animations

3. **`GOOGLE_MAPS_SETUP.md`**
   - Complete setup guide with screenshots
   - Step-by-step Google Cloud setup
   - Platform-specific configuration
   - Cost and billing information

### Modified Files:
1. **`pubspec.yaml`**
   - Added: `google_maps_webservice: ^6.2.0`

2. **`lib/services/route_service.dart`**
   - Enhanced with Google Maps integration
   - Automatic API fallback to mock data if API fails
   - Seamless switch between real and mock routes

## How to Use

### 1. Add Your API Key (REQUIRED)

Open `lib/services/google_maps_service.dart` and replace:
```dart
static const String _googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
```

Get your API key by following `GOOGLE_MAPS_SETUP.md`

### 2. Using Google Maps in Screens

#### Example 1: Display Map with Route

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/google_map_widget.dart';

// Create markers for source and destination
Set<Marker> markers = {
  MapMarkerBuilder.createMarker(
    position: LatLng(33.6844, 73.0479), // Islamabad
    markerId: 'source',
    title: 'Source',
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueBlue,
    ),
  ),
  MapMarkerBuilder.createMarker(
    position: LatLng(31.5204, 74.3587), // Lahore
    markerId: 'destination',
    title: 'Destination',
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueRed,
    ),
  ),
};

// Create polyline from encoded string (from Google Maps API)
Set<Polyline> polylines = {
  MapPolylineBuilder.createPolyline(
    points: MapPolylineBuilder.decodePolyline(encodedPolylineString),
    polylineId: 'route',
  ),
};

// Use the widget
GoogleMapWidget(
  initialPosition: LatLng(33.6844, 73.0479),
  destinationPosition: LatLng(31.5204, 74.3587),
  markers: markers,
  polylines: polylines,
  height: 400,
)
```

#### Example 2: Get Real Routes

```dart
import '../../services/google_maps_service.dart';

// In your provider or screen
try {
  final routes = await GoogleMapsService.calculateRoutes(
    origin: 'Islamabad, Pakistan',
    destination: 'Lahore, Pakistan',
    fuelAverage: 10.5,
  );
  
  for (var route in routes) {
    print('Route: ${route.name}');
    print('Distance: ${route.distance} km');
    print('Time: ${route.estimatedTime} hours');
    print('Cost: PKR ${route.totalCost}');
  }
} catch (e) {
  print('Error: $e');
}
```

#### Example 3: Search Places

```dart
// Autocomplete for location input
var predictions = await GoogleMapsService.getPlacePredictions('Islamabad');

for (var prediction in predictions?.predictions ?? []) {
  print(prediction.mainText);
  print(prediction.secondaryText);
}
```

### 3. Integration in Existing Screens

The route service automatically uses Google Maps when available:

```dart
// In RouteProvider
Future<bool> searchRoutes(Vehicle? vehicle, double fuelAverage) async {
  // This now calls Google Maps API automatically
  // Falls back to mock data if API fails
  final routes = await _routeService.getRoutes(
    _source,
    _destination,
    vehicle,
    fuelAverage,
  );
  
  _availableRoutes = routes;
  notifyListeners();
  return true;
}
```

## Web Services Methods

### `calculateRoutes()`
Calculate multiple optimized routes between two locations
```dart
Future<List<RouteData>> calculateRoutes({
  required String origin,
  required String destination,
  required double fuelAverage,
})
```

**Returns:** List of routes with:
- Distance (km)
- Estimated time (hours)
- Fuel cost (PKR)
- Toll charges (PKR)
- Encoded polyline for map display

### `getDirections()`
Get turn-by-turn directions
```dart
Future<DirectionsResponse?> getDirections({
  required String origin,
  required String destination,
})
```

### `getDistance()`
Get distance matrix between locations
```dart
Future<DistanceMatrixResponse?> getDistance({
  required String origin,
  required String destination,
})
```

### `searchPlaces()`
Search for places by text query
```dart
Future<PlacesSearchResponse?> searchPlaces(String query)
```

### `getPlacePredictions()`
Autocomplete predictions for location input
```dart
Future<PlacesAutocompleteResponse?> getPlacePredictions(String input)
```

## Architecture Flow

```
RouteInputScreen (User Input)
         ↓
    RouteProvider
         ↓
    RouteService
         ↓
   Google Maps API (or Mock Data fallback)
         ↓
   Route Objects with Polylines
         ↓
  ComparisonScreen (Display Routes)
         ↓
   GoogleMapWidget (Show Map)
```

## Error Handling

The integration includes automatic fallback:

1. **Google Maps API fails** → Falls back to mock route data
2. **Location not found** → Returns "No routes available" error
3. **Network error** → User sees retry option with error explanation

## Testing Without API Key

To test without a valid API key:
1. Comment out the API key requirement
2. The app will use mock data automatically
3. All screens will work with sample routes

## Performance Optimization

- Polylines are encoded (smaller data size)
- Routes are cached in providers
- API requests include proper error handling
- Fallback mechanism prevents app crashes

## Next Steps to Enhance

1. **Map Display on Comparison Screen**
   ```dart
   // Show Google Map with all routes as different colored polylines
   ```

2. **Real-time Tracking**
   ```dart
   // Display live location on map with route progress
   ```

3. **Traffic Layer**
   ```dart
   // Show real-time traffic and adjust ETA
   ```

4. **Toll Booth Detection**
   ```dart
   // Mark toll booths on the route polyline
   ```

5. **Route Optimization**
   ```dart
   // Offer routes optimized by: time, cost, distance
   ```

6. **Place Autocomplete TextField**
   ```dart
   // Replace text input with autocomplete location search
   ```

## Important Notes

⚠️ **API Key Security:**
- Never commit API key to GitHub
- Use environment variables for production
- Restrict API key to your app package names
- Monitor usage in Google Cloud Console

⚠️ **Billing:**
- First 28,500 requests per month are free
- After that: ~$5 per 1000 requests
- Enable billing alerts in Google Cloud Console

## Troubleshooting

### Maps not showing
- Verify API key is correct in `google_maps_service.dart`
- Check that APIs are enabled in Google Cloud Console
- Rebuild app: `flutter clean && flutter pub get && flutter run`

### Routes not calculating
- Ensure location names are recognized by Google Maps
- Try more specific location names (City, Country)
- Check network connection

### API limit reached
- Check usage in Google Cloud Console
- Wait for next billing cycle or upgrade plan
- Implement caching to reduce API calls

## Support

For Google Maps API issues: https://developers.google.com/maps/documentation
For Flutter Google Maps: https://pub.dev/packages/google_maps_flutter

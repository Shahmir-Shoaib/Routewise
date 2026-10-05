import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;
import '../core/contants/app_colors.dart';

class GoogleMapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final LatLng? destinationPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Function(GoogleMapController)? onMapCreated;
  final double height;
  final bool showMyLocationButton;

  const GoogleMapWidget({
    required this.initialPosition,
    this.destinationPosition,
    this.markers = const {},
    this.polylines = const {},
    this.onMapCreated,
    this.height = 400,
    this.showMyLocationButton = true,
    super.key,
  });

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late GoogleMapController _mapController;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GoogleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destinationPosition != widget.destinationPosition &&
        widget.destinationPosition != null) {
      _animateToLocation(widget.destinationPosition!);
    }
  }

  Future<void> _animateToLocation(LatLng location) async {
    await _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(location, 15.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialPosition,
          zoom: 15.0,
        ),
        markers: widget.markers,
        polylines: widget.polylines,
        onMapCreated: (controller) {
          _mapController = controller;
          widget.onMapCreated?.call(controller);
        },
        myLocationEnabled: widget.showMyLocationButton,
        myLocationButtonEnabled: widget.showMyLocationButton,
        zoomControlsEnabled: true,
        mapToolbarEnabled: true,
        compassEnabled: true,
        trafficEnabled: false,
        liteModeEnabled: false,
      ),
    );
  }
}

/// Helper class for creating map markers
class MapMarkerBuilder {
  static Marker createMarker({
    required LatLng position,
    required String markerId,
    String? title,
    String? snippet,
    BitmapDescriptor? icon,
  }) {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
      icon: icon ?? BitmapDescriptor.defaultMarker,
    );
  }

  static Future<BitmapDescriptor> createCustomMarker({
    required String label,
    required Color color,
  }) async {
    return BitmapDescriptor.defaultMarkerWithHue(
      _getHueFromColor(color),
    );
  }

  static double _getHueFromColor(Color color) {
    // Simple hue calculation (values between 0 and 360)
    final hslColor = HSLColor.fromColor(color);
    return hslColor.hue;
  }

  // Predefined marker colors
  static const Color sourceColor = AppColors.primary; // Primary blue
  static const Color destinationColor = Color(0xFFFF6B6B); // Red
  static const Color waypointColor = AppColors.accent; // Orange
}

/// Helper class for creating polylines
class MapPolylineBuilder {
  static Polyline createPolyline({
    required List<LatLng> points,
    required String polylineId,
    Color color = AppColors.primary,
    int width = 5,
    bool geodesic = true,
  }) {
    return Polyline(
      polylineId: PolylineId(polylineId),
      points: points,
      color: color,
      width: width,
      geodesic: geodesic,
    );
  }

  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polylinePoints = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int result = 0;
      int shift = 0;
      int b;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      result = 0;
      shift = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      double latitude = lat / 1e5;
      double longitude = lng / 1e5;

      polylinePoints.add(LatLng(latitude, longitude));
    }

    return polylinePoints;
  }
}

/// Helper class for camera animations
class MapCameraHelper {
  static Future<void> animateToLocation(
    GoogleMapController controller,
    LatLng location,
  ) async {
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(location, 15.0),
    );
  }

  static Future<void> animateToMultipleLocations(
    GoogleMapController controller,
    List<LatLng> locations,
  ) async {
    if (locations.isEmpty) return;

    if (locations.length == 1) {
      await animateToLocation(controller, locations[0]);
      return;
    }

    // Create bounds that include all locations
    double minLat = locations[0].latitude;
    double maxLat = locations[0].latitude;
    double minLng = locations[0].longitude;
    double maxLng = locations[0].longitude;

    for (LatLng location in locations) {
      minLat = math.min(minLat, location.latitude);
      maxLat = math.max(maxLat, location.latitude);
      minLng = math.min(minLng, location.longitude);
      maxLng = math.max(maxLng, location.longitude);
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }
}

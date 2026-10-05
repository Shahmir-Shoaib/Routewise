import 'package:flutter/material.dart' hide Route;
import '../../core/contants/app_colors.dart';

import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/location_provider.dart';
import '../../providers/route_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/error_handler.dart';
import '../../core/utils/responsive_helper.dart';
import '../../widgets/google_map_widget.dart';

class TripTrackingScreen extends StatefulWidget {
  const TripTrackingScreen({super.key});

  @override
  State<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends State<TripTrackingScreen> {
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  void _initializeTracking() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    try {
      await locationProvider.requestLocationPermission();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackbar(
          context,
          ErrorHandler.getLocationErrorMessage('LOCATION_PERMISSION_DENIED'),
        );
      }
    }
  }

  void _startTrip() {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);

    if (routeProvider.selectedRoute != null) {
      final route = routeProvider.selectedRoute!;
      locationProvider.startTracking();
      locationProvider.setDestination(
        33.7412,
        74.2080, // Mock destination coordinates (Lahore)
        estimatedTravelTime: route.estimatedTime,
      );
      setState(() {
        _isTracking = true;
      });
    }
  }

  void _endTrip() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Dialog(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
                SizedBox(height: 16),
                Text('Saving trip details...'),
              ],
            ),
          ),
        ),
      );
    }

    try {
      // Get userId from AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.uid ?? 'anonymous';

      // Save trip data with userId
      await tripProvider.saveTrip(
        {
          'route': routeProvider.selectedRoute?.toMap(),
          'distance': routeProvider.selectedRoute?.distance,
          'estimatedTime': routeProvider.selectedRoute?.estimatedTime,
          'timestamp': DateTime.now().toIso8601String(),
        },
        userId,
      );

      locationProvider.stopTracking();
      setState(() {
        _isTracking = false;
      });

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip completed! View details in Trip Summary.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving trip: $e'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Trip Tracking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer3<LocationProvider, RouteProvider, TripProvider>(
        builder: (context, locationProvider, routeProvider, tripProvider, _) {
          if (routeProvider.selectedRoute == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.directions_car,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No active trip",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Select a route and start a trip to track",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.compare),
                      label: const Text("Find Routes"),
                    ),
                  ],
                ),
              ),
            );
          }

          final route = routeProvider.selectedRoute!;
          final distance = locationProvider.distanceToDestination;
          final eta = locationProvider.estimatedTimeRemaining;
          final currentLocation = locationProvider.currentLocation;

          // Calculate progress percentage
          double progressPercent = 0;
          if (route.distance > 0) {
            progressPercent =
                ((route.distance - distance) / route.distance).clamp(0.0, 1.0);
          }

          return SingleChildScrollView(
            padding: ResponsiveHelper.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isTracking
                          ? [AppColors.primary, AppColors.primaryLight]
                          : [const Color(0xFFB0B0B0), const Color(0xFF9E9E9E)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              route.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _isTracking ? 'IN PROGRESS' : 'READY',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (ResponsiveHelper.isMobile(context))
                        Column(
                          children: [
                            _statusColumn(
                                '${(progressPercent * 100).toStringAsFixed(0)}%',
                                'Complete',
                                Colors.white),
                            const SizedBox(height: 12),
                            _statusColumn('${distance.toStringAsFixed(1)} km',
                                'Remaining', Colors.white),
                            const SizedBox(height: 12),
                            _statusColumn('${eta.toStringAsFixed(1)} hrs',
                                'ETA', Colors.white),
                          ],
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statusColumn(
                                '${(progressPercent * 100).toStringAsFixed(0)}%',
                                'Complete',
                                Colors.white),
                            _statusColumn('${distance.toStringAsFixed(1)} km',
                                'Remaining', Colors.white),
                            _statusColumn('${eta.toStringAsFixed(1)} hrs',
                                'ETA', Colors.white),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Trip Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(progressPercent * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isTracking ? AppColors.primary : Colors.grey[400]!,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Current Location
                if (currentLocation != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.my_location,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Current Location',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _locationRow('Latitude',
                            currentLocation.latitude.toStringAsFixed(4)),
                        const SizedBox(height: 8),
                        _locationRow('Longitude',
                            currentLocation.longitude.toStringAsFixed(4)),
                        if (currentLocation.speed != null) ...[
                          const SizedBox(height: 8),
                          _locationRow('Speed',
                              '${currentLocation.speed!.toStringAsFixed(1)} km/h'),
                        ],
                        if (currentLocation.accuracy != null) ...[
                          const SizedBox(height: 8),
                          _locationRow('Accuracy',
                              '±${currentLocation.accuracy!.toStringAsFixed(1)} m'),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Trip Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trip Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _detailRow('Total Distance',
                          '${route.distance.toStringAsFixed(1)} km'),
                      _detailRow('Estimated Time',
                          '${route.estimatedTime.toStringAsFixed(1)} hours'),
                      _detailRow('Speed (Avg)',
                          '${(route.distance / route.estimatedTime).toStringAsFixed(1)} km/h'),
                      const Divider(),
                      _detailRow('Fuel Cost',
                          'PKR ${route.fuelCost.toStringAsFixed(0)}'),
                      _detailRow('Toll Charges',
                          'PKR ${route.tollCharges.toStringAsFixed(0)}'),
                      _detailRow('Total Cost',
                          'PKR ${route.totalCost.toStringAsFixed(0)}',
                          isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Route Map
                if (route.encodedPolyline.isNotEmpty)
                  SizedBox(
                    height: 280,
                    width: double.infinity,
                    child: GoogleMapWidget(
                      initialPosition: MapPolylineBuilder.decodePolyline(
                              route.encodedPolyline)
                          .firstWhere(
                        (p) => true,
                        orElse: () => const LatLng(33.6844, 73.0479),
                      ),
                      markers: currentLocation != null
                          ? {
                              Marker(
                                markerId: const MarkerId('current_location'),
                                position: LatLng(
                                  currentLocation.latitude,
                                  currentLocation.longitude,
                                ),
                                infoWindow: const InfoWindow(
                                  title: 'Current Location',
                                ),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueBlue,
                                ),
                              ),
                            }
                          : {},
                      polylines: {
                        Polyline(
                          polylineId: PolylineId('active_route_${route.id}'),
                          points: MapPolylineBuilder.decodePolyline(
                              route.encodedPolyline),
                          width: 6,
                          color: AppColors.primary,
                          geodesic: true,
                        ),
                      },
                      height: 280,
                      showMyLocationButton: true,
                    ),
                  )
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Route map not available'),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Control Buttons
                if (!_isTracking)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startTrip,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Trip'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                else if (ResponsiveHelper.isMobile(context))
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            locationProvider.stopTracking();
                            locationProvider.startTracking();
                            // Restart tracking
                          },
                          icon: const Icon(Icons.pause),
                          label: const Text('Pause'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: tripProvider.isLoading ? null : _endTrip,
                          icon: tripProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.stop),
                          label: const Text('End Trip'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            locationProvider.stopTracking();
                            locationProvider.startTracking();
                          },
                          icon: const Icon(Icons.pause),
                          label: const Text('Pause'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: tripProvider.isLoading ? null : _endTrip,
                          icon: tripProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.stop),
                          label: const Text('End Trip'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _locationRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 15 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 15 : 14,
              color: isBold ? AppColors.primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_isTracking) {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      locationProvider.stopTracking();
    }
    super.dispose();
  }
}

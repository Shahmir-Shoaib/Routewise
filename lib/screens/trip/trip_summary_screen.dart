import 'package:flutter/material.dart' hide Route;
import '../../core/contants/app_colors.dart';

import 'package:provider/provider.dart';
import '../../providers/route_provider.dart';
import '../../widgets/google_map_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripSummaryScreen extends StatefulWidget {
  const TripSummaryScreen({super.key});

  @override
  State<TripSummaryScreen> createState() => _TripSummaryScreenState();
}

class _TripSummaryScreenState extends State<TripSummaryScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Trip Summary'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Consumer<RouteProvider>(
        builder: (context, routeProvider, _) {
          if (routeProvider.selectedRoute == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No trip data",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Trip summary will appear after completing a trip",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.directions_car),
                      label: const Text("Start a Trip"),
                    ),
                  ],
                ),
              ),
            );
          }

          final route = routeProvider.selectedRoute!;

          // Mock actual trip data (in real implement, this would come from TripHistoryProvider)
          final actualTime = route.estimatedTime * 0.85; // 15% faster
          final actualCost = route.totalCost * 0.90; // 10% cheaper
          final timeSaved = route.estimatedTime - actualTime;
          final costSaved = route.totalCost - actualCost;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary,
                        Color(0xFF6C8FFF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Trip Completed!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${route.source} → ${route.destination}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Key Metrics
                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        title: 'Time Saved',
                        value: timeSaved.toStringAsFixed(1),
                        unit: 'hours',
                        icon: Icons.timer,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _metricCard(
                        title: 'Cost Saved',
                        value: costSaved.toStringAsFixed(0),
                        unit: 'PKR',
                        icon: Icons.savings,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Map (selected route polyline)
                if (route.encodedPolyline.isNotEmpty)
                  SizedBox(
                    height: 240,
                    width: double.infinity,
                    child: GoogleMapWidget(
                      initialPosition: MapPolylineBuilder.decodePolyline(
                              route.encodedPolyline)
                          .firstWhere(
                        (p) => true,
                        orElse: () => const LatLng(33.6844, 73.0479),
                      ),
                      markers: const {},
                      polylines: {
                        Polyline(
                          polylineId: PolylineId('selected_${route.id}'),
                          points: MapPolylineBuilder.decodePolyline(
                              route.encodedPolyline),
                          width: 6,
                          color: AppColors.primary,
                          geodesic: true,
                        ),
                      },
                      height: 240,
                      showMyLocationButton: false,
                    ),
                  )
                else
                  const SizedBox(height: 240),

                // Trip Details
                Container(
                  padding: const EdgeInsets.all(20),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _detailRow('Route', route.name, AppColors.primary),
                      const SizedBox(height: 12),
                      _detailRow('Distance',
                          '${route.distance.toStringAsFixed(1)} km'),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        'Time Comparison',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _comparisonRow(
                        'Estimated',
                        '${route.estimatedTime.toStringAsFixed(1)} hours',
                        Colors.grey,
                      ),
                      _comparisonRow(
                        'Actual',
                        '${actualTime.toStringAsFixed(1)} hours',
                        AppColors.secondary,
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        'Cost Breakdown',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _costRow('Fuel Cost',
                          'PKR ${route.fuelCost.toStringAsFixed(0)}'),
                      _costRow('Toll Charges',
                          'PKR ${route.tollCharges.toStringAsFixed(0)}'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _costRow(
                          'Estimated Total',
                          'PKR ${route.totalCost.toStringAsFixed(0)}',
                          isBold: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.secondary.withOpacity(0.3)),
                        ),
                        child: _costRow(
                          'Actual Total',
                          'PKR ${actualCost.toStringAsFixed(0)}',
                          color: AppColors.secondary,
                          isBold: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.accent.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'You Saved',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.accent,
                              ),
                            ),
                            Text(
                              'PKR ${costSaved.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Route Details Expandable
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
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Route Segments',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              _isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      if (_isExpanded) ...[
                        const SizedBox(height: 16),
                        ...route.route.asMap().entries.map((entry) {
                          int index = entry.key;
                          String segment = entry.value;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary.withOpacity(0.1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  segment,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (route.tollBooths.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          const Text(
                            'Toll Booths',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...route.tollBooths.asMap().entries.map((entry) {
                            int index = entry.key;
                            String booth = entry.value;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.toll,
                                    size: 18,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${index + 1}. $booth',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Receipt sent to your email'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download Receipt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Back to Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
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
            unit,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, [Color? highlightColor]) {
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: highlightColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _comparisonRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _costRow(String label, String value,
      {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 15 : 14,
            color: color ?? Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 15 : 14,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

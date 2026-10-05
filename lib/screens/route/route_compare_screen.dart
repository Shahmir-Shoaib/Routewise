import 'package:flutter/material.dart' hide Route;
import 'package:provider/provider.dart';
import '../../core/contants/app_colors.dart';
import '../../providers/route_provider.dart';
import '../../widgets/trip_summary_card.dart';
import '../../widgets/google_map_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../trip/trip_summary_screen.dart';
import '../trip/trip_tracking_screen.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/error_handler.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Route Comparison"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Consumer<RouteProvider>(
        builder: (context, routeProvider, _) {
          // Show loading spinner when routes are being fetched
          if (routeProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text("Searching for best routes..."),
                ],
              ),
            );
          }

          if (routeProvider.availableRoutes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No routes available",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      routeProvider.source.isEmpty
                          ? "Enter route details to see comparisons"
                          : "No routes found for this route",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    if (routeProvider.source.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () {
                          routeProvider.reset();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Clear Search"),
                      ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: ResponsiveHelper.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${routeProvider.source} → ${routeProvider.destination}",
                        style: TextStyle(
                          fontSize:
                              ResponsiveHelper.getHeadlineMediumSize(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${routeProvider.availableRoutes.length} routes found",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Route map (draw all candidate routes as polylines)
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Builder(
                    builder: (context) {
                      final routes = routeProvider.availableRoutes;
                      // If we don't have polylines yet, just show an empty map area.
                      final polylines = routes
                          .map((r) {
                            if (r.encodedPolyline.isEmpty) {
                              return null;
                            }
                            List<LatLng> pts = const [];
                            if (r.encodedPolyline.isNotEmpty) {
                              try {
                                pts = MapPolylineBuilder.decodePolyline(
                                  r.encodedPolyline,
                                );
                              } catch (_) {
                                // If a single route has a bad/invalid polyline,
                                // don't crash the whole screen.
                                pts = const [];
                              }
                            }

                            // Alternate colors by index-ish hash (simple + deterministic)

                            final hue = (r.id.hashCode % 360).toDouble();
                            final color =
                                HSLColor.fromAHSL(1, hue, 0.65, 0.5).toColor();
                            return Polyline(
                              polylineId: PolylineId('route_${r.id}'),
                              points: pts,
                              width: 5,
                              color: color,
                              geodesic: true,
                            );
                          })
                          .whereType<Polyline>()
                          .toSet();

                      // Pick an initial camera target from first available polyline point.
                      LatLng initial = const LatLng(33.6844, 73.0479);
                      for (final r in routes) {
                        if (r.encodedPolyline.isEmpty) continue;
                        final pts = MapPolylineBuilder.decodePolyline(
                            r.encodedPolyline);
                        if (pts.isNotEmpty) {
                          initial = pts.first;
                          break;
                        }
                      }

                      return GoogleMapWidget(
                        initialPosition: initial,
                        markers: const {},
                        polylines: polylines,
                        height: 220,
                        showMyLocationButton: false,
                        // No need for onMapCreated here
                      );
                    },
                  ),
                ),

                // Use grid layout on tablets/desktops, single column on mobile

                if (ResponsiveHelper.isMobile(context))
                  Column(
                    children: routeProvider.availableRoutes.map((route) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildRouteCard(context, route, routeProvider),
                      );
                    }).toList(),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          ResponsiveHelper.isDesktop(context) ? 2 : 1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: routeProvider.availableRoutes.length,
                    itemBuilder: (context, index) {
                      return _buildRouteCard(
                        context,
                        routeProvider.availableRoutes[index],
                        routeProvider,
                      );
                    },
                  ),
                const SizedBox(height: 24),
                _buildActionButtons(context, routeProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRouteCard(
      BuildContext context, dynamic route, RouteProvider routeProvider) {
    return GestureDetector(
      onTap: () {
        routeProvider.selectRoute(route);
        ErrorHandler.showSuccessSnackbar(
          context,
          'Selected: ${route.name}',
        );
      },
      child: TripSummaryCard(
        routeName: route.name,
        distance: "${route.distance.toStringAsFixed(1)} km",
        time: "${route.estimatedTime.toStringAsFixed(1)} hrs",
        cost: "PKR ${route.fuelCost.toStringAsFixed(0)}",
        tollCost: "PKR ${route.tollCharges.toStringAsFixed(0)}",
        totalCost: "PKR ${route.totalCost.toStringAsFixed(0)}",
        isRecommended: route.isRecommended,
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, RouteProvider routeProvider) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Column(
      children: [
        if (isDesktop)
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: routeProvider.selectedRoute == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TripSummaryScreen(),
                            ),
                          );
                        },
                  child: const Text(
                    "View Trip Summary",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: routeProvider.selectedRoute == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TripTrackingScreen(),
                            ),
                          );
                        },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    "Start Trip",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: routeProvider.selectedRoute == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TripSummaryScreen(),
                            ),
                          );
                        },
                  child: const Text(
                    "View Trip Summary",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: routeProvider.selectedRoute == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TripTrackingScreen(),
                            ),
                          );
                        },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    "Start Trip",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

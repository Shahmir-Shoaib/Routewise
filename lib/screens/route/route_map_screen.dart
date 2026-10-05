import 'package:flutter/material.dart' hide Route;
import 'package:provider/provider.dart';
import '../../core/contants/app_colors.dart';
import '../../providers/route_provider.dart';

class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Route Map'),
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
                      Icons.map_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No route selected",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Select a route to view it on the map",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to route comparison screen
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.compare),
                      label: const Text("View Routes"),
                    ),
                  ],
                ),
              ),
            );
          }

          final selectedRoute = routeProvider.selectedRoute!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mock Map Visualization
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Simplified route visualization
                      CustomPaint(
                        size: const Size(double.infinity, 300),
                        painter: RoutePainter(
                          source: routeProvider.source,
                          destination: routeProvider.destination,
                          tollBooths: selectedRoute.tollBooths,
                        ),
                      ),
                      // Central route info
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            selectedRoute.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${selectedRoute.distance.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Route Details
                const Text(
                  'Route Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Source and Destination
                _buildLocationCard(
                  icon: Icons.location_on,
                  label: 'From',
                  location: routeProvider.source,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _buildLocationCard(
                  icon: Icons.location_on,
                  label: 'To',
                  location: routeProvider.destination,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),

                // Route Segments
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
                        'Route Path',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...selectedRoute.route.asMap().entries.map((entry) {
                        int index = entry.key;
                        String segment = entry.value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
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
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Toll Booths
                if (selectedRoute.tollBooths.isNotEmpty)
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
                        Row(
                          children: [
                            const Icon(
                              Icons.toll,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Toll Booths',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'PKR ${selectedRoute.tollCharges.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...selectedRoute.tollBooths
                            .asMap()
                            .entries
                            .map((entry) {
                          int index = entry.key;
                          String booth = entry.value;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.toll,
                                  size: 20,
                                  color: Colors.orange[700],
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${index + 1}. $booth',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Cost Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      _costRow('Fuel Cost',
                          'PKR ${selectedRoute.fuelCost.toStringAsFixed(0)}'),
                      const SizedBox(height: 8),
                      _costRow('Toll Charges',
                          'PKR ${selectedRoute.tollCharges.toStringAsFixed(0)}'),
                      const Divider(height: 16),
                      _costRow('Total Cost',
                          'PKR ${selectedRoute.totalCost.toStringAsFixed(0)}',
                          isBold: true, isTotal: true),
                    ],
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

  Widget _buildLocationCard({
    required IconData icon,
    required String label,
    required String location,
    required Color color,
  }) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _costRow(String label, String value,
      {bool isBold = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? AppColors.primary : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? AppColors.primary : Colors.black87,
          ),
        ),
      ],
    );
  }
}

class RoutePainter extends CustomPainter {
  final String source;
  final String destination;
  final List<String> tollBooths;

  RoutePainter({
    required this.source,
    required this.destination,
    required this.tollBooths,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw curved route line
    final path = Path();
    path.moveTo(50, size.height / 2 - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height / 2 + 50,
      size.width - 50,
      size.height / 2 + 30,
    );
    canvas.drawPath(path, paint);

    // Draw start point
    canvas.drawCircle(
      Offset(50, size.height / 2 - 30),
      8,
      Paint()..color = Colors.green,
    );
    canvas.drawCircle(
      Offset(50, size.height / 2 - 30),
      12,
      Paint()
        ..color = Colors.green.withOpacity(0.2)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // Draw toll booth markers
    if (tollBooths.isNotEmpty) {
      final tollPaint = Paint()..color = Colors.orange;
      int boothCount = tollBooths.length;
      for (int i = 0; i < boothCount; i++) {
        final progress = (i + 1) / (boothCount + 1);
        final x = 50 + (size.width - 100) * progress;
        final y = (size.height / 2 - 30) +
            (50 - (-30)) * progress * (2 * progress - 1);

        canvas.drawCircle(Offset(x, y), 6, tollPaint);
      }
    }

    // Draw end point
    canvas.drawCircle(
      Offset(size.width - 50, size.height / 2 + 30),
      8,
      Paint()..color = Colors.red,
    );
    canvas.drawCircle(
      Offset(size.width - 50, size.height / 2 + 30),
      12,
      Paint()
        ..color = Colors.red.withOpacity(0.2)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

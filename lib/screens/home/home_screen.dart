import 'package:flutter/material.dart';
import '../../core/contants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../veh/vehicle_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final headlineSize = ResponsiveHelper.getHeadlineLargeSize(context);
    final bodySize = ResponsiveHelper.getBodyLargeSize(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradientPrimary,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 60 : (isMobile ? 24 : 40),
              vertical: isDesktop ? 40 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: isDesktop ? 20 : 40),

                // Logo / App Name
                Text(
                  "RouteWise",
                  style: TextStyle(
                    fontSize: isDesktop ? 28 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),

                SizedBox(height: isDesktop ? 40 : 60),

                // Headline
                Text(
                  "Plan Your\nJourney Smartly",
                  style: TextStyle(
                    fontSize: headlineSize,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  "Compare travel time, fuel cost and routes before you even start your trip.",
                  style: TextStyle(
                    fontSize: bodySize,
                    color: Colors.white70,
                  ),
                ),

                SizedBox(height: isDesktop ? 60 : 40),

                // Glass Card - Responsive Layout
                isDesktop
                    ? _buildDesktopFeatureCard(context)
                    : _buildMobileFeatureCard(context),

                SizedBox(height: isDesktop ? 60 : 30),

                // Start Button
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 300 : double.infinity,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        vertical: isDesktop ? 20 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VehicleScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Start Planning",
                      style: TextStyle(
                        fontSize: isDesktop ? 20 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isDesktop ? 60 : 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Desktop feature card layout (horizontal grid)
  Widget _buildDesktopFeatureCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _FeatureItem(
            icon: Icons.route,
            text: "Route\nCompare",
            size: 40,
            textSize: 16,
          ),
          _FeatureItem(
            icon: Icons.local_gas_station,
            text: "Fuel\nCost",
            size: 40,
            textSize: 16,
          ),
          _FeatureItem(
            icon: Icons.timer,
            text: "Time\nEstimate",
            size: 40,
            textSize: 16,
          ),
        ],
      ),
    );
  }

  /// Mobile feature card layout
  Widget _buildMobileFeatureCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _FeatureItem(
                icon: Icons.route,
                text: "Route\nCompare",
              ),
              _FeatureItem(
                icon: Icons.local_gas_station,
                text: "Fuel\nCost",
              ),
              _FeatureItem(
                icon: Icons.timer,
                text: "Time\nEstimate",
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final double size;
  final double textSize;

  const _FeatureItem({
    required this.icon,
    required this.text,
    this.size = 28,
    this.textSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: size),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: textSize,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
  }
}

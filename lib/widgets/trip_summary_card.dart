import 'package:flutter/material.dart';
import '../../core/contants/app_colors.dart';

class TripSummaryCard extends StatelessWidget {
  final String routeName;
  final String distance;
  final String time;
  final String cost;
  final String? tollCost;
  final String? totalCost;
  final bool isRecommended;

  const TripSummaryCard({
    super.key,
    required this.routeName,
    required this.distance,
    required this.time,
    required this.cost,
    this.tollCost,
    this.totalCost,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isRecommended
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                routeName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (isRecommended)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientRoute,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "AI Best",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.route, "Distance", distance),
          _infoRow(Icons.timer, "Time", time),
          _infoRow(Icons.local_gas_station, "Fuel Cost", cost),
          if (tollCost != null) _infoRow(Icons.toll, "Toll Charges", tollCost!),
          if (totalCost != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Cost",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    totalCost!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }
}

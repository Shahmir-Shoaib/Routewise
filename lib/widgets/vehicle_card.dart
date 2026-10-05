import 'package:flutter/material.dart';
import '../../core/contants/app_colors.dart';
import '../../core/contants/app_shadows.dart';

class VehicleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const VehicleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.gradientRoute : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  AppShadows.cardGlow,
                  AppShadows.neumorphicLight,
                ]
              : [AppShadows.neumorphicLight],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: selected ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? Colors.white : AppColors.textSecondary,
            )
          ],
        ),
      ),
    );
  }
}

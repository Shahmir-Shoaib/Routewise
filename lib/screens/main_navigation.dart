import 'package:flutter/material.dart' hide Route;
import '../../core/contants/app_colors.dart';

import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import 'home/home_screen.dart';
import 'veh/vehicle_screen.dart';
import 'route/route_input_screen.dart';
import 'route/route_compare_screen.dart';
import 'trip/trip_history_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const VehicleScreen();
      case 2:
        return const RouteInputScreen();
      case 3:
        return const ComparisonScreen();
      case 4:
        return const TripHistoryScreen();
      case 5:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RouteWise'),
        elevation: 0,
        actions: [
          IconButton(
            icon: context.watch<ThemeProvider>().themeMode == ThemeMode.light
                ? const Icon(Icons.dark_mode)
                : const Icon(Icons.light_mode),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: _getScreen(currentIndex),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.directions_car), label: "Vehicle"),
            BottomNavigationBarItem(
                icon: Icon(Icons.location_on), label: "Routes"),
            BottomNavigationBarItem(
                icon: Icon(Icons.analytics), label: "Compare"),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: "History"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart' hide Route;
import 'package:provider/provider.dart';
import '../core/utils/responsive_helper.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/contants/app_colors.dart';

import 'home/home_screen.dart';
import 'veh/vehicle_screen.dart';
import 'route/route_input_screen.dart';
import 'route/route_compare_screen.dart';
import 'trip/trip_history_screen.dart';
import 'profile/profile_screen.dart';

class ResponsiveMainNavigation extends StatefulWidget {
  const ResponsiveMainNavigation({super.key});

  @override
  State<ResponsiveMainNavigation> createState() =>
      _ResponsiveMainNavigationState();
}

class _ResponsiveMainNavigationState extends State<ResponsiveMainNavigation> {
  int currentIndex = 0;

  final List<NavigationItem> navigationItems = [
    NavigationItem(
      label: 'Home',
      icon: Icons.home,
      screen: const HomeScreen(),
    ),
    NavigationItem(
      label: 'Vehicles',
      icon: Icons.directions_car,
      screen: const VehicleScreen(),
    ),
    NavigationItem(
      label: 'Routes',
      icon: Icons.map,
      screen: const RouteInputScreen(),
    ),
    NavigationItem(
      label: 'Compare',
      icon: Icons.compare,
      screen: const ComparisonScreen(),
    ),
    NavigationItem(
      label: 'History',
      icon: Icons.history,
      screen: const TripHistoryScreen(),
    ),
    NavigationItem(
      label: 'Profile',
      icon: Icons.person,
      screen: const ProfileScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktopLayout = ResponsiveHelper.useSidebarLayout(context);

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
      body: isDesktopLayout
          ? _buildDesktopLayout(context)
          : _buildMobileLayout(context),
      bottomNavigationBar:
          isDesktopLayout ? null : _buildBottomNavigation(context),
    );
  }

  /// Desktop/Tablet layout with sidebar
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 250,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Menu',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: navigationItems.length,
                  itemBuilder: (context, index) {
                    final item = navigationItems[index];
                    final isSelected = index == currentIndex;

                    return ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.label),
                      selected: isSelected,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      onTap: () {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Main content
        Expanded(
          child: navigationItems[currentIndex].screen,
        ),
      ],
    );
  }

  /// Mobile layout with content area
  Widget _buildMobileLayout(BuildContext context) {
    return navigationItems[currentIndex].screen;
  }

  /// Bottom navigation bar for mobile
  Widget _buildBottomNavigation(BuildContext context) {
    return ClipRRect(
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
        items: navigationItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}

/// Navigation item model
class NavigationItem {
  final String label;
  final IconData icon;
  final Widget screen;

  NavigationItem({
    required this.label,
    required this.icon,
    required this.screen,
  });
}

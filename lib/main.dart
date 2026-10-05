import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/trip_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/vehicles_provider.dart';
import 'providers/route_provider.dart';
import 'providers/location_provider.dart';
import 'providers/trip_history_provider.dart';
import 'providers/saved_trips_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/responsive_main_navigation.dart';
import 'core/utils/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RouteWiseApp());
}

class RouteWiseApp extends StatelessWidget {
  const RouteWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VehiclesProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => TripHistoryProvider()),
        ChangeNotifierProvider(create: (_) => SavedTripsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'RouteWise',
            theme: AppTheme.lightTheme,
            themeMode: themeProvider.themeMode,
            darkTheme: AppTheme.darkTheme,
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.isAuthenticated) {
                  return const ResponsiveMainNavigation();
                }
                return const LoginScreen();
              },
            ),
            routes: {
              '/home': (context) => const ResponsiveMainNavigation(),
            },
          );
        },
      ),
    );
  }
}

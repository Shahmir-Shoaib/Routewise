import 'package:flutter/material.dart' hide Route;
import 'package:provider/provider.dart';
import '../../core/contants/app_colors.dart';
import '../../providers/route_provider.dart';
import '../../providers/trip_provider.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/validation_helper.dart';
import '../../core/utils/error_handler.dart';
import 'route_compare_screen.dart';

class RouteInputScreen extends StatefulWidget {
  const RouteInputScreen({super.key});

  @override
  State<RouteInputScreen> createState() => _RouteInputScreenState();
}

class _RouteInputScreenState extends State<RouteInputScreen> {
  late TextEditingController _sourceController;
  late TextEditingController _destinationController;

  String? _sourceError;
  String? _destinationError;

  @override
  void initState() {
    super.initState();
    final routeProvider = context.read<RouteProvider>();
    _sourceController = TextEditingController(text: routeProvider.source);
    _destinationController =
        TextEditingController(text: routeProvider.destination);
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _validateSource(String value) {
    context.read<RouteProvider>().setSource(value);
    setState(() {
      _sourceError = ValidationHelper.getLocationError(value);
    });
  }

  void _validateDestination(String value) {
    context.read<RouteProvider>().setDestination(value);
    setState(() {
      _destinationError = ValidationHelper.getLocationError(value);
    });
  }

  bool _isFormValid() {
    return _sourceController.text.isNotEmpty &&
        _destinationController.text.isNotEmpty &&
        _sourceError == null &&
        _destinationError == null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tripProvider = context.read<TripProvider>();
    final padding = ResponsiveHelper.getResponsivePadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plan Your Trip"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter your route details",
              style: TextStyle(
                fontSize: ResponsiveHelper.getHeadlineMediumSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // SOURCE
            TextField(
              controller: _sourceController,
              onChanged: _validateSource,
              decoration: InputDecoration(
                labelText: "Source",
                hintText: "Enter starting point",
                prefixIcon: const Icon(Icons.my_location),
                errorText: _sourceError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _sourceError != null
                        ? Colors.red
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // DESTINATION
            TextField(
              controller: _destinationController,
              onChanged: _validateDestination,
              decoration: InputDecoration(
                labelText: "Destination",
                hintText: "Enter destination",
                prefixIcon: const Icon(Icons.location_on),
                errorText: _destinationError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _destinationError != null
                        ? Colors.red
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Consumer<RouteProvider>(
              builder: (context, routeProvider, _) {
                return Column(
                  children: [
                    if (routeProvider.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                routeProvider.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
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
                        onPressed: (!_isFormValid() || routeProvider.isLoading)
                            ? null
                            : () async {
                                if (!_isFormValid()) {
                                  ErrorHandler.showErrorSnackbar(
                                    context,
                                    'Please fix the errors in the form',
                                  );
                                  return;
                                }

                                try {
                                  final success =
                                      await routeProvider.searchRoutes(
                                    tripProvider.selectedVehicle,
                                    tripProvider.fuelAverage,
                                  );

                                  if (!success && mounted) {
                                    ErrorHandler.showErrorDialog(
                                      context,
                                      'Route Search Failed',
                                      routeProvider.errorMessage ??
                                          'Unable to find routes for these locations. Please try again.',
                                      onRetry: () async {
                                        await routeProvider.searchRoutes(
                                          tripProvider.selectedVehicle,
                                          tripProvider.fuelAverage,
                                        );
                                      },
                                    );
                                  } else if (success && mounted) {
                                    ErrorHandler.showSuccessSnackbar(
                                      context,
                                      'Routes found successfully!',
                                    );
                                    // Navigate to comparison screen
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ComparisonScreen(),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ErrorHandler.showErrorSnackbar(
                                      context,
                                      ErrorHandler.getErrorMessage(e),
                                    );
                                  }
                                }
                              },
                        child: routeProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                "Compare Routes",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

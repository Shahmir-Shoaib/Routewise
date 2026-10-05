import 'package:flutter/material.dart';
import '../contants/app_colors.dart';

class ErrorHandler {
  /// Show error snackbar with consistent styling
  static void showErrorSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.info,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onRetry();
                },
                child: const Text('Retry'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Handle location-related errors
  static String getLocationErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'LOCATION_SERVICE_DISABLED':
        return 'Location services are disabled. Please enable them in settings.';
      case 'LOCATION_PERMISSION_DENIED':
        return 'Location permission was denied. Please enable it in settings.';
      case 'LOCATION_PERMISSION_DENIED_FOREVER':
        return 'Location permission was permanently denied. Please enable it in app settings.';
      case 'INVALID_LOCATION':
        return 'Unable to retrieve your location. Please try again.';
      case 'LOCATION_NOT_FOUND':
        return 'The location you entered could not be found. Please check and try again.';
      default:
        return 'An error occurred while retrieving location: $errorCode';
    }
  }

  /// Handle network-related errors
  static String getNetworkErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'NO_INTERNET':
        return 'No internet connection. Please check your network and try again.';
      case 'TIMEOUT':
        return 'Request timed out. Please try again.';
      case 'SERVER_ERROR':
        return 'Server error occurred. Please try again later.';
      case 'NOT_FOUND':
        return 'The requested resource was not found.';
      case 'UNAUTHORIZED':
        return 'Unauthorized access. Please log in again.';
      default:
        return 'Network error occurred: $errorCode';
    }
  }

  /// Handle route-related errors
  static String getRouteErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'NO_ROUTE_FOUND':
        return 'No route found between these locations. Please try different locations.';
      case 'INVALID_SOURCE':
        return 'Invalid source location. Please enter a valid location.';
      case 'INVALID_DESTINATION':
        return 'Invalid destination location. Please enter a valid location.';
      case 'SAME_LOCATION':
        return 'Source and destination cannot be the same.';
      default:
        return 'Route search failed: $errorCode';
    }
  }

  /// Parse and handle generic errors
  static String getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }
}

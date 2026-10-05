/// Input validation utilities for the app
class ValidationHelper {
  /// Validate email format
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  /// Validate password (minimum 6 characters)
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Validate name (not empty, at least 2 characters)
  static bool isValidName(String name) {
    return name.trim().length >= 2;
  }

  /// Validate location/route (not empty)
  static bool isValidLocation(String location) {
    return location.trim().isNotEmpty;
  }

  /// Validate fuel average (positive number)
  static bool isValidFuelAverage(String fuel) {
    if (fuel.isEmpty) return false;
    final fuelValue = double.tryParse(fuel);
    return fuelValue != null && fuelValue > 0;
  }

  /// Get error message for email
  static String? getEmailError(String email) {
    if (email.isEmpty) return 'Email is required';
    if (!isValidEmail(email)) return 'Enter a valid email address';
    return null;
  }

  /// Get error message for password
  static String? getPasswordError(String password) {
    if (password.isEmpty) return 'Password is required';
    if (!isValidPassword(password)) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Get error message for name
  static String? getNameError(String name) {
    if (name.isEmpty) return 'Name is required';
    if (!isValidName(name)) return 'Name must be at least 2 characters';
    return null;
  }

  /// Get error message for location
  static String? getLocationError(String location) {
    if (!isValidLocation(location)) return 'This field is required';
    return null;
  }

  /// Get error message for fuel average
  static String? getFuelAverageError(String fuel) {
    if (fuel.isEmpty) return 'Fuel average is required';
    if (!isValidFuelAverage(fuel)) return 'Enter a valid positive number';
    return null;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../route/route_input_screen.dart';
import '../../providers/trip_provider.dart';
import '../../core/utils/validation_helper.dart';
import '../../core/utils/error_handler.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  String selectedVehicle = "";
  late TextEditingController _fuelAverageController;
  String? _fuelAverageError;

  @override
  void initState() {
    super.initState();
    _fuelAverageController = TextEditingController();
  }

  @override
  void dispose() {
    _fuelAverageController.dispose();
    super.dispose();
  }

  void _validateFuelAverage(String value) {
    setState(() {
      _fuelAverageError = ValidationHelper.getFuelAverageError(value);
    });
  }

  bool _isFormValid() {
    return selectedVehicle.isNotEmpty &&
        _fuelAverageController.text.isNotEmpty &&
        _fuelAverageError == null;
  }

  final List<Map<String, dynamic>> vehicles = [
    {"name": "Bike", "icon": Icons.two_wheeler},
    {"name": "Car", "icon": Icons.directions_car},
    {"name": "SUV", "icon": Icons.airport_shuttle},
    {"name": "Bus", "icon": Icons.directions_bus},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Select Vehicle"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Choose your vehicle",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "This helps calculate accurate fuel cost & travel time",
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),
              GridView.builder(
                shrinkWrap: true,
                itemCount: vehicles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  final isSelected = selectedVehicle == vehicle["name"];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedVehicle = vehicle["name"];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFF2E5BFF) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            vehicle["icon"],
                            size: 40,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF2E5BFF),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            vehicle["name"],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              if (selectedVehicle.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Fuel Average (km/l)",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _fuelAverageController,
                      keyboardType: TextInputType.number,
                      onChanged: _validateFuelAverage,
                      decoration: InputDecoration(
                        hintText: "Enter average",
                        errorText: _fuelAverageError,
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[100],
                        hintStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[500]
                              : Colors.grey[600],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _fuelAverageError != null
                                ? Colors.red
                                : Theme.of(context).dividerColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _fuelAverageError != null
                                ? Colors.red
                                : Theme.of(context).dividerColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _fuelAverageError != null
                                ? Colors.red
                                : const Color(0xFF2E5BFF),
                            width: 2,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    )
                  ],
                ),
              const SizedBox(height: 30),
              if (selectedVehicle.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E5BFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: !_isFormValid()
                        ? null
                        : () {
                            if (selectedVehicle.isNotEmpty &&
                                _fuelAverageController.text.isNotEmpty) {
                              context.read<TripProvider>().setSelectedVehicle(
                                    selectedVehicle,
                                  );
                              context.read<TripProvider>().setFuelAverage(
                                    double.parse(_fuelAverageController.text),
                                  );
                              ErrorHandler.showSuccessSnackbar(
                                context,
                                'Vehicle selected: $selectedVehicle',
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RouteInputScreen(),
                                ),
                              );
                            } else {
                              ErrorHandler.showErrorSnackbar(
                                context,
                                'Please select a vehicle and enter fuel average',
                              );
                            }
                          },
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

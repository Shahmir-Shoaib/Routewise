import '../../core/contants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_history_provider.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  String _sortBy = 'date_desc';
  bool _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  void _loadTrips() async {
    final historyProvider =
        Provider.of<TripHistoryProvider>(context, listen: false);
    await historyProvider.loadTripsFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Trip History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortMenu,
          ),
        ],
      ),
      body: Consumer<TripHistoryProvider>(
        builder: (context, historyProvider, _) {
          if (historyProvider.trips.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.history,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No trip history",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your completed trips will appear here",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.directions_car),
                      label: const Text("Book a Trip"),
                    ),
                  ],
                ),
              ),
            );
          }

          final trips = historyProvider.trips;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.route,
                        label: 'Total Trips',
                        value: trips.length.toString(),
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        icon: Icons.speed,
                        label: 'Total Distance',
                        value:
                            '${historyProvider.totalDistance.toStringAsFixed(0)} km',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.attach_money,
                        label: 'Total Spent',
                        value:
                            'PKR ${historyProvider.totalCost.toStringAsFixed(0)}',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        icon: Icons.savings,
                        label: 'Total Saved',
                        value:
                            'PKR ${historyProvider.getTotalCostSavings().toStringAsFixed(0)}',
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Filter/Sort controls
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${historyProvider.trips.length} trips total',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showOnlyFavorites = !_showOnlyFavorites;
                          });
                        },
                        icon: Icon(
                          _showOnlyFavorites
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _showOnlyFavorites ? Colors.red : Colors.grey,
                        ),
                        label: const Text('Favorites'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Trip Cards
                ...trips.asMap().entries.map((entry) {
                  var trip = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        _showTripDetails(context, trip);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${trip.source} → ${trip.destination}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppColors.primaryLight
                                              : AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        trip.startTime.toString().split('.')[0],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[500]
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: trip.wasCheaper
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    trip.wasCheaper
                                        ? 'Saved PKR ${trip.costSavings.toStringAsFixed(0)}'
                                        : 'PKR ${trip.costSavingsPercentage.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: trip.wasCheaper
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _tripStatItem(
                                  icon: Icons.route,
                                  label: 'Distance',
                                  value:
                                      '${trip.distance.toStringAsFixed(1)} km',
                                ),
                                _tripStatItem(
                                  icon: Icons.timer,
                                  label: 'Duration',
                                  value: trip.wasFaster
                                      ? '${trip.actualTime.toStringAsFixed(1)} h ✓'
                                      : '${trip.actualTime.toStringAsFixed(1)} h',
                                ),
                                _tripStatItem(
                                  icon: Icons.local_gas_station,
                                  label: 'Cost',
                                  value:
                                      'PKR ${trip.actualCost.toStringAsFixed(0)}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              _sortOption('date_desc', 'Newest First'),
              _sortOption('date_asc', 'Oldest First'),
              _sortOption('distance_desc', 'Longest Distance'),
              _sortOption('distance_asc', 'Shortest Distance'),
              _sortOption('cost_desc', 'Most Expensive'),
              _sortOption('cost_asc', 'Cheapest'),
              _sortOption('time_saved', 'Most Time Saved'),
              _sortOption('cost_saved', 'Most Cost Saved'),
            ],
          ),
        );
      },
    );
  }

  Widget _sortOption(String value, String label) {
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: value,
        groupValue: _sortBy,
        onChanged: (newValue) {
          if (newValue != null) {
            setState(() {
              _sortBy = newValue;
            });
            final historyProvider =
                Provider.of<TripHistoryProvider>(context, listen: false);
            historyProvider.sortTrips(newValue);
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showTripDetails(BuildContext context, CompletedTrip trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${trip.source} → ${trip.destination}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _detailRow('Vehicle', trip.vehicleName),
                _detailRow(
                    'Distance', '${trip.distance.toStringAsFixed(1)} km'),
                _detailRow('Estimated Time',
                    '${trip.estimatedTime.toStringAsFixed(1)} hours'),
                _detailRow('Actual Time',
                    '${trip.actualTime.toStringAsFixed(1)} hours'),
                _detailRow('Time Saved',
                    '${trip.timeSavings.toStringAsFixed(1)} hours'),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _detailRow('Estimated Cost',
                    'PKR ${trip.estimatedCost.toStringAsFixed(0)}'),
                _detailRow(
                    'Actual Cost', 'PKR ${trip.actualCost.toStringAsFixed(0)}'),
                _detailRow(
                    'Cost Saved', 'PKR ${trip.costSavings.toStringAsFixed(0)}'),
                if (trip.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(trip.notes),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tripStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import '../widgets/trip_summary_card.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool showCards = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        showCards = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Route Comparison"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: showCards ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              child: const Column(
                children: [
                  TripSummaryCard(
                    routeName: "Motorway",
                    distance: "340 km",
                    time: "4h 30m",
                    cost: "PKR 6,200",
                    isRecommended: true,
                  ),
                  SizedBox(height: 16),
                  TripSummaryCard(
                    routeName: "GT Road",
                    distance: "310 km",
                    time: "5h 20m",
                    cost: "PKR 5,400",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

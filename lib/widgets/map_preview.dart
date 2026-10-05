import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const LatLng start = LatLng(33.6844, 73.0479);
  static const LatLng end = LatLng(31.5204, 74.3587);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Route Preview")),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: start,
          zoom: 6,
        ),
        markers: {
          const Marker(markerId: MarkerId("start"), position: start),
          const Marker(markerId: MarkerId("end"), position: end),
        },
      ),
    );
  }
}

# TODO

## Google Maps polyline integration (Comparison + Trip Summary)
- [ ] Update `lib/models/route_model.dart` to store `encodedPolyline` (and keep backward compatibility if needed).
- [ ] Update `lib/services/route_service.dart` to propagate `encodedPolyline` from `GoogleMapsService.calculateRoutes()` into `Route`.
- [ ] Update `lib/screens/route/route_compare_screen.dart` to render a `GoogleMapWidget` with polylines for each route.
- [ ] Update `lib/screens/trip/trip_summary_screen.dart` to render a `GoogleMapWidget` with a single selected route polyline.
- [ ] Run `flutter clean && flutter pub get` and `flutter run` to verify both screens compile and show polylines.


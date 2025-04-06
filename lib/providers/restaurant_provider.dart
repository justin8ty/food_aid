import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/restaurant.dart';
import '../services/places_service.dart';

final restaurantProvider =
    StateNotifierProvider<RestaurantNotifier, List<Restaurant>>(
      (ref) => RestaurantNotifier(),
    );

class RestaurantNotifier extends StateNotifier<List<Restaurant>> {
  RestaurantNotifier() : super([]);

  Future<void> fetchNearbyRestaurants(LatLng location) async {
    final results = await PlacesService.fetchRestaurants(location);
    state = results;
  }
}

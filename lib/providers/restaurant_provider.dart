import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/places_service.dart';

final restaurantProvider =
    StateNotifierProvider<RestaurantNotifier, List<Marker>>(
      (ref) => RestaurantNotifier(ref),
    );

class RestaurantNotifier extends StateNotifier<List<Marker>> {
  final Ref ref;

  RestaurantNotifier(this.ref) : super([]);

  Future<void> loadRestaurants(LatLng location) async {
    final service = ref.read(placesServiceProvider);
    final places = await service.getNearbyRestaurants(location);

    final markers =
        places.map((place) {
          return Marker(
            markerId: MarkerId(place.name),
            position: LatLng(place.lat, place.lng),
            infoWindow: InfoWindow(title: place.name),
          );
        }).toList();

    state = markers;
  }
}

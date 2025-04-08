import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/food_bank.dart';
import '../services/food_bank_service.dart';

final restaurantProvider = StateNotifierProvider<RestaurantNotifier, List<Marker>>(
  (ref) => RestaurantNotifier(ref),
);

class RestaurantNotifier extends StateNotifier<List<Marker>> {
  final Ref ref;

  RestaurantNotifier(this.ref) : super([]);

  Future<void> loadFoodBanks(String query) async {
    final service = ref.read(foodBankServiceProvider);
    final foodBanks = await service.searchFoodBanks(query);

    final markers = foodBanks.map((bank) {
      return Marker(
        markerId: MarkerId(bank.name),
        position: LatLng(bank.latitude, bank.longitude),
        infoWindow: InfoWindow(
          title: bank.name,
          snippet: bank.address,
        ),
      );
    }).toList();

    state = markers;
  }
}
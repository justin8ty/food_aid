import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/food_bank.dart';
import '../services/food_bank_service.dart';

final foodBankProvider = StateNotifierProvider<FoodBankNotifier, FoodBankState>(
  (ref) => FoodBankNotifier(ref),
);

class FoodBankState {
  final List<Marker> markers;
  final List<FoodBank> banks;

  FoodBankState({required this.markers, required this.banks});
}

class FoodBankNotifier extends StateNotifier<FoodBankState> {
  final Ref ref;

  FoodBankNotifier(this.ref) : super(FoodBankState(markers: [], banks: []));

  Future<void> loadFoodBanks(String query) async {
    final service = ref.read(foodBankServiceProvider);
    final foodBanks = await service.searchFoodBanks(query);

    final markers =
        foodBanks.map((bank) {
          return Marker(
            markerId: MarkerId(bank.name),
            position: LatLng(bank.latitude, bank.longitude),
            infoWindow: InfoWindow(title: bank.name, snippet: bank.address),
          );
        }).toList();

    state = FoodBankState(markers: markers, banks: foodBanks);
  }
}

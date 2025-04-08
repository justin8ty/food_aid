import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/restaurant_provider.dart';
import '../models/food_bank.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late GoogleMapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  static const double defaultZoom = 14;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _searchAndMove(String query) async {
    if (query.isEmpty) return;

    await ref.read(foodBankProvider.notifier).loadFoodBanks(query);

    final markers = ref.read(foodBankProvider).markers;
    if (markers.isNotEmpty) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(markers.first.position, defaultZoom),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No food banks found for "$query"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodBankProvider);
    final markers = state.markers;
    final foodBanks = state.banks;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(3.1390, 101.6869), // Default to KL
                    zoom: defaultZoom,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: Set<Marker>.from(markers),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: "Search food bank by name or address",
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: _searchAndMove,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed:
                              () => _searchAndMove(_searchController.text),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: foodBanks.length,
              itemBuilder: (context, index) {
                final bank = foodBanks[index];
                return ListTile(
                  title: Text(bank.name),
                  subtitle: Text(bank.address),
                  trailing: Icon(Icons.location_on),
                  onTap: () {
                    _mapController.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(bank.latitude, bank.longitude),
                        defaultZoom,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

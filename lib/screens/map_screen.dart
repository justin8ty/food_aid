import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/restaurant_provider.dart';

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
    
    await ref.read(restaurantProvider.notifier).loadFoodBanks(query);
    
    final markers = ref.read(restaurantProvider);
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
    final markers = ref.watch(restaurantProvider);

    return Scaffold(
      body: Stack(
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _searchAndMove,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _searchAndMove(_searchController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

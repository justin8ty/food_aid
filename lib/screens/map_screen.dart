import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/places_service.dart';
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
    final location = await ref
        .read(placesServiceProvider)
        .searchLocation(query);
    if (location != null) {
      final target = LatLng(location.latitude, location.longitude);
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(target, defaultZoom),
      );
      await ref.read(restaurantProvider.notifier).loadRestaurants(target);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Location not found: $query')));
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
                        hintText: "Search city or ZIP",
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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

  LatLng? _userLocation;
  Marker? _userMarker;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    final location = LatLng(position.latitude, position.longitude);

    setState(() {
      _userLocation = location;
      _userMarker = Marker(
        markerId: const MarkerId('user_location'),
        position: location,
        infoWindow: const InfoWindow(title: 'You are here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    });

    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(location, defaultZoom),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_userLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, defaultZoom),
      );
    }
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
        SnackBar(
          content: Text('No food banks found for "$query"'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodBankProvider);
    final markers = Set<Marker>.from(state.markers);
    if (_userMarker != null) markers.add(_userMarker!);
    final foodBanks = state.banks;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Map
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(3.1390, 101.6869), // KL fallback
                      zoom: defaultZoom,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: markers,
                  ),
                  Positioned(
                    top: 20,
                    left: 16,
                    right: 16,
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.black87),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: "Search by name or address",
                                  hintStyle: TextStyle(color: Colors.black54),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(color: Colors.black87),
                                onSubmitted: _searchAndMove,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_forward,
                                color: Colors.deepPurple,
                              ),
                              onPressed:
                                  () => _searchAndMove(_searchController.text),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              flex: 1,
              child:
                  foodBanks.isEmpty
                      ? const Center(
                        child: Text(
                          'No food banks found.',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount: foodBanks.length,
                        itemBuilder: (context, index) {
                          final bank = foodBanks[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              title: Text(
                                bank.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                bank.address,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.location_on,
                                color: Colors.deepPurple,
                                size: 28,
                              ),
                              onTap: () {
                                _mapController.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    LatLng(bank.latitude, bank.longitude),
                                    defaultZoom,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

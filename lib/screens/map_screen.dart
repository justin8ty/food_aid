import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/restaurant_marker.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(
    3.1390,
    101.6869,
  ); // Default: Kuala Lumpur

  @override
  void initState() {
    super.initState();
    _loadLocation();
    ref
        .read(restaurantProvider.notifier)
        .fetchNearbyRestaurants(_initialPosition);
  }

  Future<void> _loadLocation() async {
    final position = await LocationService.getCurrentLocation();
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_initialPosition, 14),
    );
    ref
        .read(restaurantProvider.notifier)
        .fetchNearbyRestaurants(_initialPosition);
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(restaurantProvider);

    return Scaffold(
      body:
          _initialPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                onMapCreated: (controller) => _mapController = controller,
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 14,
                ),
                markers:
                    restaurants.map((r) => buildRestaurantMarker(r)).toSet(),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
    );
  }
}

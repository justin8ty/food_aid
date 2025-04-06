import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/restaurant.dart';

Marker buildRestaurantMarker(Restaurant restaurant) {
  return Marker(
    markerId: MarkerId(restaurant.id),
    position: restaurant.location,
    infoWindow: InfoWindow(
      title: restaurant.name,
      snippet: 'Rating: ${restaurant.rating.toString()}',
    ),
  );
}

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Restaurant {
  final String id;
  final String name;
  final double rating;
  final LatLng location;

  Restaurant({
    required this.id,
    required this.name,
    required this.rating,
    required this.location,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['place_id'],
      name: json['name'],
      rating: (json['rating'] ?? 0).toDouble(),
      location: LatLng(
        json['geometry']['location']['lat'],
        json['geometry']['location']['lng'],
      ),
    );
  }
}

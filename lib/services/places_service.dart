import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

final placesServiceProvider = Provider((ref) => PlacesService());

class PlacesService {
  static const String _apiKey = 'AIzaSyDrBOJ5Dxq9kSSFKfdL9HJ3YazqgmkE4AE';

  Future<List<Place>> getNearbyRestaurants(LatLng location) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${location.latitude},${location.longitude}'
      '&radius=1500&type=restaurant&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((e) => Place.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  Future<LatLng?> searchLocation(String query) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?address=${Uri.encodeComponent(query)}&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];
      if (results != null && results.isNotEmpty) {
        final loc = results[0]['geometry']['location'];
        return LatLng(loc['lat'], loc['lng']);
      }
    }
    return null;
  }
}

class Place {
  final String name;
  final double lat;
  final double lng;

  Place({required this.name, required this.lat, required this.lng});

  factory Place.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']['location'];
    return Place(
      name: json['name'],
      lat: geometry['lat'],
      lng: geometry['lng'],
    );
  }
}

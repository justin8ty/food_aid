import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/restaurant.dart';

class PlacesService {
  static const String _apiKey = 'AIzaSyDrBOJ5Dxq9kSSFKfdL9HJ3YazqgmkE4AE';

  static Future<List<Restaurant>> fetchRestaurants(LatLng location) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${location.latitude},${location.longitude}'
      '&radius=2000&type=restaurant&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    final results = data['results'] as List;
    return results.map((e) => Restaurant.fromJson(e)).toList();
  }
}

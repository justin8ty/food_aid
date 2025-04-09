// lib/services/geojson_service.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final geoJsonServiceProvider = Provider((ref) => GeoJsonService());

class GeoJsonService {
  Future<List<Polygon>> getStatePolygons() async {
    final jsonString = await rootBundle.loadString('assets/my.json');
    final geoJson = json.decode(jsonString);
    
    final polygons = <Polygon>[];
    
    for (var feature in geoJson['features']) {
      if (feature['geometry']['coordinates'].isEmpty) continue;
      
      final stateId = feature['properties']['id'];
      final stateName = feature['properties']['name'];
      
      // Convert coordinates to LatLng list
      final List<LatLng> points = [];
      final coords = feature['geometry']['coordinates'];
      
      // Handle both Polygon and MultiPolygon
      if (feature['geometry']['type'] == 'Polygon') {
        for (var point in coords[0]) {
          points.add(LatLng(point[1], point[0]));
        }
      } else if (feature['geometry']['type'] == 'MultiPolygon') {
        for (var polygon in coords) {
          for (var point in polygon[0]) {
            points.add(LatLng(point[1], point[0]));
          }
        }
      }
      
      polygons.add(Polygon(
        polygonId: PolygonId(stateId),
        points: points,
        strokeWidth: 0,
        fillColor: ['Kelantan', 'Sabah', 'Perlis'].contains(stateName)
            ? Colors.red.withOpacity(0.3)
            : ['Kedah', 'Perak', 'Sarawak', 'Pahang'].contains(stateName)
                ? Colors.yellow.withOpacity(0.4)
                : Colors.green.withOpacity(0.3), // fallback color if none match
      ));
    }
    
    return polygons;
  }
}
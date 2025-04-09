// lib/services/geojson_service.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/state_urgency.dart';

final geoJsonServiceProvider = Provider((ref) => GeoJsonService());

class GeoJsonService {
  Future<List<StateUrgency>> _loadUrgencyData() async {
    final jsonString = await rootBundle.loadString('assets/map_data.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => StateUrgency.fromJson(json)).toList();
  }

  Future<List<Polygon>> getStatePolygons() async {
    final jsonString = await rootBundle.loadString('assets/my.json');
    final geoJson = json.decode(jsonString);
    final urgencyData = await _loadUrgencyData();
    
    final polygons = <Polygon>[];
    
    for (var feature in geoJson['features']) {
      if (feature['geometry']['coordinates'].isEmpty) continue;
      
      final stateName = feature['properties']['name'];
      final stateUrgency = urgencyData.firstWhere(
        (data) => data.state == stateName,
        orElse: () => StateUrgency(
          state: stateName,
          needMetricScore: 0,
          urgency: 'low',
        ),
      );
      
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
      
      // Determine color based on urgency
      Color polygonColor;
      switch (stateUrgency.urgency) {
        case 'high':
          polygonColor = Colors.red;
          break;
        case 'moderate':
          polygonColor = Colors.orange;
          break;
        case 'low':
        default:
          polygonColor = Colors.green;
      }
      
      polygons.add(Polygon(
        polygonId: PolygonId(stateName),
        points: points,
        strokeWidth: 0,
        strokeColor: polygonColor,
        fillColor: polygonColor.withOpacity(0.3),
        consumeTapEvents: true,
      ));
    }
    
    return polygons;
  }
}
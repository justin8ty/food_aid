import 'package:flutter/material.dart';
import 'screens/map_screen.dart';

class RestaurantRadarApp extends StatelessWidget {
  const RestaurantRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Radar',
      theme: ThemeData.dark(),
      home: const MapScreen(),
    );
  }
}

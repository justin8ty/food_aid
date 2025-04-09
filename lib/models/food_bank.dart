class FoodBank {
  final String name;
  final String address;
  final String url;
  final double latitude;
  final double longitude;
  final String? area;

  FoodBank({
    required this.name,
    required this.address,
    required this.url,
    required this.latitude,
    required this.longitude,
    this.area,
  });

  factory FoodBank.fromJson(Map<String, dynamic> json) {
    final originalUrl = json['details']['url'];
    final normalizedUrl = _normalizeGoogleMapsUrl(originalUrl);
    final (lat, lng) = _extractCoordinatesFromUrl(normalizedUrl);

    return FoodBank(
      name: json['name'],
      address: json['details']['address'],
      url: normalizedUrl,
      latitude: lat,
      longitude: lng,
    );
  }

  /// Extracts coordinates from a standard Google Maps URL like:
  /// https://www.google.com/maps/dir//5.4141307,100.3287506
  static (double, double) _extractCoordinatesFromUrl(String url) {
    try {
      final parts = url.split('/');
      final coords = parts.last;
      final latLng = coords.split(',');
      final lat = double.parse(latLng[0]);
      final lng = double.parse(latLng[1]);
      return (lat, lng);
    } catch (e) {
      print('[FoodBank Parser] Failed to extract from $url');
      return (3.1390, 101.6869); // KL fallback
    }
  }

  /// Converts non-standard Google Maps URLs into a standard format
  /// Example:
  /// input: https://www.google.com/maps/place/.../@5.3896329,100.3018622,...
  /// output: https://www.google.com/maps/dir//5.3896329,100.3018622
  static String _normalizeGoogleMapsUrl(String url) {
    final atPattern = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)');
    final match = atPattern.firstMatch(url);

    if (match != null) {
      final lat = match.group(1);
      final lng = match.group(2);
      if (lat != null && lng != null) {
        return 'https://www.google.com/maps/dir//$lat,$lng';
      }
    }

    // If already standard or nothing found, return as-is
    return url;
  }
}

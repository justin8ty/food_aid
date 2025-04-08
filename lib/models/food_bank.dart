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
    // extract coords from url
    final url = json['details']['url'];
    final (lat, lng) = _extractCoordinatesFromUrl(url);
    
    return FoodBank(
      name: json['name'],
      address: json['details']['address'],
      url: url,
      latitude: lat,
      longitude: lng,
    ); 
  }

  static (double, double) _extractCoordinatesFromUrl(String url) {
    try {
      // "https://www.google.com/maps/dir//5.414130699999999,100.3287506"
      final parts = url.split('/');
      final coords = parts.last; // end up with "5.414130699999999,100.3287506"
      final latLng = coords.split(',');
      return (
        double.parse(latLng[0]),
        double.parse(latLng[1]),
      );
    } catch (e) {
      // return kl if fail
      return (3.1390, 101.6869);
    }
  }

}

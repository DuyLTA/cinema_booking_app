class GeoPositionModel {
  const GeoPositionModel({
    required this.latitude,
    required this.longitude,
    this.isFallback = false,
  });

  final double latitude;
  final double longitude;
  final bool isFallback;
}

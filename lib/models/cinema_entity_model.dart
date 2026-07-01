class CinemaEntityModel {
  final String id;
  final String name;
  final String? location;
  final String? address;
  final String? hotline;
  final String? workingHours;
  final int? totalScreens;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;

  CinemaEntityModel({
    required this.id,
    required this.name,
    this.location,
    this.address,
    this.hotline,
    this.workingHours,
    this.totalScreens,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  factory CinemaEntityModel.fromJson(Map<String, dynamic> json) {
    return CinemaEntityModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Cinema',
      location: json['location'] as String?,
      address: json['address'] as String?,
      hotline: json['hotline'] as String?,
      workingHours: json['working_hours'] as String?,
      totalScreens: _toInt(json['total_screens']),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }

  bool get hasCoordinate => latitude != null && longitude != null;

  CinemaEntityModel copyWith({double? distanceKm}) {
    return CinemaEntityModel(
      id: id,
      name: name,
      location: location,
      address: address,
      hotline: hotline,
      workingHours: workingHours,
      totalScreens: totalScreens,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

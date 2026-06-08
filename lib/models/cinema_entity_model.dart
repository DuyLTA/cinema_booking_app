class CinemaEntityModel {
  final String id;
  final String name;
  final String? location;
  final String? address;
  final String? hotline;
  final String? workingHours;
  final int? totalScreens;

  CinemaEntityModel({
    required this.id,
    required this.name,
    this.location,
    this.address,
    this.hotline,
    this.workingHours,
    this.totalScreens,
  });

  factory CinemaEntityModel.fromJson(Map<String, dynamic> json) {
    return CinemaEntityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String?,
      address: json['address'] as String?,
      hotline: json['hotline'] as String?,
      workingHours: json['working_hours'] as String?,
      totalScreens: json['total_screens'] as int?,
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../models/geo_position_model.dart';

class LocationService {
  static const _channel = MethodChannel('cinema_booking_app/location');
  static const GeoPositionModel defaultUserPosition = GeoPositionModel(
    latitude: 10.7769,
    longitude: 106.7009,
    isFallback: true,
  );

  Future<GeoPositionModel> getCurrentPosition() async {
    final geolocatorPosition = await _getPositionWithGeolocator();
    if (geolocatorPosition != null) return geolocatorPosition;

    try {
      final result = await _channel
          .invokeMapMethod<String, dynamic>('getCurrentLocation')
          .timeout(const Duration(seconds: 12));

      final latitude = _toDouble(result?['latitude']);
      final longitude = _toDouble(result?['longitude']);
      if (latitude == null || longitude == null) {
        return defaultUserPosition;
      }

      return GeoPositionModel(latitude: latitude, longitude: longitude);
    } catch (_) {
      return defaultUserPosition;
    }
  }

  Future<GeoPositionModel?> _getPositionWithGeolocator() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      return GeoPositionModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      try {
        final position = await Geolocator.getLastKnownPosition();
        if (position == null) return null;
        final age = DateTime.now().difference(position.timestamp);
        if (age > const Duration(minutes: 5)) return null;

        return GeoPositionModel(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } catch (_) {
        return null;
      }
    }
  }

  double distanceInKm({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(toLatitude - fromLatitude);
    final dLon = _toRadians(toLongitude - fromLongitude);
    final lat1 = _toRadians(fromLatitude);
    final lat2 = _toRadians(toLatitude);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degree) => degree * math.pi / 180;

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/route_direction_model.dart';

class GoogleDirectionsService {
  Future<RouteDirectionModel?> getDrivingRoute({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']?.trim();
    if (apiKey == null || apiKey.isEmpty) return null;

    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '$originLatitude,$originLongitude',
      'destination': '$destinationLatitude,$destinationLongitude',
      'mode': 'driving',
      'language': 'vi',
      'key': apiKey,
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = payload['routes'] as List<dynamic>? ?? const [];
    if (routes.isEmpty) return null;

    final route = Map<String, dynamic>.from(routes.first as Map);
    final overviewPolyline = Map<String, dynamic>.from(
      (route['overview_polyline'] as Map?) ?? {},
    );
    final encodedPoints = overviewPolyline['points'] as String?;
    if (encodedPoints == null || encodedPoints.isEmpty) return null;

    final legs = route['legs'] as List<dynamic>? ?? const [];
    final leg = legs.isEmpty
        ? const <String, dynamic>{}
        : Map<String, dynamic>.from(legs.first as Map);
    final distance = Map<String, dynamic>.from((leg['distance'] as Map?) ?? {});
    final duration = Map<String, dynamic>.from((leg['duration'] as Map?) ?? {});

    return RouteDirectionModel(
      points: _decodePolyline(encodedPoints),
      distanceText: distance['text'] as String? ?? '',
      durationText: duration['text'] as String? ?? '',
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var latitude = 0;
    var longitude = 0;

    while (index < encoded.length) {
      final latitudeChange = _decodeNextValue(encoded, () => index++);
      index = latitudeChange.nextIndex;
      latitude += latitudeChange.value;

      final longitudeChange = _decodeNextValue(encoded, () => index++);
      index = longitudeChange.nextIndex;
      longitude += longitudeChange.value;

      points.add(LatLng(latitude / 1e5, longitude / 1e5));
    }

    return points;
  }

  _PolylineValue _decodeNextValue(String encoded, int Function() nextIndex) {
    var shift = 0;
    var result = 0;
    var currentIndex = 0;
    int byte;

    do {
      currentIndex = nextIndex();
      byte = encoded.codeUnitAt(currentIndex) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);

    final value = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
    return _PolylineValue(value: value, nextIndex: currentIndex + 1);
  }
}

class _PolylineValue {
  const _PolylineValue({required this.value, required this.nextIndex});

  final int value;
  final int nextIndex;
}

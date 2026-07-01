import 'package:flutter/material.dart';

import '../../../models/cinema_entity_model.dart';
import '../../../models/geo_position_model.dart';
import '../../../models/route_direction_model.dart';
import '../../../services/google_directions_service.dart';
import '../../../services/location_service.dart';

class CinemaMapProvider extends ChangeNotifier {
  CinemaMapProvider({
    required this.cinema,
    required GeoPositionModel initialPosition,
    LocationService? locationService,
    GoogleDirectionsService? directionsService,
  }) : userPosition = initialPosition,
       _locationService = locationService ?? LocationService(),
       _directionsService = directionsService ?? GoogleDirectionsService();

  final CinemaEntityModel cinema;
  final LocationService _locationService;
  final GoogleDirectionsService _directionsService;

  GeoPositionModel userPosition;
  RouteDirectionModel? route;
  bool isLoadingRoute = false;
  String? routeMessage;

  bool get hasRealUserLocation => !userPosition.isFallback;

  String get distanceText {
    if ((route?.distanceText ?? '').isNotEmpty) return route!.distanceText;
    if (cinema.distanceKm != null) return _formatDistance(cinema.distanceKm!);
    return 'Distance unavailable';
  }

  String get durationText {
    if ((route?.durationText ?? '').isNotEmpty) return route!.durationText;
    return hasRealUserLocation ? 'Route unavailable' : 'GPS required';
  }

  Future<void> loadRoute() async {
    isLoadingRoute = true;
    routeMessage = null;
    notifyListeners();

    try {
      userPosition = await _locationService.getCurrentPosition();
      if (userPosition.isFallback) {
        route = null;
        routeMessage = 'Bat GPS hoac set Location tren emulator roi thu lai.';
        return;
      }

      if (!cinema.hasCoordinate) {
        route = null;
        routeMessage = 'Rap chua co toa do.';
        return;
      }

      route = await _directionsService.getDrivingRoute(
        originLatitude: userPosition.latitude,
        originLongitude: userPosition.longitude,
        destinationLatitude: cinema.latitude!,
        destinationLongitude: cinema.longitude!,
      );

      if (route == null) {
        routeMessage = 'Khong lay duoc duong di tu Google Directions.';
      }
    } catch (_) {
      route = null;
      routeMessage = 'Khong lay duoc duong di.';
    } finally {
      isLoadingRoute = false;
      notifyListeners();
    }
  }

  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }
}

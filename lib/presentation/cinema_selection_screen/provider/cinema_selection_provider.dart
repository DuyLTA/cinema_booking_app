import 'package:flutter/material.dart';

import '../../../models/cinema_entity_model.dart';
import '../../../models/geo_position_model.dart';
import '../../../services/cinema_service.dart';
import '../../../services/location_service.dart';

class CinemaSelectionProvider extends ChangeNotifier {
  CinemaSelectionProvider({
    CinemaService? cinemaService,
    LocationService? locationService,
  }) : _cinemaService = cinemaService ?? CinemaService(),
       _locationService = locationService ?? LocationService();

  final CinemaService _cinemaService;
  final LocationService _locationService;

  List<CinemaEntityModel> cinemas = const [];
  GeoPositionModel userPosition = LocationService.defaultUserPosition;
  bool isLoading = false;
  String? errorMessage;
  bool isUsingFallbackLocation = true;

  Future<void> loadCinemas() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final loadedCinemas = await _cinemaService.getAllCinemas();
      userPosition = await _loadUserPositionSafely();
      isUsingFallbackLocation = userPosition.isFallback;
      cinemas = _sortByDistance(loadedCinemas);
    } catch (_) {
      cinemas = const [];
      errorMessage = 'Unable to load cinemas. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<GeoPositionModel> _loadUserPositionSafely() async {
    try {
      return await _locationService.getCurrentPosition();
    } catch (_) {
      return LocationService.defaultUserPosition;
    }
  }

  List<CinemaEntityModel> _sortByDistance(List<CinemaEntityModel> values) {
    if (userPosition.isFallback) {
      return [...values]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    final enriched = values.map((cinema) {
      if (!cinema.hasCoordinate) return cinema;
      final distance = _locationService.distanceInKm(
        fromLatitude: userPosition.latitude,
        fromLongitude: userPosition.longitude,
        toLatitude: cinema.latitude!,
        toLongitude: cinema.longitude!,
      );
      return cinema.copyWith(distanceKm: distance);
    }).toList();

    enriched.sort((a, b) {
      final aDistance = a.distanceKm ?? double.infinity;
      final bDistance = b.distanceKm ?? double.infinity;
      final compare = aDistance.compareTo(bDistance);
      if (compare != 0) return compare;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return enriched;
  }
}

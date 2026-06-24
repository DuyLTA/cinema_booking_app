import 'package:flutter/material.dart';

import '../../../models/cinema_entity_model.dart';
import '../../../services/cinema_service.dart';

class CinemaSelectionProvider extends ChangeNotifier {
  CinemaSelectionProvider({CinemaService? cinemaService})
    : _cinemaService = cinemaService ?? CinemaService();

  final CinemaService _cinemaService;

  List<CinemaEntityModel> cinemas = const [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadCinemas() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      cinemas = await _cinemaService.getAllCinemas();
    } catch (_) {
      cinemas = const [];
      errorMessage = 'Unable to load cinemas. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

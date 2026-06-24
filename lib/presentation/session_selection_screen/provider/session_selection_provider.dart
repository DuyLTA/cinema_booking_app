import 'package:flutter/material.dart';

import '../../../models/booking_flow_models.dart';
import '../../../services/showtime_service.dart';

class SessionSelectionProvider extends ChangeNotifier {
  final ShowtimeService _showtimeService = ShowtimeService();

  bool isLoading = false;
  String? errorMessage;
  List<BookingSessionModel> sessions = [];
  BookingSessionModel? selectedSession;
  int selectedDateIndex = 0;
  String selectedRegion = 'All Regions';

  List<DateTime> get dates {
    final now = DateTime.now();
    return List.generate(
      4,
      (index) => DateTime(now.year, now.month, now.day + index),
    );
  }

  List<String> get regions {
    final values =
        sessions
            .map(_regionForSession)
            .where((region) => region.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return values.isEmpty ? ['All Regions'] : values;
  }

  List<BookingSessionModel> get filteredSessions {
    final selectedDate = dates[selectedDateIndex];
    return sessions.where((session) {
      final sameDay =
          session.startTime.year == selectedDate.year &&
          session.startTime.month == selectedDate.month &&
          session.startTime.day == selectedDate.day;
      final sameRegion =
          selectedRegion == 'All Regions' ||
          _regionForSession(session).toLowerCase() ==
              selectedRegion.toLowerCase();
      return sameDay && sameRegion;
    }).toList();
  }

  Map<String, List<BookingSessionModel>> get sessionsByCinema {
    final grouped = <String, List<BookingSessionModel>>{};
    for (final session in filteredSessions) {
      grouped.putIfAbsent(session.cinemaName, () => []).add(session);
    }

    for (final group in grouped.values) {
      group.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    return grouped;
  }

  Future<void> loadSessions(String movieId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      sessions = await _showtimeService.getSessionsForMovie(movieId: movieId);
      if (sessions.isNotEmpty) {
        final availableRegions = regions;
        if (availableRegions.isNotEmpty) {
          selectedRegion = availableRegions.first;
        }
        _syncDateToFirstAvailableSession();
        _syncSelectedSessionToFilter();
      } else {
        selectedSession = null;
      }
    } catch (e) {
      errorMessage = e.toString();
      sessions = [];
      selectedSession = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectDate(int index) {
    selectedDateIndex = index;
    _syncSelectedSessionToFilter();
    notifyListeners();
  }

  void selectRegion(String region) {
    selectedRegion = region;
    _syncSelectedSessionToFilter();
    notifyListeners();
  }

  void selectSession(BookingSessionModel session) {
    if (!_isSessionSelectable(session)) {
      selectedSession = null;
      notifyListeners();
      return;
    }

    selectedSession = session;
    notifyListeners();
  }

  void _syncDateToFirstAvailableSession() {
    final session = sessions.firstWhere(
      _isInVisibleDateRange,
      orElse: () => sessions.first,
    );
    final index = dates.indexWhere(
      (date) =>
          date.year == session.startTime.year &&
          date.month == session.startTime.month &&
          date.day == session.startTime.day,
    );
    if (index >= 0) {
      selectedDateIndex = index;
    }
  }

  void _syncSelectedSessionToFilter() {
    final visibleSessions = filteredSessions;
    if (visibleSessions.isEmpty) {
      selectedSession = null;
      return;
    }

    final currentSession = selectedSession;
    final stillVisible =
        currentSession != null &&
        visibleSessions.any((session) => session.id == currentSession.id) &&
        _isSessionSelectable(currentSession);

    selectedSession = stillVisible ? currentSession : null;
  }

  bool _isInVisibleDateRange(BookingSessionModel session) {
    return dates.any(
      (date) =>
          date.year == session.startTime.year &&
          date.month == session.startTime.month &&
          date.day == session.startTime.day,
    );
  }

  bool _isSessionSelectable(BookingSessionModel session) {
    return !session.startTime.isBefore(DateTime.now());
  }

  String _regionForSession(BookingSessionModel session) {
    final text = '${session.cinemaLocation} ${session.cinemaAddress}'
        .trim()
        .toLowerCase();

    if (text.contains('ha noi') || text.contains('hanoi')) {
      return 'Ha Noi';
    }
    if (text.contains('da nang') || text.contains('danang')) {
      return 'Da Nang';
    }
    if (text.contains('ho chi minh') ||
        text.contains('hcm') ||
        text.contains('district')) {
      return 'Ho Chi Minh City';
    }

    return session.cinemaLocation.trim();
  }
}

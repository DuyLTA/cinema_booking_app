import 'package:flutter/material.dart';

import '../../../models/booking_flow_models.dart';
import '../../../models/cinema_schedule_model.dart';
import '../../../models/movie_model.dart';
import '../../../services/movie_service.dart';
import '../../../services/showtime_service.dart';

class CinemaScheduleProvider extends ChangeNotifier {
  CinemaScheduleProvider({
    required this.cinemaId,
    MovieService? movieService,
    ShowtimeService? showtimeService,
  }) : _movieService = movieService ?? MovieService(),
       _showtimeService = showtimeService ?? ShowtimeService();

  final String cinemaId;
  final MovieService _movieService;
  final ShowtimeService _showtimeService;

  List<DateTime> dates = const [];
  List<BookingSessionModel> _sessions = const [];
  Map<String, MovieModel> _moviesById = const {};
  int selectedDateIndex = 0;
  bool isLoading = false;
  String? errorMessage;

  DateTime get selectedDate => dates[selectedDateIndex];

  List<CinemaMovieScheduleModel> get schedules {
    if (dates.isEmpty) return const [];

    final grouped = <String, List<BookingSessionModel>>{};
    for (final session in _sessions) {
      if (!_isSameDate(session.startTime, selectedDate)) continue;
      grouped.putIfAbsent(session.movieId, () => []).add(session);
    }

    return grouped.entries
        .where((entry) => _moviesById.containsKey(entry.key))
        .map(
          (entry) => CinemaMovieScheduleModel(
            movie: _moviesById[entry.key]!,
            sessions: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) {
        final aTime = a.sessions.first.startTime;
        final bTime = b.sessions.first.startTime;
        return aTime.compareTo(bTime);
      });
  }

  Future<void> loadSchedule() async {
    isLoading = true;
    errorMessage = null;
    _generateDates();
    notifyListeners();

    try {
      final start = dates.first;
      final end = dates.last.add(const Duration(days: 1));
      final results = await Future.wait([
        _showtimeService.getSessionsForCinema(
          cinemaId: cinemaId,
          from: start,
          to: end,
        ),
        _movieService.getAllMovies(),
      ]);

      _sessions = results[0] as List<BookingSessionModel>;
      final movies = results[1] as List<MovieModel>;
      _moviesById = {for (final movie in movies) movie.id: movie};
    } catch (_) {
      _sessions = const [];
      _moviesById = const {};
      errorMessage = 'Unable to load this cinema schedule.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectDate(int index) {
    if (index < 0 || index >= dates.length || index == selectedDateIndex) {
      return;
    }
    selectedDateIndex = index;
    notifyListeners();
  }

  bool isSessionAvailable(BookingSessionModel session) {
    return session.startTime.isAfter(DateTime.now());
  }

  void _generateDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    dates = List.generate(7, (index) => today.add(Duration(days: index)));
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

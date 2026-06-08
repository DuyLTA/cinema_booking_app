import 'package:flutter/material.dart';

import '../../../core/utils/movie_ui_mapper.dart';
import '../../../models/cinema_entity_model.dart';
import '../../../services/cinema_service.dart';
import '../../../services/movie_service.dart';
import '../../../services/showtime_service.dart';
import '../models/movie_list_model.dart';

class MovieListProvider extends ChangeNotifier {
  final MovieService _movieService = MovieService();
  final CinemaService _cinemaService = CinemaService();
  final ShowtimeService _showtimeService = ShowtimeService();

  MovieListModel movieListModel = MovieListModel();
  TextEditingController searchController = TextEditingController();

  String selectedCinema = 'All Cinemas';
  int selectedDateIndex = 0;
  bool isLoading = false;
  String searchQuery = '';
  String? errorMessage;

  List<String> cinemas = ['All Cinemas'];
  List<DateItemModel> dates = [];
  List<CinemaEntityModel> _cinemaEntities = [];
  List<MovieItemModel> _allMovies = [];
  List<MovieItemModel> _displayMovies = [];

  List<MovieItemModel> get filteredMovies {
    if (searchQuery.isEmpty) {
      return _displayMovies;
    }

    final keyword = searchQuery.toLowerCase();
    return _displayMovies.where((movie) {
      return (movie.title ?? '').toLowerCase().contains(keyword) ||
          (movie.durationGenre ?? '').toLowerCase().contains(keyword);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _generateDates();

      final cinemaResults = await _cinemaService.getAllCinemas();
      _cinemaEntities = cinemaResults;
      cinemas = ['All Cinemas', ...cinemaResults.map((cinema) => cinema.name)];

      final nowShowing = await _movieService.getMoviesByStatus(
        status: 'now_showing',
      );
      final comingSoon = await _movieService.getMoviesByStatus(
        status: 'coming_soon',
      );

      _allMovies = [...nowShowing, ...comingSoon]
          .map(MovieUiMapper.toMovieListItem)
          .toList();
      _displayMovies = List<MovieItemModel>.from(_allMovies);
    } catch (e) {
      errorMessage = e.toString();
      _allMovies = [];
      _displayMovies = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _generateDates() {
    final now = DateTime.now();
    const weekdayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    dates = List.generate(7, (index) {
      final date = DateTime(now.year, now.month, now.day + index);
      return DateItemModel(
        dayLabel: index == 0 ? 'TODAY' : weekdayLabels[date.weekday - 1],
        dateNumber: date.day.toString().padLeft(2, '0'),
        date: date,
      );
    });
  }

  Future<void> selectCinema(String cinema) async {
    selectedCinema = cinema;
    await _refreshDisplayedMovies();
  }

  Future<void> selectDate(int index) async {
    selectedDateIndex = index;
    await _refreshDisplayedMovies();
  }

  Future<void> _refreshDisplayedMovies() async {
    if (selectedCinema == 'All Cinemas') {
      _displayMovies = List<MovieItemModel>.from(_allMovies);
      notifyListeners();
      return;
    }

    try {
      final cinema = _cinemaEntities.firstWhere(
        (item) => item.name == selectedCinema,
      );
      final selectedDate = dates[selectedDateIndex].date;
      final movieIds = await _showtimeService.getMovieIdsForCinema(
        cinemaId: cinema.id,
        date: selectedDate,
      );

      _displayMovies = _allMovies
          .where((movie) => movieIds.contains(movie.id))
          .toList();
    } catch (e) {
      _displayMovies = [];
      errorMessage = e.toString();
    }

    notifyListeners();
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    notifyListeners();
  }
}

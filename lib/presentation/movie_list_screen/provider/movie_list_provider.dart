import 'package:flutter/material.dart';

import '../../../core/utils/movie_ui_mapper.dart';
import '../../../models/cinema_entity_model.dart';
import '../../../services/movie_rating_service.dart';
import '../../../services/cinema_service.dart';
import '../../../services/movie_service.dart';
import '../../../services/showtime_service.dart';
import '../models/movie_list_model.dart';

class MovieListProvider extends ChangeNotifier {
  final MovieService _movieService = MovieService();
  final MovieRatingService _movieRatingService = MovieRatingService();
  final CinemaService _cinemaService = CinemaService();
  final ShowtimeService _showtimeService = ShowtimeService();

  MovieListModel movieListModel = MovieListModel();
  TextEditingController searchController = TextEditingController();

  String selectedCinema = 'All Cinemas';
  String selectedGenre = 'All Genres';
  String selectedRatingFilter = 'All Ratings';
  int selectedDateIndex = 0;
  bool isLoading = false;
  String searchQuery = '';
  String? errorMessage;

  List<String> cinemas = ['All Cinemas'];
  List<String> genres = ['All Genres'];
  final List<String> ratingFilters = const [
    'All Ratings',
    '5 Stars',
    '4+ Stars',
    '3+ Stars',
    '2+ Stars',
    '1+ Stars',
  ];
  List<DateItemModel> dates = [];
  List<CinemaEntityModel> _cinemaEntities = [];
  List<MovieItemModel> _allMovies = [];
  List<MovieItemModel> _displayMovies = [];

  List<MovieItemModel> get filteredMovies {
    final keyword = searchQuery.toLowerCase();
    return _displayMovies.where((movie) {
      final matchesSearch =
          keyword.isEmpty ||
          (movie.title ?? '').toLowerCase().contains(keyword) ||
          (movie.durationGenre ?? '').toLowerCase().contains(keyword) ||
          (movie.genre ?? '').toLowerCase().contains(keyword);
      final matchesGenre =
          selectedGenre == 'All Genres' ||
          _movieGenres(
            movie,
          ).any((genre) => genre.toLowerCase() == selectedGenre.toLowerCase());
      final matchesRating = _matchesRatingFilter(movie);

      return matchesSearch && matchesGenre && matchesRating;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> initialize({String? initialCinemaId}) async {
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

      final movies = [...nowShowing, ...comingSoon];
      final ratingStats = await _movieRatingService.getRatingStatsForMovies(
        movies.map((movie) => movie.id).toList(),
      );

      _allMovies = movies.map((movie) {
        final item = MovieUiMapper.toMovieListItem(movie);
        final stats = ratingStats[movie.id];
        if (stats == null) {
          return item;
        }

        return item.copyWith(
          averageRating: stats.averageRating,
          ratingCount: stats.ratingCount,
        );
      }).toList();
      _displayMovies = List<MovieItemModel>.from(_allMovies);

      if (initialCinemaId != null && initialCinemaId.isNotEmpty) {
        final matchingCinemas = _cinemaEntities.where(
          (cinema) => cinema.id == initialCinemaId,
        );
        if (matchingCinemas.isNotEmpty) {
          selectedCinema = matchingCinemas.first.name;
          await _refreshDisplayedMovies();
        }
      }

      _refreshGenreOptions();
    } catch (e) {
      errorMessage = e.toString();
      _allMovies = [];
      _displayMovies = [];
      genres = ['All Genres'];
      selectedGenre = 'All Genres';
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

  void selectGenre(String genre) {
    selectedGenre = genre;
    notifyListeners();
  }

  void selectRatingFilter(String ratingFilter) {
    selectedRatingFilter = ratingFilter;
    notifyListeners();
  }

  Future<void> _refreshDisplayedMovies() async {
    errorMessage = null;

    if (selectedCinema == 'All Cinemas') {
      _displayMovies = List<MovieItemModel>.from(_allMovies);
      _refreshGenreOptions();
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
      final fallbackMovieIds = movieIds.isEmpty
          ? await _showtimeService.getMovieIdsForCinema(cinemaId: cinema.id)
          : movieIds;

      _displayMovies = _allMovies
          .where((movie) => fallbackMovieIds.contains(movie.id))
          .toList();
    } catch (e) {
      _displayMovies = [];
      errorMessage = e.toString();
    }

    _refreshGenreOptions();
    notifyListeners();
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void _refreshGenreOptions() {
    final genreSet = <String>{};

    for (final movie in _displayMovies) {
      genreSet.addAll(_movieGenres(movie));
    }

    final sortedGenres = genreSet.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    genres = ['All Genres', ...sortedGenres];
    if (!genres.any(
      (genre) => genre.toLowerCase() == selectedGenre.toLowerCase(),
    )) {
      selectedGenre = 'All Genres';
    }
  }

  List<String> _movieGenres(MovieItemModel movie) {
    return (movie.genre ?? '')
        .split(',')
        .map((genre) => genre.trim())
        .where((genre) => genre.isNotEmpty)
        .toList();
  }

  bool _matchesRatingFilter(MovieItemModel movie) {
    if (selectedRatingFilter == 'All Ratings') {
      return true;
    }

    final threshold = int.tryParse(selectedRatingFilter.substring(0, 1)) ?? 0;
    return movie.ratingCount > 0 && movie.averageRating >= threshold;
  }
}

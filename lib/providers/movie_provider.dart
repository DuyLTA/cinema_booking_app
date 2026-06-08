import 'package:flutter/foundation.dart';
import '../models/movie_model.dart';
import '../services/movie_service.dart';

class MovieProvider extends ChangeNotifier {
  final MovieService _movieService = MovieService();

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  List<MovieModel> _nowShowingMovies = [];
  List<MovieModel> _comingSoonMovies = [];
  List<MovieModel> _allMovies = [];
  List<MovieModel> _filteredMovies = [];
  String _selectedStatus = 'now_showing'; // 'now_showing' or 'coming_soon'
  String _searchKeyword = '';

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MovieModel> get movies =>
      _filteredMovies.isEmpty ? _allMovies : _filteredMovies;
  List<MovieModel> get nowShowingMovies => _nowShowingMovies;
  List<MovieModel> get comingSoonMovies => _comingSoonMovies;
  List<MovieModel> get allMovies => _allMovies;
  String get selectedStatus => _selectedStatus;
  String get searchKeyword => _searchKeyword;

  /// Load movies by status
  ///
  /// Parameters:
  /// - [status]: 'now_showing' or 'coming_soon'
  Future<void> loadMoviesByStatus({required String status}) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedStatus = status;
    _searchKeyword = ''; // Clear search when changing status
    _filteredMovies = [];
    notifyListeners();

    try {
      _allMovies = await _movieService.getMoviesByStatus(status: status);
    } catch (e) {
      _errorMessage = e.toString();
      _allMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all now showing movies
  Future<void> loadNowShowingMovies() async {
    await loadMoviesByStatus(status: 'now_showing');
  }

  /// Load all coming soon movies
  Future<void> loadComingSoonMovies() async {
    await loadMoviesByStatus(status: 'coming_soon');
  }

  /// Load both now showing and coming soon sections
  Future<void> loadMovieSections() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nowShowing = await _movieService.getMoviesByStatus(
        status: 'now_showing',
      );
      final comingSoon = await _movieService.getMoviesByStatus(
        status: 'coming_soon',
      );

      _nowShowingMovies = nowShowing;
      _comingSoonMovies = comingSoon;
    } catch (e) {
      _errorMessage = e.toString();
      _nowShowingMovies = [];
      _comingSoonMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all movies (no status filter)
  Future<void> loadAllMovies() async {
    _isLoading = true;
    _errorMessage = null;
    _searchKeyword = '';
    _filteredMovies = [];
    notifyListeners();

    try {
      _allMovies = await _movieService.getAllMovies();
    } catch (e) {
      _errorMessage = e.toString();
      _allMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search movies by keyword
  ///
  /// Parameters:
  /// - [keyword]: Search keyword to filter by title or genre
  ///
  /// This method filters from the already loaded movies
  /// If you need to search across all movies, call [searchMoviesFromServer] instead
  void searchMovies({required String keyword}) {
    _searchKeyword = keyword;

    if (keyword.isEmpty) {
      _filteredMovies = [];
    } else {
      final lowerKeyword = keyword.toLowerCase();
      _filteredMovies = _allMovies.where((movie) {
        return movie.title.toLowerCase().contains(lowerKeyword) ||
            (movie.genre?.toLowerCase().contains(lowerKeyword) ?? false);
      }).toList();
    }

    notifyListeners();
  }

  /// Search movies from server (with optional status filter)
  ///
  /// Parameters:
  /// - [keyword]: Search keyword
  /// - [status]: Optional status filter
  Future<void> searchMoviesFromServer({
    required String keyword,
    String? status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _searchKeyword = keyword;
    notifyListeners();

    try {
      _filteredMovies = await _movieService.searchMovies(
        keyword: keyword,
        status: status,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _filteredMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear search and show all movies
  void clearSearch() {
    _searchKeyword = '';
    _filteredMovies = [];
    notifyListeners();
  }

  /// Switch between status tabs
  ///
  /// Parameters:
  /// - [status]: 'now_showing' or 'coming_soon'
  Future<void> switchStatus({required String status}) async {
    if (_selectedStatus != status) {
      await loadMoviesByStatus(status: status);
    }
  }

  /// Get a single movie by ID
  ///
  /// Parameters:
  /// - [movieId]: Movie UUID
  ///
  /// Returns: MovieModel if found, null otherwise
  Future<MovieModel?> getMovieById({required String movieId}) async {
    try {
      return await _movieService.getMovieById(movieId: movieId);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

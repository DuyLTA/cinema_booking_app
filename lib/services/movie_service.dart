import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movie_model.dart';

class MovieService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all movies with a specific status
  ///
  /// Parameters:
  /// - [status]: Movie status ('now_showing', 'coming_soon', 'ended')
  ///
  /// Returns: List of MovieModel objects sorted by release date
  /// Throws: Exception if query fails
  Future<List<MovieModel>> getMoviesByStatus({required String status}) async {
    try {
      final response = await _supabase
          .from('movies')
          .select()
          .eq('status', status)
          .order('release_date', ascending: false)
          .timeout(const Duration(seconds: 10));

      return (response as List)
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch movies: $e');
    }
  }

  /// Get all now showing movies
  ///
  /// Returns: List of MovieModel objects
  /// Throws: Exception if query fails
  Future<List<MovieModel>> getNowShowingMovies() async {
    return getMoviesByStatus(status: 'now_showing');
  }

  /// Get all coming soon movies
  ///
  /// Returns: List of MovieModel objects
  /// Throws: Exception if query fails
  Future<List<MovieModel>> getComingSoonMovies() async {
    return getMoviesByStatus(status: 'coming_soon');
  }

  /// Get a single movie by ID
  ///
  /// Parameters:
  /// - [movieId]: Movie UUID
  ///
  /// Returns: MovieModel if found, null otherwise
  /// Throws: Exception if query fails
  Future<MovieModel?> getMovieById({required String movieId}) async {
    try {
      final response = await _supabase
          .from('movies')
          .select()
          .eq('id', movieId)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      if (response == null) {
        return null;
      }

      return MovieModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch movie: $e');
    }
  }

  /// Search movies by title or genre
  ///
  /// Parameters:
  /// - [keyword]: Search keyword
  /// - [status]: Optional movie status filter
  ///
  /// Returns: List of MovieModel objects matching the search
  /// Throws: Exception if query fails
  Future<List<MovieModel>> searchMovies({
    required String keyword,
    String? status,
  }) async {
    try {
      var query = _supabase.from('movies').select();

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('title');

      // Client-side filtering for search
      final lowerKeyword = keyword.toLowerCase();
      final filtered = (response as List)
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .where((movie) {
            return movie.title.toLowerCase().contains(lowerKeyword) ||
                (movie.genre?.toLowerCase().contains(lowerKeyword) ?? false);
          })
          .toList();

      return filtered;
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }

  /// Get all movies (no filter)
  ///
  /// Returns: List of all MovieModel objects
  /// Throws: Exception if query fails
  Future<List<MovieModel>> getAllMovies() async {
    try {
      final response = await _supabase
          .from('movies')
          .select()
          .order('release_date', ascending: false);

      return (response as List)
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all movies: $e');
    }
  }

  /// Get movies by genre
  ///
  /// Parameters:
  /// - [genre]: Movie genre
  ///
  /// Returns: List of MovieModel objects with the specified genre
  /// Throws: Exception if query fails
  Future<List<MovieModel>> getMoviesByGenre({required String genre}) async {
    try {
      final response = await _supabase
          .from('movies')
          .select()
          .eq('genre', genre)
          .order('release_date', ascending: false);

      return (response as List)
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch movies by genre: $e');
    }
  }
}

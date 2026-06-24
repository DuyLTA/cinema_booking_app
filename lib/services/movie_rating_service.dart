import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/movie_rating_model.dart';

class MovieRatingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, MovieRatingStats>> getRatingStatsForMovies(
    List<String> movieIds,
  ) async {
    if (movieIds.isEmpty) {
      return const {};
    }

    try {
      final response = await _supabase
          .from('movie_rating_stats')
          .select()
          .inFilter('movie_id', movieIds);

      final stats = <String, MovieRatingStats>{};
      for (final item in response as List) {
        final stat = MovieRatingStats.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
        if (stat.movieId.isNotEmpty) {
          stats[stat.movieId] = stat;
        }
      }

      return stats;
    } catch (_) {
      return const {};
    }
  }

  Future<MovieRatingStats> getRatingStatsForMovie(String movieId) async {
    final stats = await getRatingStatsForMovies([movieId]);
    return stats[movieId] ??
        MovieRatingStats(movieId: movieId, averageRating: 0, ratingCount: 0);
  }

  Future<int?> getCurrentUserRating(String movieId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || movieId.isEmpty) {
      return null;
    }

    try {
      final response = await _supabase
          .from('movie_ratings')
          .select('rating')
          .eq('movie_id', movieId)
          .eq('user_id', userId)
          .maybeSingle();

      return response?['rating'] as int?;
    } catch (_) {
      return null;
    }
  }

  Future<void> submitRating({
    required String movieId,
    required int rating,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Please sign in before rating this movie.');
    }
    if (movieId.isEmpty) {
      throw Exception('Movie is not available.');
    }
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5 stars.');
    }

    await _supabase.from('movie_ratings').upsert({
      'movie_id': movieId,
      'user_id': userId,
      'rating': rating,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'movie_id,user_id');
  }
}

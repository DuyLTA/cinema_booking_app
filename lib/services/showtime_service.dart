import 'package:supabase_flutter/supabase_flutter.dart';

class ShowtimeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Set<String>> getMovieIdsForCinema({
    required String cinemaId,
    DateTime? date,
  }) async {
    try {
      var query = _supabase
          .from('showtimes')
          .select('movie_id, start_time')
          .eq('cinema_id', cinemaId)
          .eq('is_active', true);

      final response = await query.timeout(const Duration(seconds: 10));
      final movieIds = <String>{};

      for (final row in response as List) {
        final movieId = row['movie_id'] as String?;
        final startTimeRaw = row['start_time'] as String?;
        if (movieId == null) continue;

        if (date != null && startTimeRaw != null) {
          final startTime = DateTime.parse(startTimeRaw).toLocal();
          final sameDay = startTime.year == date.year &&
              startTime.month == date.month &&
              startTime.day == date.day;
          if (!sameDay) continue;
        }

        movieIds.add(movieId);
      }

      return movieIds;
    } catch (e) {
      throw Exception('Failed to fetch showtimes: $e');
    }
  }
}

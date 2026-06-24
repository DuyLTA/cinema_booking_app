import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking_flow_models.dart';

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
          final sameDay =
              startTime.year == date.year &&
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

  Future<List<BookingSessionModel>> getSessionsForMovie({
    required String movieId,
  }) async {
    try {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final response = await _supabase
          .from('showtimes')
          .select(
            'id,movie_id,cinema_id,room_id,start_time,end_time,format,is_active,'
            'cinemas(name,location,address),rooms(room_name)',
          )
          .eq('movie_id', movieId)
          .eq('is_active', true)
          .gte('start_time', startOfToday.toUtc().toIso8601String())
          .order('start_time', ascending: true)
          .timeout(const Duration(seconds: 10));

      final sessions = (response as List)
          .map(
            (json) => BookingSessionModel.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList();

      final priceMap = await _getBasePricesForShowtimes(
        sessions.map((session) => session.id).toList(),
      );

      return sessions
          .map(
            (session) =>
                session.copyWith(basePrice: priceMap[session.id] ?? 65000),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch movie sessions: $e');
    }
  }

  Future<List<BookingSessionModel>> getSessionsForCinema({
    required String cinemaId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final response = await _supabase
          .from('showtimes')
          .select(
            'id,movie_id,cinema_id,room_id,start_time,end_time,format,is_active,'
            'cinemas(name,location,address),rooms(room_name)',
          )
          .eq('cinema_id', cinemaId)
          .eq('is_active', true)
          .gte('start_time', from.toUtc().toIso8601String())
          .lt('start_time', to.toUtc().toIso8601String())
          .order('start_time', ascending: true)
          .timeout(const Duration(seconds: 10));

      final sessions = (response as List)
          .map(
            (json) => BookingSessionModel.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList();
      final priceMap = await _getBasePricesForShowtimes(
        sessions.map((session) => session.id).toList(),
      );

      return sessions
          .map(
            (session) =>
                session.copyWith(basePrice: priceMap[session.id] ?? 65000),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch cinema sessions: $e');
    }
  }

  Future<List<ShowtimeSeatModel>> getSeatsForShowtime({
    required String showtimeId,
  }) async {
    try {
      final response = await _supabase
          .from('showtime_seats')
          .select(
            'id,status,seats(id,seat_code,row_label,seat_number,type,is_active)',
          )
          .eq('showtime_id', showtimeId)
          .order('id', ascending: true)
          .timeout(const Duration(seconds: 10));

      final seats = (response as List)
          .map(
            (json) => ShowtimeSeatModel.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .where((seat) => seat.seatCode.isNotEmpty)
          .toList();

      seats.sort((a, b) {
        final rowCompare = a.rowLabel.compareTo(b.rowLabel);
        if (rowCompare != 0) return rowCompare;
        return a.seatNumber.compareTo(b.seatNumber);
      });

      return seats;
    } catch (e) {
      throw Exception('Failed to fetch showtime seats: $e');
    }
  }

  Future<Map<String, double>> _getBasePricesForShowtimes(
    List<String> showtimeIds,
  ) async {
    if (showtimeIds.isEmpty) {
      return const {};
    }

    try {
      final response = await _supabase
          .from('ticket_prices')
          .select('showtime_id,price')
          .inFilter('showtime_id', showtimeIds);

      final prices = <String, double>{};
      for (final row in response as List) {
        final map = Map<String, dynamic>.from(row as Map);
        final showtimeId = map['showtime_id'] as String?;
        final price = map['price'];
        if (showtimeId == null || prices.containsKey(showtimeId)) continue;
        prices[showtimeId] = price is num ? price.toDouble() : 65000;
      }

      return prices;
    } catch (_) {
      return const {};
    }
  }
}

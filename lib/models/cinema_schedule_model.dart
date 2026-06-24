import 'booking_flow_models.dart';
import 'movie_model.dart';

class CinemaMovieScheduleModel {
  const CinemaMovieScheduleModel({required this.movie, required this.sessions});

  final MovieModel movie;
  final List<BookingSessionModel> sessions;

  Map<String, List<BookingSessionModel>> get sessionsByFormat {
    final result = <String, List<BookingSessionModel>>{};
    for (final session in sessions) {
      result.putIfAbsent(session.format.toUpperCase(), () => []).add(session);
    }
    return result;
  }
}

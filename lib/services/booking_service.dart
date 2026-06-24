import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booked_ticket_model.dart';
import '../models/booking_flow_models.dart';
import 'ticket_service.dart';

class BookingService {
  BookingService({TicketService? ticketService})
    : _ticketService = ticketService ?? TicketService();

  final SupabaseClient _supabase = Supabase.instance.client;
  final TicketService _ticketService;

  Future<void> finalizeSuccessfulBooking({
    required BookedTicketModel ticket,
    required List<ShowtimeSeatModel> selectedSeats,
  }) async {
    if (selectedSeats.isEmpty) {
      await _ticketService.saveTicket(ticket);
      return;
    }

    final showtimeSeatIds = selectedSeats
        .map((seat) => seat.showtimeSeatId)
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList();

    if (showtimeSeatIds.isEmpty) {
      throw Exception('Selected seats are missing showtime seat ids.');
    }

    try {
      final existingRows = await _supabase
          .from('showtime_seats')
          .select('id,status')
          .inFilter('id', showtimeSeatIds);

      final existingSeats = (existingRows as List)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList();

      if (existingSeats.length != showtimeSeatIds.length) {
        throw Exception(
          'Some showtime seats were not found or cannot be read. '
          'Found ${existingSeats.length}/${showtimeSeatIds.length}.',
        );
      }

      final unavailableSeats = existingSeats.where((row) {
        final status = (row['status'] as String? ?? '').trim().toLowerCase();
        return status != 'available';
      }).toList();

      if (unavailableSeats.isNotEmpty) {
        throw Exception(
          'Some seats are no longer available: '
          '${unavailableSeats.map((row) => row['id']).join(', ')}.',
        );
      }

      await _supabase
          .from('showtime_seats')
          .update({'status': 'booked'})
          .inFilter('id', showtimeSeatIds);

      final syncedRows = await _supabase
          .from('showtime_seats')
          .select('id,status')
          .inFilter('id', showtimeSeatIds);

      final syncedSeats = (syncedRows as List)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList();

      final syncedCount = syncedSeats
          .where(
            (row) =>
                (row['status'] as String? ?? '').trim().toLowerCase() ==
                'booked',
          )
          .length;

      if (syncedCount != showtimeSeatIds.length) {
        throw Exception(
          'Seat booking sync is incomplete. Synced $syncedCount/${showtimeSeatIds.length} seats.',
        );
      }
    } catch (error) {
      throw Exception('Failed to mark seats as booked: $error');
    }

    await _ticketService.saveTicket(ticket);
  }
}

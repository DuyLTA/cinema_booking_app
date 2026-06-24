import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booked_ticket_model.dart';

class TicketService {
  static final Map<String, List<BookedTicketModel>> _ticketsByUser = {};
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<BookedTicketModel>> getTicketsForUser(String userId) async {
    try {
      final rows = await _supabase
          .from('booked_tickets')
          .select('payload')
          .eq('user_id', userId)
          .order('booked_at', ascending: false);

      return rows
          .map<BookedTicketModel>(
            (row) => BookedTicketModel.fromJson(
              Map<String, dynamic>.from(row['payload'] as Map),
            ),
          )
          .toList();
    } catch (_) {
      // The demo SQL may not be installed yet; keep the app usable locally.
    }

    final tickets = List<BookedTicketModel>.from(_ticketsByUser[userId] ?? []);
    tickets.sort((a, b) => b.bookedAt.compareTo(a.bookedAt));
    return tickets;
  }

  Future<void> saveTicket(BookedTicketModel ticket) async {
    final userTickets = _ticketsByUser.putIfAbsent(ticket.userId, () => []);
    final existingIndex = userTickets.indexWhere(
      (item) => item.id == ticket.id,
    );

    if (existingIndex >= 0) {
      userTickets[existingIndex] = ticket;
      return;
    }

    userTickets.add(ticket);

    try {
      await _supabase.from('booked_tickets').upsert({
        'id': ticket.id,
        'user_id': ticket.userId,
        'payload': ticket.toJson(),
        'booked_at': ticket.bookedAt.toIso8601String(),
      });
    } catch (_) {
      // Local fallback already saved the ticket for the current app session.
    }
  }
}

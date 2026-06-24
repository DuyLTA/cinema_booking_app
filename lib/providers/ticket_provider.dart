import 'package:flutter/foundation.dart';

import '../models/booked_ticket_model.dart';
import '../services/booking_service.dart';
import '../services/ticket_service.dart';

class TicketProvider extends ChangeNotifier {
  TicketProvider({TicketService? ticketService})
    : _ticketService = ticketService ?? TicketService();

  final TicketService _ticketService;
  final BookingService _bookingService = BookingService();

  bool isLoading = false;
  String? errorMessage;
  List<BookedTicketModel> tickets = [];

  Future<void> loadTickets(String? userId) async {
    if (userId == null || userId.isEmpty) {
      tickets = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      tickets = await _ticketService.getTicketsForUser(userId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveTicket(BookedTicketModel ticket) async {
    await _ticketService.saveTicket(ticket);
    await loadTickets(ticket.userId);
  }

  Future<void> finalizeSuccessfulBooking(BookedTicketModel ticket) async {
    await _bookingService.finalizeSuccessfulBooking(
      ticket: ticket,
      selectedSeats: ticket.selectedSeats,
    );
    await loadTickets(ticket.userId);
  }
}

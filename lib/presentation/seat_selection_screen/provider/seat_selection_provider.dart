import 'package:flutter/material.dart';

import '../../../models/booking_flow_models.dart';
import '../../../services/showtime_service.dart';

class SeatSelectionProvider extends ChangeNotifier {
  final ShowtimeService _showtimeService = ShowtimeService();

  bool isLoading = false;
  String? errorMessage;
  List<ShowtimeSeatModel> seats = [];
  final Set<String> selectedShowtimeSeatIds = {};

  List<ShowtimeSeatModel> get selectedSeats => seats
      .where((seat) => selectedShowtimeSeatIds.contains(seat.showtimeSeatId))
      .toList();

  Future<void> loadSeats(String showtimeId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      seats = await _showtimeService.getSeatsForShowtime(
        showtimeId: showtimeId,
      );
      selectedShowtimeSeatIds.clear();
    } catch (e) {
      errorMessage = e.toString();
      seats = [];
      selectedShowtimeSeatIds.clear();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleSeat(ShowtimeSeatModel seat) {
    if (!seat.isBookable) return;

    if (selectedShowtimeSeatIds.contains(seat.showtimeSeatId)) {
      selectedShowtimeSeatIds.remove(seat.showtimeSeatId);
    } else {
      selectedShowtimeSeatIds.add(seat.showtimeSeatId);
    }
    notifyListeners();
  }

  bool isSelected(ShowtimeSeatModel seat) {
    return selectedShowtimeSeatIds.contains(seat.showtimeSeatId);
  }

  double totalAmount() {
    return selectedSeats.fold(0, (sum, seat) {
      final price = switch (seat.type.toLowerCase()) {
        'vip' => 80000.0,
        'couple' => 130000.0,
        _ => 65000.0,
      };
      return sum + price;
    });
  }
}

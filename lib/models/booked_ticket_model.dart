import 'booking_flow_models.dart';

String buildBookingId({
  required String txnRef,
  required BookingSessionModel session,
}) {
  final trimmedTxnRef = txnRef.trim();
  if (trimmedTxnRef.isNotEmpty) {
    return trimmedTxnRef;
  }

  return 'CB${session.id.hashCode.abs()}${session.startTime.millisecondsSinceEpoch}';
}

class BookedTicketModel {
  const BookedTicketModel({
    required this.id,
    required this.userId,
    required this.movieTitle,
    required this.session,
    required this.selectedSeats,
    required this.selectedFoods,
    required this.total,
    required this.paymentMethod,
    required this.txnRef,
    required this.bookedAt,
  });

  final String id;
  final String userId;
  final String movieTitle;
  final BookingSessionModel session;
  final List<ShowtimeSeatModel> selectedSeats;
  final List<SelectedFoodItemModel> selectedFoods;
  final double total;
  final String paymentMethod;
  final String txnRef;
  final DateTime bookedAt;

  String get seatsLabel {
    if (selectedSeats.isEmpty) return 'No seats';
    return selectedSeats.map((seat) => seat.seatCode).join(', ');
  }

  int get foodQuantity {
    return selectedFoods.fold(0, (sum, item) => sum + item.quantity);
  }

  String get qrPayload {
    return [
      'CINEBOOKING',
      id,
      userId,
      session.id,
      seatsLabel,
      txnRef,
    ].join('|');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'movieTitle': movieTitle,
      'session': _sessionToJson(session),
      'selectedSeats': selectedSeats.map(_seatToJson).toList(),
      'selectedFoods': selectedFoods.map(_selectedFoodToJson).toList(),
      'total': total,
      'paymentMethod': paymentMethod,
      'txnRef': txnRef,
      'bookedAt': bookedAt.toIso8601String(),
    };
  }

  factory BookedTicketModel.fromJson(Map<String, dynamic> json) {
    return BookedTicketModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      movieTitle: json['movieTitle'] as String? ?? 'Movie',
      session: _sessionFromJson(
        Map<String, dynamic>.from((json['session'] as Map?) ?? {}),
      ),
      selectedSeats: ((json['selectedSeats'] as List?) ?? [])
          .map((item) => _seatFromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      selectedFoods: ((json['selectedFoods'] as List?) ?? [])
          .map(
            (item) =>
                _selectedFoodFromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      total: (json['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['paymentMethod'] as String? ?? 'VNPay QR Sandbox',
      txnRef: json['txnRef'] as String? ?? '',
      bookedAt:
          DateTime.tryParse(json['bookedAt'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
}

Map<String, dynamic> _sessionToJson(BookingSessionModel session) {
  return {
    'id': session.id,
    'movieId': session.movieId,
    'cinemaId': session.cinemaId,
    'roomId': session.roomId,
    'cinemaName': session.cinemaName,
    'cinemaLocation': session.cinemaLocation,
    'cinemaAddress': session.cinemaAddress,
    'roomName': session.roomName,
    'startTime': session.startTime.toIso8601String(),
    'endTime': session.endTime?.toIso8601String(),
    'format': session.format,
    'basePrice': session.basePrice,
  };
}

BookingSessionModel _sessionFromJson(Map<String, dynamic> json) {
  return BookingSessionModel(
    id: json['id'] as String? ?? '',
    movieId: json['movieId'] as String? ?? '',
    cinemaId: json['cinemaId'] as String? ?? '',
    roomId: json['roomId'] as String? ?? '',
    cinemaName: json['cinemaName'] as String? ?? 'Unknown Cinema',
    cinemaLocation: json['cinemaLocation'] as String? ?? '',
    cinemaAddress: json['cinemaAddress'] as String? ?? '',
    roomName: json['roomName'] as String? ?? 'Room',
    startTime:
        DateTime.tryParse(json['startTime'] as String? ?? '')?.toLocal() ??
        DateTime.now(),
    endTime: DateTime.tryParse(json['endTime'] as String? ?? '')?.toLocal(),
    format: json['format'] as String? ?? '2D',
    basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0,
  );
}

Map<String, dynamic> _seatToJson(ShowtimeSeatModel seat) {
  return {
    'showtimeSeatId': seat.showtimeSeatId,
    'seatId': seat.seatId,
    'seatCode': seat.seatCode,
    'rowLabel': seat.rowLabel,
    'seatNumber': seat.seatNumber,
    'type': seat.type,
    'status': seat.status,
    'isActive': seat.isActive,
  };
}

ShowtimeSeatModel _seatFromJson(Map<String, dynamic> json) {
  return ShowtimeSeatModel(
    showtimeSeatId: json['showtimeSeatId'] as String? ?? '',
    seatId: json['seatId'] as String? ?? '',
    seatCode: json['seatCode'] as String? ?? '',
    rowLabel: json['rowLabel'] as String? ?? '',
    seatNumber: json['seatNumber'] as int? ?? 0,
    type: json['type'] as String? ?? 'standard',
    status: json['status'] as String? ?? 'available',
    isActive: json['isActive'] as bool? ?? true,
  );
}

Map<String, dynamic> _selectedFoodToJson(SelectedFoodItemModel item) {
  return {
    'quantity': item.quantity,
    'food': {
      'id': item.food.id,
      'name': item.food.name,
      'category': item.food.category,
      'description': item.food.description,
      'imageUrl': item.food.imageUrl,
      'price': item.food.price,
      'isAvailable': item.food.isAvailable,
    },
  };
}

SelectedFoodItemModel _selectedFoodFromJson(Map<String, dynamic> json) {
  final food = Map<String, dynamic>.from((json['food'] as Map?) ?? {});
  return SelectedFoodItemModel(
    quantity: json['quantity'] as int? ?? 0,
    food: FoodItemModel(
      id: food['id'] as String? ?? '',
      name: food['name'] as String? ?? 'Snack',
      category: food['category'] as String? ?? 'Snacks',
      description: food['description'] as String? ?? '',
      imageUrl: food['imageUrl'] as String? ?? '',
      price: (food['price'] as num?)?.toDouble() ?? 0,
      isAvailable: food['isAvailable'] as bool? ?? true,
    ),
  );
}

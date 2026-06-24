class BookingSessionModel {
  const BookingSessionModel({
    required this.id,
    required this.movieId,
    required this.cinemaId,
    required this.roomId,
    required this.cinemaName,
    required this.cinemaLocation,
    required this.cinemaAddress,
    required this.roomName,
    required this.startTime,
    required this.endTime,
    required this.format,
    required this.basePrice,
  });

  final String id;
  final String movieId;
  final String cinemaId;
  final String roomId;
  final String cinemaName;
  final String cinemaLocation;
  final String cinemaAddress;
  final String roomName;
  final DateTime startTime;
  final DateTime? endTime;
  final String format;
  final double basePrice;

  factory BookingSessionModel.fromJson(Map<String, dynamic> json) {
    final cinema = Map<String, dynamic>.from((json['cinemas'] as Map?) ?? {});
    final room = Map<String, dynamic>.from((json['rooms'] as Map?) ?? {});

    return BookingSessionModel(
      id: json['id'] as String? ?? '',
      movieId: json['movie_id'] as String? ?? '',
      cinemaId: json['cinema_id'] as String? ?? '',
      roomId: json['room_id'] as String? ?? '',
      cinemaName: cinema['name'] as String? ?? 'Unknown Cinema',
      cinemaLocation: cinema['location'] as String? ?? '',
      cinemaAddress: cinema['address'] as String? ?? '',
      roomName: room['room_name'] as String? ?? 'Room',
      startTime:
          DateTime.tryParse(json['start_time'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      endTime: DateTime.tryParse(json['end_time'] as String? ?? '')?.toLocal(),
      format: json['format'] as String? ?? '2D',
      basePrice: 0,
    );
  }

  BookingSessionModel copyWith({double? basePrice}) {
    return BookingSessionModel(
      id: id,
      movieId: movieId,
      cinemaId: cinemaId,
      roomId: roomId,
      cinemaName: cinemaName,
      cinemaLocation: cinemaLocation,
      cinemaAddress: cinemaAddress,
      roomName: roomName,
      startTime: startTime,
      endTime: endTime,
      format: format,
      basePrice: basePrice ?? this.basePrice,
    );
  }
}

class ShowtimeSeatModel {
  const ShowtimeSeatModel({
    required this.showtimeSeatId,
    required this.seatId,
    required this.seatCode,
    required this.rowLabel,
    required this.seatNumber,
    required this.type,
    required this.status,
    required this.isActive,
  });

  final String showtimeSeatId;
  final String seatId;
  final String seatCode;
  final String rowLabel;
  final int seatNumber;
  final String type;
  final String status;
  final bool isActive;

  String get normalizedType => type.trim().toLowerCase();

  String get normalizedStatus => status.trim().toLowerCase();

  bool get isBookable => isActive && normalizedStatus == 'available';

  bool get isBooked =>
      normalizedStatus == 'booked' ||
      normalizedStatus == 'reserved' ||
      normalizedStatus == 'held' ||
      normalizedStatus == 'used';

  bool get isBlocked => normalizedStatus == 'blocked' || !isActive;

  bool get isUnavailable => !isBookable;

  factory ShowtimeSeatModel.fromJson(Map<String, dynamic> json) {
    final seat = Map<String, dynamic>.from((json['seats'] as Map?) ?? {});

    return ShowtimeSeatModel(
      showtimeSeatId: json['id'] as String? ?? '',
      seatId: seat['id'] as String? ?? '',
      seatCode: seat['seat_code'] as String? ?? '',
      rowLabel: seat['row_label'] as String? ?? '',
      seatNumber: seat['seat_number'] as int? ?? 0,
      type: seat['type'] as String? ?? 'standard',
      status: json['status'] as String? ?? 'available',
      isActive: seat['is_active'] as bool? ?? true,
    );
  }
}

class FoodItemModel {
  const FoodItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.isAvailable,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final double price;
  final bool isAvailable;

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    final price = json['price'];
    return FoodItemModel(
      id: json['id'] as String? ?? '',
      name: json['product_name'] as String? ?? 'Snack',
      category: json['category'] as String? ?? 'Snacks',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      price: price is num ? price.toDouble() : 0,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }
}

class SelectedFoodItemModel {
  const SelectedFoodItemModel({required this.food, required this.quantity});

  final FoodItemModel food;
  final int quantity;

  double get lineTotal => food.price * quantity;
}

enum PaymentMethodType { vnpayQr }

class PaymentMethodModel {
  const PaymentMethodModel({
    required this.type,
    required this.name,
    required this.shortLabel,
    required this.iconColor,
  });

  final PaymentMethodType type;
  final String name;
  final String shortLabel;
  final int iconColor;
}

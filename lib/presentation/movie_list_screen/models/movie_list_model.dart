// ignore_for_file: must_be_immutable

/// This class is used in the [movie_list_screen] screen.
class MovieListModel {
  MovieListModel();
}

class MovieItemModel {
  String? id;
  String? title;
  String? durationGenre;
  String? genre;
  String? rating;
  String? posterImage;
  double averageRating;
  int ratingCount;

  MovieItemModel({
    this.id,
    this.title,
    this.durationGenre,
    this.genre,
    this.rating,
    this.posterImage,
    this.averageRating = 0,
    this.ratingCount = 0,
  });

  MovieItemModel copyWith({
    String? id,
    String? title,
    String? durationGenre,
    String? genre,
    String? rating,
    String? posterImage,
    double? averageRating,
    int? ratingCount,
  }) {
    return MovieItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      durationGenre: durationGenre ?? this.durationGenre,
      genre: genre ?? this.genre,
      rating: rating ?? this.rating,
      posterImage: posterImage ?? this.posterImage,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}

class DateItemModel {
  String? dayLabel;
  String? dateNumber;
  DateTime? date;

  DateItemModel({this.dayLabel, this.dateNumber, this.date});

  DateItemModel copyWith({
    String? dayLabel,
    String? dateNumber,
    DateTime? date,
  }) {
    return DateItemModel(
      dayLabel: dayLabel ?? this.dayLabel,
      dateNumber: dateNumber ?? this.dateNumber,
      date: date ?? this.date,
    );
  }
}

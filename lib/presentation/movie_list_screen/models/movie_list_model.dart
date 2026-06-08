// ignore_for_file: must_be_immutable

/// This class is used in the [movie_list_screen] screen.
class MovieListModel {
  MovieListModel();
}

class MovieItemModel {
  String? id;
  String? title;
  String? durationGenre;
  String? rating;
  String? posterImage;

  MovieItemModel({
    this.id,
    this.title,
    this.durationGenre,
    this.rating,
    this.posterImage,
  });

  MovieItemModel copyWith({
    String? id,
    String? title,
    String? durationGenre,
    String? rating,
    String? posterImage,
  }) {
    return MovieItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      durationGenre: durationGenre ?? this.durationGenre,
      rating: rating ?? this.rating,
      posterImage: posterImage ?? this.posterImage,
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

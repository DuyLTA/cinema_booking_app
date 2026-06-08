// ignore_for_file: must_be_immutable
class MovieDetailModel {
  MovieDetailModel({
    this.id,
    this.title,
    this.description,
    this.posterUrl,
    this.bannerUrl,
    this.trailerUrl,
    this.genre,
    this.director,
    this.language,
    this.subtitle,
    this.durationMinutes,
    this.ageRating,
    this.releaseDate,
    this.status,
  }) {
    id = id ?? '';
    title = title ?? '';
    description = description ?? '';
    posterUrl = posterUrl ?? '';
    bannerUrl = bannerUrl ?? '';
    trailerUrl = trailerUrl ?? '';
    genre = genre ?? '';
    director = director ?? '';
    language = language ?? '';
    subtitle = subtitle ?? '';
    durationMinutes = durationMinutes ?? 0;
    ageRating = ageRating ?? '';
    releaseDate = releaseDate ?? '';
    status = status ?? '';
  }

  String? id;
  String? title;
  String? description;
  String? posterUrl;
  String? bannerUrl;
  String? trailerUrl;
  String? genre;
  String? director;
  String? language;
  String? subtitle;
  int? durationMinutes;
  String? ageRating;
  String? releaseDate;
  String? status;

  MovieDetailModel copyWith({
    String? id,
    String? title,
    String? description,
    String? posterUrl,
    String? bannerUrl,
    String? trailerUrl,
    String? genre,
    String? director,
    String? language,
    String? subtitle,
    int? durationMinutes,
    String? ageRating,
    String? releaseDate,
    String? status,
  }) {
    return MovieDetailModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      genre: genre ?? this.genre,
      director: director ?? this.director,
      language: language ?? this.language,
      subtitle: subtitle ?? this.subtitle,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      ageRating: ageRating ?? this.ageRating,
      releaseDate: releaseDate ?? this.releaseDate,
      status: status ?? this.status,
    );
  }
}

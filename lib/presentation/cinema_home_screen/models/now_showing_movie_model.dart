// ignore_for_file: must_be_immutable
class NowShowingMovieModel {
  NowShowingMovieModel({
    this.imagePath,
    this.bannerPath,
    this.title,
    this.description,
    this.language,
    this.ageRating,
    this.subtitle,
    this.format,
    this.id,
  }) {
    imagePath = imagePath ?? '';
    bannerPath = bannerPath ?? '';
    title = title ?? '';
    description = description ?? '';
    language = language ?? '';
    ageRating = ageRating ?? '';
    subtitle = subtitle ?? '';
    format = format ?? 'IMAX';
    id = id ?? '';
  }

  String? imagePath;
  String? bannerPath;
  String? title;
  String? description;
  String? language;
  String? ageRating;
  String? subtitle;
  String? format;
  String? id;

  NowShowingMovieModel copyWith({
    String? imagePath,
    String? bannerPath,
    String? title,
    String? description,
    String? language,
    String? ageRating,
    String? subtitle,
    String? format,
    String? id,
  }) {
    return NowShowingMovieModel(
      imagePath: imagePath ?? this.imagePath,
      bannerPath: bannerPath ?? this.bannerPath,
      title: title ?? this.title,
      description: description ?? this.description,
      language: language ?? this.language,
      ageRating: ageRating ?? this.ageRating,
      subtitle: subtitle ?? this.subtitle,
      format: format ?? this.format,
      id: id ?? this.id,
    );
  }
}

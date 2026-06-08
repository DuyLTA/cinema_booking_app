// ignore_for_file: must_be_immutable
class ComingSoonMovieModel {
  ComingSoonMovieModel({
    this.imagePath,
    this.title,
    this.language,
    this.ageRating,
    this.subtitle,
    this.format,
    this.hasFormatBadge,
    this.hasReminder,
    this.id,
  }) {
    imagePath = imagePath ?? '';
    title = title ?? '';
    language = language ?? '';
    ageRating = ageRating ?? '';
    subtitle = subtitle ?? '';
    format = format ?? '';
    hasFormatBadge = hasFormatBadge ?? false;
    hasReminder = hasReminder ?? false;
    id = id ?? '';
  }

  String? imagePath;
  String? title;
  String? language;
  String? ageRating;
  String? subtitle;
  String? format;
  bool? hasFormatBadge;
  bool? hasReminder;
  String? id;

  ComingSoonMovieModel copyWith({
    String? imagePath,
    String? title,
    String? language,
    String? ageRating,
    String? subtitle,
    String? format,
    bool? hasFormatBadge,
    bool? hasReminder,
    String? id,
  }) {
    return ComingSoonMovieModel(
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
      language: language ?? this.language,
      ageRating: ageRating ?? this.ageRating,
      subtitle: subtitle ?? this.subtitle,
      format: format ?? this.format,
      hasFormatBadge: hasFormatBadge ?? this.hasFormatBadge,
      hasReminder: hasReminder ?? this.hasReminder,
      id: id ?? this.id,
    );
  }
}

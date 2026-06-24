import 'package:cinema_booking_app/core/utils/image_constant.dart';
import 'package:cinema_booking_app/models/movie_model.dart';
import 'package:cinema_booking_app/presentation/cinema_home_screen/models/coming_soon_movie_model.dart';
import 'package:cinema_booking_app/presentation/cinema_home_screen/models/now_showing_movie_model.dart';
import 'package:cinema_booking_app/presentation/movie_list_screen/models/movie_list_model.dart';

class MovieUiMapper {
  static String posterPath(MovieModel movie) {
    final url = movie.posterUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return url;
    }
    return ImageConstant.imgImageNotFound;
  }

  static String languageLabel(MovieModel movie) {
    final parts = <String>[];
    if (movie.language != null && movie.language!.trim().isNotEmpty) {
      parts.add(movie.language!.trim());
    }
    if (movie.subtitle != null && movie.subtitle!.trim().isNotEmpty) {
      parts.add(movie.subtitle!.trim());
    }
    return parts.isEmpty ? '2D' : parts.join(' • ');
  }

  static String ageSubtitleLabel(MovieModel movie) {
    final parts = <String>[];
    final rating = movie.ageRating?.trim();
    final subtitle = movie.subtitle?.trim();
    if (rating != null && rating.isNotEmpty) {
      parts.add(rating);
    }
    if (subtitle != null && subtitle.isNotEmpty) {
      parts.add(subtitle);
    }
    return parts.join(' • ');
  }

  static String formatLabel(MovieModel movie) {
    if (movie.genre != null && movie.genre!.trim().isNotEmpty) {
      return movie.genre!.trim().toUpperCase();
    }
    return '2D';
  }

  static String durationGenreLabel(MovieModel movie) {
    final minutes = movie.durationMinutes ?? 0;
    final genre = (movie.genre ?? 'MOVIE').toUpperCase();
    return '$minutes MIN • $genre';
  }

  static String bannerPath(MovieModel movie) {
    final url = movie.bannerUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return url;
    }
    return posterPath(movie);
  }

  static NowShowingMovieModel toNowShowing(MovieModel movie) {
    return NowShowingMovieModel(
      id: movie.id,
      imagePath: posterPath(movie),
      bannerPath: bannerPath(movie),
      title: movie.title,
      description: movie.description,
      language: languageLabel(movie),
      ageRating: movie.ageRating ?? '',
      subtitle: movie.subtitle ?? '',
      format: formatLabel(movie),
    );
  }

  static ComingSoonMovieModel toComingSoon(MovieModel movie) {
    final format = formatLabel(movie);
    return ComingSoonMovieModel(
      id: movie.id,
      imagePath: posterPath(movie),
      title: movie.title,
      language: languageLabel(movie),
      ageRating: movie.ageRating ?? '',
      subtitle: movie.subtitle ?? '',
      format: format,
      hasFormatBadge: format.isNotEmpty,
      hasReminder: false,
    );
  }

  static MovieItemModel toMovieListItem(MovieModel movie) {
    return MovieItemModel(
      id: movie.id,
      title: movie.title,
      durationGenre: durationGenreLabel(movie),
      genre: movie.genre,
      rating: movie.ageRating ?? 'P',
      posterImage: posterPath(movie),
    );
  }
}

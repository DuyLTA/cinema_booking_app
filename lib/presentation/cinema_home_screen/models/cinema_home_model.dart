import './cinema_model.dart';
import './coming_soon_movie_model.dart';
import './now_showing_movie_model.dart';
import './offer_model.dart';

// ignore_for_file: must_be_immutable
class CinemaHomeModel {
  CinemaHomeModel({
    this.nowShowingMovies,
    this.comingSoonMovies,
    this.nearbyCinemas,
    this.exclusiveOffers,
  }) {
    nowShowingMovies = nowShowingMovies ?? [];
    comingSoonMovies = comingSoonMovies ?? [];
    nearbyCinemas = nearbyCinemas ?? [];
    exclusiveOffers = exclusiveOffers ?? [];
  }

  List<NowShowingMovieModel>? nowShowingMovies;
  List<ComingSoonMovieModel>? comingSoonMovies;
  List<CinemaModel>? nearbyCinemas;
  List<OfferModel>? exclusiveOffers;

  CinemaHomeModel copyWith({
    List<NowShowingMovieModel>? nowShowingMovies,
    List<ComingSoonMovieModel>? comingSoonMovies,
    List<CinemaModel>? nearbyCinemas,
    List<OfferModel>? exclusiveOffers,
  }) {
    return CinemaHomeModel(
      nowShowingMovies: nowShowingMovies ?? this.nowShowingMovies,
      comingSoonMovies: comingSoonMovies ?? this.comingSoonMovies,
      nearbyCinemas: nearbyCinemas ?? this.nearbyCinemas,
      exclusiveOffers: exclusiveOffers ?? this.exclusiveOffers,
    );
  }
}

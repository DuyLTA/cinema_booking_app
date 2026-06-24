import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/movie_provider.dart';
import '../../../services/movie_rating_service.dart';
import '../models/movie_detail_model.dart';

class MovieDetailProvider extends ChangeNotifier {
  final MovieRatingService _movieRatingService = MovieRatingService();

  MovieDetailModel movieDetail = MovieDetailModel();
  bool isLoading = false;
  bool isSubmittingRating = false;
  String? errorMessage;
  String? ratingErrorMessage;

  Future<void> loadMovieDetail(String movieId, BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      final movie = await movieProvider.getMovieById(movieId: movieId);

      if (movie != null) {
        final ratingStats = await _movieRatingService.getRatingStatsForMovie(
          movie.id,
        );
        final userRating = await _movieRatingService.getCurrentUserRating(
          movie.id,
        );

        movieDetail = MovieDetailModel(
          id: movie.id,
          title: movie.title,
          description: movie.description,
          posterUrl: movie.posterUrl,
          bannerUrl: movie.bannerUrl,
          trailerUrl: movie.trailerUrl,
          genre: movie.genre,
          director: movie.director,
          language: movie.language,
          subtitle: movie.subtitle,
          durationMinutes: movie.durationMinutes,
          ageRating: movie.ageRating,
          releaseDate: movie.releaseDate != null
              ? '${movie.releaseDate!.day}/${movie.releaseDate!.month}/${movie.releaseDate!.year}'
              : '',
          castMembers: movie.castMembers,
          crewMembers: movie.crewMembers,
          status: movie.status,
          averageRating: ratingStats.averageRating,
          ratingCount: ratingStats.ratingCount,
          userRating: userRating,
        );
      } else {
        errorMessage = 'Movie not found (ID: $movieId)';
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitRating(int rating) async {
    final movieId = movieDetail.id ?? '';
    isSubmittingRating = true;
    ratingErrorMessage = null;
    notifyListeners();

    try {
      await _movieRatingService.submitRating(movieId: movieId, rating: rating);
      final ratingStats = await _movieRatingService.getRatingStatsForMovie(
        movieId,
      );
      movieDetail = movieDetail.copyWith(
        averageRating: ratingStats.averageRating,
        ratingCount: ratingStats.ratingCount,
        userRating: rating,
      );
    } catch (e) {
      ratingErrorMessage = e.toString();
    } finally {
      isSubmittingRating = false;
      notifyListeners();
    }
  }
}

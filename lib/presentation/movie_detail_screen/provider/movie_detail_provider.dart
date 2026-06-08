import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_export.dart';
import '../../../models/movie_model.dart';
import '../../../providers/movie_provider.dart';
import '../models/movie_detail_model.dart';

class MovieDetailProvider extends ChangeNotifier {
  MovieDetailModel movieDetail = MovieDetailModel();
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadMovieDetail(String movieId, BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    print('DEBUG: Loading movie detail with ID: $movieId');

    try {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      final movie = await movieProvider.getMovieById(movieId: movieId);
      
      print('DEBUG: Movie found: ${movie != null}');
      if (movie != null) {
        print('DEBUG: Movie title: ${movie.title}');
      }
      
      if (movie != null) {
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
          status: movie.status,
        );
      } else {
        errorMessage = 'Movie not found (ID: $movieId)';
      }
    } catch (e) {
      print('DEBUG: Error loading movie: $e');
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

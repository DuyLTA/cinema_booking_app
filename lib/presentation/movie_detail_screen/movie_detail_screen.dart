import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import 'models/movie_detail_model.dart';
import 'provider/movie_detail_provider.dart';
import 'widgets/movie_detail_widgets.dart';

class MovieDetailScreen extends StatefulWidget {
  final String movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  static Widget builder(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final movieId = args?['movieId'] as String? ?? '';

    return ChangeNotifierProvider(
      create: (context) =>
          MovieDetailProvider()..loadMovieDetail(movieId, context),
      child: MovieDetailScreen(movieId: movieId),
    );
  }

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: Consumer<MovieDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(appTheme.orange_100),
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.errorMessage!,
                      style: TextStyleHelper.instance.title16RegularDMSans,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () =>
                          provider.loadMovieDetail(widget.movieId, context),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MovieDetailHeroSection(
                      movie: provider.movieDetail,
                      onBackTap: () => Navigator.of(context).pop(),
                    ),
                    MovieHeaderSection(movie: provider.movieDetail),
                    MovieRatingSection(
                      averageRating: provider.movieDetail.averageRating,
                      ratingCount: provider.movieDetail.ratingCount,
                      userRating: provider.movieDetail.userRating,
                      isSubmitting: provider.isSubmittingRating,
                      onRatingSelected: (rating) async {
                        await provider.submitRating(rating);
                        if (!context.mounted) return;

                        final error = provider.ratingErrorMessage;
                        AppSnackBar.show(
                          context,
                          message: error ?? 'Thanks for rating this movie.',
                          type: error == null
                              ? AppSnackBarType.success
                              : AppSnackBarType.error,
                        );
                      },
                    ),
                    MovieStorySection(movie: provider.movieDetail),
                    MovieCastSection(movie: provider.movieDetail),
                    MovieReleaseInfoSection(movie: provider.movieDetail),
                    SizedBox(
                      height: _canBookMovie(provider.movieDetail)
                          ? 100.h
                          : 24.h,
                    ),
                  ],
                ),
              ),
              if (_canBookMovie(provider.movieDetail))
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BottomBookingButton(
                    onTap: () =>
                        _openSessionSelection(context, provider.movieDetail),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  bool _canBookMovie(MovieDetailModel movie) {
    return movie.status?.trim().toLowerCase() == 'now_showing';
  }

  void _openSessionSelection(BuildContext context, MovieDetailModel movie) {
    Navigator.of(context).pushNamed(
      AppRoutes.sessionSelectionScreen,
      arguments: {
        'movieId': movie.id ?? widget.movieId,
        'movieTitle': movie.title ?? '',
        'posterUrl': (movie.posterUrl?.trim().isNotEmpty ?? false)
            ? movie.posterUrl
            : ImageConstant.imgImageNotFound,
        'genre': movie.genre ?? '',
        'ageRating': movie.ageRating ?? '',
      },
    );
  }
}

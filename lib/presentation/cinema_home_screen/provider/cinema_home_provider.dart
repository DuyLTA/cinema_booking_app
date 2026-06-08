import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../providers/movie_provider.dart';
import '../../../core/utils/movie_ui_mapper.dart';
import '../../../models/cinema_entity_model.dart';
import '../../../services/cinema_service.dart';
import '../models/cinema_home_model.dart';
import '../models/cinema_model.dart';
import '../models/coming_soon_movie_model.dart';
import '../models/now_showing_movie_model.dart';
import '../models/offer_model.dart';

class CinemaHomeProvider extends ChangeNotifier {
  final CinemaService _cinemaService = CinemaService();

  CinemaHomeModel cinemaHomeModel = CinemaHomeModel();

  List<NowShowingMovieModel> nowShowingMovies = [];
  List<ComingSoonMovieModel> comingSoonMovies = [];
  List<CinemaModel> nearbyCinemas = [];
  List<OfferModel> exclusiveOffers = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadData(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);
      await movieProvider.loadMovieSections();

      nowShowingMovies = movieProvider.nowShowingMovies
          .map(MovieUiMapper.toNowShowing)
          .toList();
      comingSoonMovies = movieProvider.comingSoonMovies
          .map(MovieUiMapper.toComingSoon)
          .toList();

      final cinemas = await _cinemaService.getAllCinemas();
      nearbyCinemas = cinemas.map(_mapCinemaEntity).toList();

      _loadExclusiveOffers();
    } catch (e) {
      errorMessage = e.toString();
      nowShowingMovies = [];
      comingSoonMovies = [];
      nearbyCinemas = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  CinemaModel _mapCinemaEntity(CinemaEntityModel cinema) {
    final locationParts = <String>[];
    if (cinema.location != null && cinema.location!.trim().isNotEmpty) {
      locationParts.add(cinema.location!.trim());
    }
    if (cinema.address != null && cinema.address!.trim().isNotEmpty) {
      locationParts.add(cinema.address!.trim());
    }

    final formats = <CinemaFormatChip>[];
    if ((cinema.totalScreens ?? 0) > 0) {
      formats.add(
        CinemaFormatChip(
          label: '${cinema.totalScreens} SCREENS',
          textColor: appTheme.orange_100,
          backgroundColor: appTheme.color19FABD,
          borderColor: appTheme.color4CFFDF,
        ),
      );
    }

    return CinemaModel(
      id: cinema.id,
      name: cinema.name.toUpperCase(),
      distance: locationParts.isEmpty
          ? 'Available for booking'
          : locationParts.join(' • '),
      formats: formats,
    );
  }

  void _loadExclusiveOffers() {
    exclusiveOffers = [
      OfferModel(
        id: '1',
        title: 'HAPPY MONDAY',
        description:
            'Enjoy 50% Off on all tickets\nevery Monday for Premiere\nmembers.',
        promoCode: 'PROMO: MONDAY50',
        borderColor: appTheme.color33FFB3,
        showOverlayImage: true,
        isClaimed: false,
      ),
      OfferModel(
        id: '2',
        title: 'COMBO DELUXE',
        description:
            'Get a free Large Popcorn with\nany 2 Gold Class tickets\npurchased today.',
        promoCode: 'PROMO: POPDELUXE',
        borderColor: appTheme.color33FFDF,
        showOverlayImage: false,
        isClaimed: false,
      ),
    ];
  }

  void toggleReminder(int index) {
    if (index < comingSoonMovies.length) {
      comingSoonMovies[index].hasReminder =
          !(comingSoonMovies[index].hasReminder ?? false);
      notifyListeners();
    }
  }

  void claimOffer(int index) {
    if (index < exclusiveOffers.length) {
      exclusiveOffers[index].isClaimed = true;
      notifyListeners();
    }
  }

  void copyPromoCode(BuildContext context, String promoCode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Promo code "$promoCode" copied!'),
        backgroundColor: appTheme.gray_900_01,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

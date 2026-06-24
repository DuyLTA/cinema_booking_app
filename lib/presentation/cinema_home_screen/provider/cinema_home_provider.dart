import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../providers/movie_provider.dart';
import '../../../core/utils/movie_ui_mapper.dart';
import '../../../models/cinema_entity_model.dart';
import '../../../services/coupon_service.dart';
import '../../../services/cinema_service.dart';
import '../models/cinema_home_model.dart';
import '../models/cinema_model.dart';
import '../models/coming_soon_movie_model.dart';
import '../models/now_showing_movie_model.dart';
import '../models/offer_model.dart';

class CinemaHomeProvider extends ChangeNotifier {
  final CinemaService _cinemaService = CinemaService();
  final CouponService _couponService = CouponService();

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

      final offers = await _couponService.getOffers();
      exclusiveOffers = offers
          .where((offer) => !(offer.isClaimed ?? false))
          .toList();
    } catch (e) {
      errorMessage = e.toString();
      nowShowingMovies = [];
      comingSoonMovies = [];
      nearbyCinemas = [];
      exclusiveOffers = [];
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

  void toggleReminder(int index) {
    if (index < comingSoonMovies.length) {
      comingSoonMovies[index].hasReminder =
          !(comingSoonMovies[index].hasReminder ?? false);
      notifyListeners();
    }
  }

  Future<void> claimOffer(BuildContext context, int index) async {
    if (index >= exclusiveOffers.length) {
      return;
    }

    final offer = exclusiveOffers[index];
    await _couponService.claimCoupon(offer);
    if (!context.mounted) {
      return;
    }
    if (index < exclusiveOffers.length) {
      exclusiveOffers.removeAt(index);
      notifyListeners();
    }
    copyPromoCode(context, offer.promoCode ?? '');
  }

  void copyPromoCode(BuildContext context, String promoCode) {
    if (promoCode.trim().isEmpty) {
      AppSnackBar.show(
        context,
        message: 'No promo code available for this offer.',
        type: AppSnackBarType.error,
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: promoCode.trim()));
    AppSnackBar.show(
      context,
      message: 'Promo code "$promoCode" copied!',
      type: AppSnackBarType.success,
    );
  }
}

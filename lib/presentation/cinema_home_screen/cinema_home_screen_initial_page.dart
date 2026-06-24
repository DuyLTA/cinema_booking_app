import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_book_button.dart';
import '../../widgets/custom_cine_marquee_app_bar.dart';
import '../../widgets/custom_image_view.dart';
import 'provider/cinema_home_provider.dart';
import 'widgets/cine_home_drawer.dart';
import 'widgets/cinema_card_widget.dart';
import 'widgets/coming_soon_item_widget.dart';
import 'widgets/now_showing_item_widget.dart';
import 'widgets/offer_card_widget.dart';

class CinemaHomeScreenInitialPage extends StatefulWidget {
  const CinemaHomeScreenInitialPage({super.key});

  static Widget builder(BuildContext context) {
    return const CinemaHomeScreenInitialPage();
  }

  @override
  State<CinemaHomeScreenInitialPage> createState() =>
      _CinemaHomeScreenInitialPageState();
}

class _CinemaHomeScreenInitialPageState
    extends State<CinemaHomeScreenInitialPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CinemaHomeProvider>().loadData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      appBar: CustomCineMarqueeAppBar(
        titleText: 'CINE BOOKING',
        onLeadingTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.profileScreen),
        onTicketTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.movieListScreen),
      ),
      endDrawer: const CineHomeDrawer(),
      body: Consumer<CinemaHomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.nowShowingMovies.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(appTheme.orange_100),
              ),
            );
          }

          if (provider.errorMessage != null &&
              provider.nowShowingMovies.isEmpty &&
              provider.comingSoonMovies.isEmpty) {
            return _buildErrorState(provider);
          }

          return RefreshIndicator(
            color: appTheme.orange_100,
            onRefresh: () => provider.loadData(context),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroSection(provider),
                  _buildNowShowingHeader(context),
                  _buildNowShowingList(provider),
                  _buildSectionHeader('COMING SOON'),
                  _buildComingSoonList(provider),
                  _buildSectionHeader('NEARBY CINEMAS'),
                  _buildCinemaList(provider),
                  _buildSectionHeader('OFFERS & PROMOTIONS'),
                  _buildOffersList(provider),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(CinemaHomeProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Unable to load movies',
              style: TextStyleHelper.instance.title16RegularDMSans,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: () => provider.loadData(context),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(CinemaHomeProvider provider) {
    final featured = provider.nowShowingMovies.isNotEmpty
        ? provider.nowShowingMovies.first
        : null;

    if (featured == null) {
      return SizedBox(height: 16.h);
    }

    final heroImage = (featured.imagePath?.isNotEmpty ?? false)
        ? featured.imagePath!
        : featured.bannerPath ?? '';
    final description = featured.description?.trim() ?? '';

    return SizedBox(
      width: double.infinity,
      height: 400.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomImageView(imagePath: heroImage, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  appTheme.screenBackground.withValues(alpha: 0.35),
                  appTheme.screenBackground.withValues(alpha: 0.72),
                  appTheme.screenBackground,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 24.h,
            right: 24.h,
            bottom: 28.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FEATURED SCREENING',
                  style: TextStyleHelper.instance.label10RegularBebasNeue
                      .copyWith(color: appTheme.orange_100, letterSpacing: 2.5),
                ),
                SizedBox(height: 10.h),
                Text(
                  (featured.title ?? '').toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyleHelper.instance.headline30RegularBebasNeue
                      .copyWith(
                        fontFamily: 'Bodoni Moda',
                        fontWeight: FontWeight.w600,
                        fontSize: 26.fSize,
                        letterSpacing: 1.2,
                        height: 1.1,
                      ),
                ),
                if (description.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyleHelper.instance.title16RegularDMSans
                        .copyWith(color: appTheme.gray_300, height: 1.35),
                  ),
                ],
                SizedBox(height: 16.h),
                CustomBookButton(
                  buttonWidth: 200.h,
                  label: 'BOOK NOW',
                  variant: CustomBookButtonVariant.hero,
                  widthType: CustomBookButtonWidth.auto,
                  onTap: () {
                    if (featured.id != null && featured.id!.isNotEmpty) {
                      Navigator.of(context).pushNamed(
                        AppRoutes.movieDetailScreen,
                        arguments: {'movieId': featured.id},
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowShowingHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.h, 24.h, 20.h, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'NOW SHOWING',
            style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
              color: appTheme.gray_300,
              letterSpacing: 1,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.movieListScreen);
            },
            child: Text(
              'VIEW ALL →',
              style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
                color: appTheme.orange_100,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.h, 20.h, 20.h, 12.h),
      child: Text(
        title,
        style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
          color: appTheme.gray_300,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildNowShowingList(CinemaHomeProvider provider) {
    if (provider.nowShowingMovies.isEmpty) {
      return _buildEmptyMessage('No movies currently showing.');
    }

    return SizedBox(
      height: 268.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20.h),
        itemCount: provider.nowShowingMovies.length,
        itemBuilder: (context, index) {
          return NowShowingItemWidget(movie: provider.nowShowingMovies[index]);
        },
      ),
    );
  }

  Widget _buildComingSoonList(CinemaHomeProvider provider) {
    if (provider.comingSoonMovies.isEmpty) {
      return _buildEmptyMessage('No upcoming movies yet.');
    }

    return SizedBox(
      height: 268.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20.h),
        itemCount: provider.comingSoonMovies.length,
        itemBuilder: (context, index) {
          return ComingSoonItemWidget(
            movie: provider.comingSoonMovies[index],
            onTap: () {
              final movie = provider.comingSoonMovies[index];
              if (movie.id != null && movie.id!.isNotEmpty) {
                Navigator.of(context).pushNamed(
                  AppRoutes.movieDetailScreen,
                  arguments: {'movieId': movie.id},
                );
              }
            },
            onReminderTap: () => provider.toggleReminder(index),
          );
        },
      ),
    );
  }

  Widget _buildCinemaList(CinemaHomeProvider provider) {
    if (provider.nearbyCinemas.isEmpty) {
      return _buildEmptyMessage('No cinemas available.');
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h),
      child: Column(
        children: provider.nearbyCinemas
            .map(
              (cinema) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: CinemaCardWidget(cinema: cinema),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildOffersList(CinemaHomeProvider provider) {
    return SizedBox(
      height: 220.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20.h),
        itemCount: provider.exclusiveOffers.length,
        itemBuilder: (context, index) {
          final offer = provider.exclusiveOffers[index];
          return OfferCardWidget(
            offer: offer,
            onClaimTap: () => provider.claimOffer(context, index),
            onPromoTap: () =>
                provider.copyPromoCode(context, offer.promoCode ?? ''),
          );
        },
      ),
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 8.h),
      child: Text(
        message,
        style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
          color: appTheme.gray_500,
        ),
      ),
    );
  }
}

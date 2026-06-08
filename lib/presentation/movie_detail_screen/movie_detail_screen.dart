import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_book_button.dart';
import '../../widgets/custom_image_view.dart';
import 'models/movie_detail_model.dart';
import 'provider/movie_detail_provider.dart';

class MovieDetailScreen extends StatefulWidget {
  final String movieId;

  const MovieDetailScreen({Key? key, required this.movieId}) : super(key: key);

  static Widget builder(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final movieId = args?['movieId'] as String? ?? '';
    
    return ChangeNotifierProvider(
      create: (context) => MovieDetailProvider()..loadMovieDetail(movieId, context),
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
                      onPressed: () => provider.loadMovieDetail(widget.movieId, context),
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
                    _buildHeroSection(provider.movieDetail),
                    _buildMovieHeaderSection(provider.movieDetail),
                    _buildStorySection(provider.movieDetail),
                    _buildCastSection(),
                    _buildReleaseInfoSection(provider.movieDetail),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomBookingButton(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(MovieDetailModel movie) {
    final heroImage = (movie.bannerUrl?.isNotEmpty ?? false)
        ? movie.bannerUrl!
        : movie.posterUrl ?? '';

    return SizedBox(
      width: double.infinity,
      height: 280.h,
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
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 40.h,
            left: 20.h,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.all(8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24.h,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40.h,
            right: 20.h,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 24.h,
                ),
              ),
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () async {
                final trailerUrl = movie.trailerUrl;
                if (trailerUrl != null && trailerUrl.isNotEmpty) {
                  final uri = Uri.parse(trailerUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.platformDefault);
                  }
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30.h),
                  border: Border.all(color: Colors.white, width: 1.h),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 24.h,
                    ),
                    SizedBox(width: 8.h),
                    Text(
                      'WATCH TRAILER',
                      style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieHeaderSection(MovieDetailModel movie) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100.h,
                height: 140.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.h),
                  border: Border.all(color: appTheme.color19A48B, width: 1.h),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.h),
                  child: CustomImageView(
                    imagePath: movie.posterUrl ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title ?? '',
                      style: TextStyleHelper.instance.headline30RegularBebasNeue.copyWith(
                        fontFamily: 'Bodoni Moda',
                        fontWeight: FontWeight.w600,
                        fontSize: 24.fSize,
                        letterSpacing: 1.2,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildGenreTags(movie),
                    SizedBox(height: 8.h),
                    if (movie.durationMinutes != null && movie.durationMinutes! > 0)
                      Text(
                        '${movie.durationMinutes} MIN',
                        style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                          color: appTheme.gray_500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenreTags(MovieDetailModel movie) {
    final genres = movie.genre?.split(',') ?? ['MOVIE'];
    
    return Wrap(
      spacing: 8.h,
      runSpacing: 8.h,
      children: genres.take(2).map((genre) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
          decoration: BoxDecoration(
            color: appTheme.gray_900_02,
            borderRadius: BorderRadius.circular(6.h),
            border: Border.all(color: appTheme.color19A48B, width: 1.h),
          ),
          child: Text(
            genre.trim().toUpperCase(),
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              color: appTheme.gray_400,
              letterSpacing: 1,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStorySection(MovieDetailModel movie) {
    if (movie.description == null || movie.description!.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'THE STORY',
                style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
                  color: appTheme.gray_300,
                  letterSpacing: 1,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'READ MORE',
                  style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
                    color: appTheme.orange_100,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            movie.description!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
              color: appTheme.gray_400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CAST & CREW',
                style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
                  color: appTheme.gray_300,
                  letterSpacing: 1,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'VIEW ALL',
                  style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
                    color: appTheme.orange_100,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 16.h,
              children: [
                _buildCastMember('Alexander Director', 'Director'),
                _buildCastMember('Elena Gold', 'The Enigma'),
                _buildCastMember('Marcus Steel', 'Lead'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastMember(String name, String role) {
    return Column(
      children: [
        Container(
          width: 70.h,
          height: 70.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: appTheme.gray_900_02,
            border: Border.all(color: appTheme.color19A48B, width: 1.h),
          ),
          child: Icon(
            Icons.person,
            color: appTheme.gray_500,
            size: 40.h,
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 80.h,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
              color: appTheme.gray_300,
              fontSize: 12.fSize,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          role,
          style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
            color: appTheme.gray_500,
            fontSize: 10.fSize,
          ),
        ),
      ],
    );
  }

  Widget _buildReleaseInfoSection(MovieDetailModel movie) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
      child: Column(
        children: [
          _buildInfoBox(
            'RELEASE DATE',
            movie.releaseDate ?? 'TBD',
          ),
          SizedBox(height: 12.h),
          _buildInfoBox(
            'DIRECTOR',
            movie.director ?? 'Unknown',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_02,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.color19A48B, width: 1.h),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              color: appTheme.gray_500,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value.toUpperCase(),
            style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
              color: appTheme.gray_300,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBookingButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
      decoration: BoxDecoration(
        color: appTheme.screenBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: Offset(0, -4.h),
            blurRadius: 10.h,
          ),
        ],
      ),
      child: CustomBookButton(
        buttonWidth: double.infinity,
        label: 'SELECT SEAT & BOOK NOW',
        variant: CustomBookButtonVariant.standard,
        widthType: CustomBookButtonWidth.flexible,
        onTap: () {},
      ),
    );
  }
}

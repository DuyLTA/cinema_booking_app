import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';
import '../../../models/movie_model.dart';
import '../../../widgets/custom_book_button.dart';
import '../../../widgets/custom_image_view.dart';
import '../models/movie_detail_model.dart';

class MovieDetailHeroSection extends StatelessWidget {
  const MovieDetailHeroSection({
    super.key,
    required this.movie,
    required this.onBackTap,
  });

  final MovieDetailModel movie;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
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
            child: _HeroCircleButton(icon: Icons.arrow_back, onTap: onBackTap),
          ),
          Positioned(
            top: 40.h,
            right: 20.h,
            child: _HeroCircleButton(icon: Icons.share, onTap: () {}),
          ),
          Center(child: _TrailerButton(movie: movie)),
        ],
      ),
    );
  }
}

class _HeroCircleButton extends StatelessWidget {
  const _HeroCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24.h),
      ),
    );
  }
}

class _TrailerButton extends StatelessWidget {
  const _TrailerButton({required this.movie});

  final MovieDetailModel movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            Icon(Icons.play_circle_outline, color: Colors.white, size: 24.h),
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
    );
  }
}

class MovieHeaderSection extends StatelessWidget {
  const MovieHeaderSection({super.key, required this.movie});

  final MovieDetailModel movie;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.h),
      child: Row(
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
                  style: TextStyleHelper.instance.headline30RegularBebasNeue
                      .copyWith(
                        fontFamily: 'Bodoni Moda',
                        fontWeight: FontWeight.w600,
                        fontSize: 24.fSize,
                        letterSpacing: 1.2,
                        height: 1.1,
                      ),
                ),
                SizedBox(height: 12.h),
                MovieGenreTags(movie: movie),
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
    );
  }
}

class MovieGenreTags extends StatelessWidget {
  const MovieGenreTags({super.key, required this.movie});

  final MovieDetailModel movie;

  @override
  Widget build(BuildContext context) {
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
}

class MovieStorySection extends StatelessWidget {
  const MovieStorySection({super.key, required this.movie});

  final MovieDetailModel movie;

  @override
  Widget build(BuildContext context) {
    if (movie.description == null || movie.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MovieSectionHeader(title: 'THE STORY', actionLabel: 'READ MORE'),
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
}

class MovieRatingSection extends StatelessWidget {
  const MovieRatingSection({
    super.key,
    required this.averageRating,
    required this.ratingCount,
    required this.userRating,
    required this.isSubmitting,
    required this.onRatingSelected,
  });

  final double averageRating;
  final int ratingCount;
  final int? userRating;
  final bool isSubmitting;
  final ValueChanged<int> onRatingSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: appTheme.gray_900_02,
          borderRadius: BorderRadius.circular(12.h),
          border: Border.all(color: appTheme.color19A48B, width: 1.h),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AUDIENCE RATING',
                  style: TextStyleHelper.instance.title20SemiBoldBodoniModa
                      .copyWith(color: appTheme.gray_300, letterSpacing: 1),
                ),
                Text(
                  ratingCount == 0
                      ? 'NO RATINGS'
                      : '${averageRating.toStringAsFixed(1)}/5',
                  style: TextStyleHelper.instance.label10RegularBebasNeue
                      .copyWith(color: appTheme.orange_100, letterSpacing: 1),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                _RatingStars(value: averageRating, size: 18.h),
                SizedBox(width: 8.h),
                Text(
                  ratingCount == 1 ? '1 rating' : '$ratingCount ratings',
                  style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                    color: appTheme.gray_500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Text(
              userRating == null ? 'Tap to rate this movie' : 'Your rating',
              style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                color: appTheme.gray_400,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: List.generate(5, (index) {
                final star = index + 1;
                final selected = (userRating ?? 0) >= star;
                return GestureDetector(
                  onTap: isSubmitting ? null : () => onRatingSelected(star),
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.h),
                    child: Icon(
                      selected ? Icons.star : Icons.star_border,
                      color: appTheme.orange_100,
                      size: 32.h,
                    ),
                  ),
                );
              }),
            ),
            if (isSubmitting) ...[
              SizedBox(height: 10.h),
              SizedBox(
                width: 18.h,
                height: 18.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.h,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    appTheme.orange_100,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.value, required this.size});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final icon = value >= starValue - 0.25
            ? Icons.star
            : value >= starValue - 0.75
            ? Icons.star_half
            : Icons.star_border;
        return Icon(icon, color: appTheme.orange_100, size: size);
      }),
    );
  }
}

class MovieCastSection extends StatelessWidget {
  const MovieCastSection({super.key, required this.movie});

  final MovieDetailModel movie;

  @override
  Widget build(BuildContext context) {
    final credits = _movieCredits(movie);
    if (credits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MovieSectionHeader(title: 'CAST & CREW', actionLabel: 'VIEW ALL'),
          SizedBox(height: 16.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 16.h,
              children: credits
                  .map(
                    (credit) => _CastMember(
                      name: credit.name,
                      role: credit.role,
                      imageUrl: credit.imageUrl,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<MovieCredit> _movieCredits(MovieDetailModel movie) {
    final credits = <MovieCredit>[...?movie.crewMembers, ...?movie.castMembers];

    if (credits.isNotEmpty) {
      return credits;
    }

    final director = movie.director?.trim();
    if (director != null && director.isNotEmpty) {
      return [MovieCredit(name: director, role: 'Director')];
    }

    return const [];
  }
}

class _MovieSectionHeader extends StatelessWidget {
  const _MovieSectionHeader({required this.title, required this.actionLabel});

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
            color: appTheme.gray_300,
            letterSpacing: 1,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            actionLabel,
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              color: appTheme.orange_100,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _CastMember extends StatelessWidget {
  const _CastMember({
    required this.name,
    required this.role,
    required this.imageUrl,
  });

  final String name;
  final String role;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

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
          child: ClipOval(
            child: hasImage
                ? CustomImageView(
                    imagePath: imageUrl,
                    width: 70.h,
                    height: 70.h,
                    fit: BoxFit.cover,
                  )
                : Icon(Icons.person, color: appTheme.gray_500, size: 40.h),
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
        SizedBox(
          width: 80.h,
          child: Text(
            role,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              color: appTheme.gray_500,
              fontSize: 10.fSize,
            ),
          ),
        ),
      ],
    );
  }
}

class MovieReleaseInfoSection extends StatelessWidget {
  const MovieReleaseInfoSection({super.key, required this.movie});

  final MovieDetailModel movie;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.h),
      child: Column(
        children: [
          _InfoBox(label: 'RELEASE DATE', value: movie.releaseDate ?? 'TBD'),
          SizedBox(height: 12.h),
          _InfoBox(label: 'DIRECTOR', value: movie.director ?? 'Unknown'),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
}

class BottomBookingButton extends StatelessWidget {
  const BottomBookingButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_book_button.dart';
import '../../../widgets/custom_image_view.dart';
import '../models/movie_list_model.dart';

class MovieCardWidget extends StatelessWidget {
  final MovieItemModel movie;
  final VoidCallback? onTap;
  final VoidCallback? onBookTap;

  const MovieCardWidget({
    super.key,
    required this.movie,
    this.onTap,
    this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final posterHeight = (constraints.maxHeight * 0.58).clamp(100.h, 220.h);

        return GestureDetector(
          onTap:
              onTap ??
              () {
                if (movie.id != null && movie.id!.isNotEmpty) {
                  Navigator.of(context).pushNamed(
                    AppRoutes.movieDetailScreen,
                    arguments: {'movieId': movie.id},
                  );
                }
              },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: posterHeight, child: _buildPosterSection()),
              SizedBox(height: 8.h),
              Text(
                movie.title ?? '',
                style: TextStyleHelper.instance.title16RegularBodoniModa
                    .copyWith(color: appTheme.gray_300, height: 1.2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                movie.durationGenre ?? '',
                style: TextStyleHelper.instance.body12MediumDMSans,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              CustomBookButton(
                buttonWidth: double.infinity,
                label: 'BOOK NOW',
                variant: CustomBookButtonVariant.standard,
                widthType: CustomBookButtonWidth.flexible,
                onTap: onBookTap,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPosterSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: appTheme.bookRedBorder, width: 1.h),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.h),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomImageView(
              imagePath: movie.posterImage ?? ImageConstant.imgImageNotFound,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 6.h,
              right: 8.h,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 8.h),
                decoration: BoxDecoration(
                  color: appTheme.bookRedFill.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4.h),
                  border: Border.all(color: appTheme.bookRedBorder, width: 1.h),
                ),
                child: Text(
                  movie.rating ?? '',
                  style: TextStyleHelper.instance.body12MediumBebasNeue,
                ),
              ),
            ),
            Positioned(left: 8.h, bottom: 8.h, child: _buildRatingBadge()),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBadge() {
    final hasRating = movie.ratingCount > 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 4.h),
      decoration: BoxDecoration(
        color: appTheme.black_900.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14.h),
        border: Border.all(color: appTheme.orange_100, width: 1.h),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: appTheme.orange_100, size: 14.h),
          SizedBox(width: 4.h),
          Text(
            hasRating ? movie.averageRating.toStringAsFixed(1) : '--',
            style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
              color: appTheme.gray_300,
              fontSize: 11.fSize,
            ),
          ),
        ],
      ),
    );
  }
}

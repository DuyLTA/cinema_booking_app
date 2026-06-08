import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_view.dart';
import '../models/now_showing_movie_model.dart';

class NowShowingItemWidget extends StatelessWidget {
  final NowShowingMovieModel movie;
  final VoidCallback? onTap;

  NowShowingItemWidget({Key? key, required this.movie, this.onTap})
    : super(key: key);

  String _metaLabel() {
    final parts = <String>[];
    final rating = movie.ageRating?.trim();
    final subtitle = movie.subtitle?.trim();
    if (rating != null && rating.isNotEmpty) {
      parts.add(rating);
    }
    if (subtitle != null && subtitle.isNotEmpty) {
      parts.add(subtitle);
    }
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final meta = _metaLabel();

    return GestureDetector(
      onTap: onTap ?? () {
        print('DEBUG: Tapped on movie, ID: ${movie.id}');
        if (movie.id != null && movie.id!.isNotEmpty) {
          Navigator.of(context).pushNamed(
            AppRoutes.movieDetailScreen,
            arguments: {'movieId': movie.id},
          );
        } else {
          print('DEBUG: Movie ID is null or empty');
        }
      },
      child: Container(
        width: 144.h,
        margin: EdgeInsets.only(right: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 144.h,
              height: 200.h,
              decoration: BoxDecoration(
                border: Border.all(color: appTheme.color33A48B, width: 1.h),
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.h),
                    child: CustomImageView(
                      imagePath: movie.imagePath ?? '',
                      height: 200.h,
                      width: 144.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8.h,
                    left: 8.h,
                    right: 8.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.h,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: appTheme.black_900.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(4.h),
                      ),
                      child: Text(
                        movie.format ?? '2D',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyleHelper.instance.label10RegularDMSans
                            .copyWith(color: appTheme.orange_100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              movie.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
                color: appTheme.gray_300,
                height: 1.2,
              ),
            ),
            if (meta.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                meta,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                  color: appTheme.gray_500,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_view.dart';
import '../models/cinema_model.dart';

class CinemaCardWidget extends StatelessWidget {
  final CinemaModel cinema;
  final VoidCallback? onTap;

  CinemaCardWidget({Key? key, required this.cinema, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: appTheme.gray_900_04,
          borderRadius: BorderRadius.circular(12.h),
          border: Border.all(color: appTheme.color19FFB3, width: 1.h),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cinema.name ?? '',
                    style: TextStyleHelper.instance.title18RegularBebasNeue
                        .copyWith(height: 22 / 18),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    cinema.distance ?? '',
                    style: TextStyleHelper.instance.title16RegularDMSans
                        .copyWith(color: appTheme.gray_500, height: 21 / 16),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 6.h,
                    children: (cinema.formats ?? [])
                        .map((format) => _buildChip(format))
                        .toList(),
                  ),
                ],
              ),
            ),
            CustomImageView(
              imagePath: ImageConstant.imgArrowRightGray500,
              height: 12.h,
              width: 6.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(CinemaFormatChip chip) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 2.h),
      decoration: BoxDecoration(
        color: chip.backgroundColor,
        borderRadius: BorderRadius.circular(10.h),
        border: Border.all(
          color: chip.borderColor ?? const Color(0x4CFFDF9E),
          width: 1.h,
        ),
      ),
      child: Text(
        chip.label ?? '',
        style: TextStyleHelper.instance.label10RegularDMSans.copyWith(
          color: chip.textColor ?? const Color(0xFFFFDF9E),
        ),
      ),
    );
  }
}

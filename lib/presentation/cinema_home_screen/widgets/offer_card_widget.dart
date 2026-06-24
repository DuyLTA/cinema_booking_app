import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_view.dart';
import '../models/offer_model.dart';

class OfferCardWidget extends StatelessWidget {
  final OfferModel offer;
  final VoidCallback? onClaimTap;
  final VoidCallback? onPromoTap;

  const OfferCardWidget({
    super.key,
    required this.offer,
    this.onClaimTap,
    this.onPromoTap,
  });

  @override
  Widget build(BuildContext context) {
    final promoCode = offer.promoCode ?? '';
    final isClaimed = offer.isClaimed ?? false;

    return Container(
      width: 288.h,
      constraints: BoxConstraints(minHeight: 220.h),
      margin: EdgeInsets.only(right: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(
          color: offer.borderColor ?? const Color(0x33FFB3B2),
          width: 1.h,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A1F1D), Color(0xFF1C1412)],
        ),
        boxShadow: [
          BoxShadow(
            color: appTheme.color19FFDF,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (offer.showOverlayImage ?? false)
            Positioned(
              top: 0,
              right: 0,
              child: CustomImageView(
                imagePath: ImageConstant.imgOverlayBlur,
                height: 96.h,
                width: 96.h,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: EdgeInsets.all(20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyleHelper.instance.headline24RegularBebasNeue
                      .copyWith(height: 29 / 24),
                ),
                SizedBox(height: 8.h),
                Text(
                  offer.description ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: onPromoTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.h,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isClaimed
                                ? appTheme.bookRedFill
                                : appTheme.gray_900_01,
                            borderRadius: BorderRadius.circular(4.h),
                            border: Border.all(
                              color: isClaimed
                                  ? appTheme.bookRedBorder
                                  : appTheme.deep_orange_100,
                              width: 1.h,
                            ),
                          ),
                          child: Text(
                            promoCode,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyleHelper
                                .instance
                                .body14RegularBebasNeue
                                .copyWith(
                                  color: isClaimed
                                      ? appTheme.gray_300
                                      : appTheme.orange_100,
                                  letterSpacing: 1,
                                  height: 17 / 14,
                                ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.h),
                    GestureDetector(
                      onTap: onClaimTap,
                      child: Text(
                        isClaimed ? 'CLAIMED' : 'Claim Now',
                        style: TextStyleHelper.instance.body14RegularBebasNeue
                            .copyWith(
                              color: isClaimed
                                  ? appTheme.gray_500
                                  : appTheme.orange_100,
                              letterSpacing: 1,
                              height: 17 / 14,
                              decoration: isClaimed
                                  ? TextDecoration.none
                                  : TextDecoration.underline,
                              decorationColor: appTheme.orange_100,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_view.dart';
import '../models/offer_model.dart';

class OfferCardWidget extends StatelessWidget {
  final OfferModel offer;
  final VoidCallback? onClaimTap;
  final VoidCallback? onPromoTap;

  OfferCardWidget({
    Key? key,
    required this.offer,
    this.onClaimTap,
    this.onPromoTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288.h,
      height: 212.h,
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
            padding: EdgeInsets.all(24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title ?? '',
                  style: TextStyleHelper.instance.headline24RegularBebasNeue
                      .copyWith(height: 29 / 24),
                ),
                SizedBox(height: 8.h),
                Text(
                  offer.description ?? '',
                  style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
                    height: 24 / 16,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: onPromoTap,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.h,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: appTheme.gray_900_01,
                          borderRadius: BorderRadius.circular(4.h),
                          border: Border.all(
                            color: appTheme.deep_orange_100,
                            width: 1.h,
                          ),
                        ),
                        child: Text(
                          offer.promoCode ?? '',
                          style: TextStyleHelper.instance.body14RegularBebasNeue
                              .copyWith(
                                color: appTheme.orange_100,
                                letterSpacing: 1,
                                height: 17 / 14,
                              ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onClaimTap,
                      child: Text(
                        'Claim Now',
                        style: TextStyleHelper.instance.body14RegularBebasNeue
                            .copyWith(
                              color: appTheme.orange_100,
                              letterSpacing: 1,
                              height: 17 / 14,
                              decoration: TextDecoration.underline,
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

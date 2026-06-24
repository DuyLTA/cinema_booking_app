import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../presentation/cinema_home_screen/models/offer_model.dart';
import '../../services/coupon_service.dart';
import '../cinema_home_screen/widgets/offer_card_widget.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key});

  static Widget builder(BuildContext context) => const OfferScreen();

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  final CouponService _couponService = CouponService();
  late Future<List<OfferModel>> _offersFuture;

  @override
  void initState() {
    super.initState();
    _offersFuture = _couponService.getOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      appBar: AppBar(
        backgroundColor: appTheme.gray_900_01,
        foregroundColor: appTheme.gray_300,
        title: Text(
          'OFFERS & PROMOTIONS',
          style: TextStyleHelper.instance.headline24RegularBebasNeue.copyWith(
            color: appTheme.orange_100,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<OfferModel>>(
        future: _offersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(appTheme.orange_100),
              ),
            );
          }

          final offers = snapshot.data ?? const <OfferModel>[];
          final availableOffers = offers
              .where((offer) => !(offer.isClaimed ?? false))
              .toList();
          final claimedOffers = offers
              .where((offer) => offer.isClaimed ?? false)
              .toList();

          return RefreshIndicator(
            color: appTheme.orange_100,
            onRefresh: () async {
              setState(() {
                _offersFuture = _couponService.getOffers();
              });
              await _offersFuture;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: 'AVAILABLE OFFERS',
                      subtitle: 'Tap claim to move it into your claimed list.',
                    ),
                    if (availableOffers.isEmpty)
                      const _EmptyState(
                        message: 'No available offers right now.',
                      )
                    else
                      _OffersStrip(
                        offers: availableOffers,
                        onClaimTap: (offer) {
                          _couponService.claimCoupon(offer).then((_) {
                            if (!context.mounted) {
                              return;
                            }
                            setState(() {
                              _offersFuture = _couponService.getOffers();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Claimed ${offer.promoCode ?? ''}',
                                ),
                              ),
                            );
                          });
                        },
                        onPromoTap: (offer) {
                          final code = offer.promoCode ?? '';
                          if (code.isNotEmpty) {
                            Clipboard.setData(ClipboardData(text: code));
                          }
                        },
                      ),
                    SizedBox(height: 18.h),
                    _SectionHeader(
                      title: 'CLAIMED OFFERS',
                      subtitle: 'These are saved for quick reuse at checkout.',
                    ),
                    if (claimedOffers.isEmpty)
                      const _EmptyState(message: 'No claimed offers yet.')
                    else
                      _OffersStrip(
                        offers: claimedOffers,
                        onClaimTap: (_) {},
                        onPromoTap: (offer) {
                          final code = offer.promoCode ?? '';
                          if (code.isNotEmpty) {
                            Clipboard.setData(ClipboardData(text: code));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Copied $code')),
                              );
                            }
                          }
                        },
                        showClaimButton: false,
                      ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
              color: appTheme.gray_300,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
              color: appTheme.gray_500,
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}

class _OffersStrip extends StatelessWidget {
  const _OffersStrip({
    required this.offers,
    required this.onClaimTap,
    required this.onPromoTap,
    this.showClaimButton = true,
  });

  final List<OfferModel> offers;
  final ValueChanged<OfferModel> onClaimTap;
  final ValueChanged<OfferModel> onPromoTap;
  final bool showClaimButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h),
      child: Column(
        children: offers
            .map(
              (offer) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: OfferCardWidget(
                  offer: offer,
                  onClaimTap: showClaimButton ? () => onClaimTap(offer) : null,
                  onPromoTap: () => onPromoTap(offer),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
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

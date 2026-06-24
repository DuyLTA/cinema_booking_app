import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../presentation/cinema_home_screen/models/offer_model.dart';
import '../theme/theme_helper.dart';
import 'coupon_claim_store.dart';

class CouponService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<OfferModel>> getOffers() async {
    try {
      final rows = await _supabase
          .from('coupons')
          .select(
            'id,code,name,description,discount_type,discount_value,min_order_amount,max_discount_amount,start_date,end_date,is_active',
          )
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));

      final claimedIds = await getClaimedCouponIds();
      return (rows as List)
          .map(
            (row) =>
                _mapCoupon(Map<String, dynamic>.from(row as Map), claimedIds),
          )
          .toList();
    } catch (_) {
      final claimedIds = await getClaimedCouponIds();
      return _fallbackOffers(claimedIds);
    }
  }

  Future<List<OfferModel>> getClaimedOffers() async {
    final offers = await getOffers();
    return offers.where((offer) => offer.isClaimed ?? false).toList();
  }

  Future<List<String>> getClaimedCouponIds() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      return CouponClaimStore.claimedOfferIds;
    }

    try {
      final rows = await _supabase
          .from('coupon_claims')
          .select('coupon_id')
          .eq('user_id', userId)
          .order('claimed_at', ascending: false)
          .timeout(const Duration(seconds: 10));

      return (rows as List)
          .map((row) => (row as Map)['coupon_id'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    } catch (_) {
      return CouponClaimStore.claimedOfferIds;
    }
  }

  Future<void> claimCoupon(OfferModel offer) async {
    final offerId = offer.id?.trim() ?? '';
    if (offerId.isEmpty) return;

    CouponClaimStore.markClaimed(offerId);

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) return;

    try {
      await _supabase.from('coupon_claims').upsert({
        'user_id': userId,
        'coupon_id': offerId,
        'coupon_code': offer.promoCode ?? '',
        'coupon_name': offer.title ?? '',
        'claimed_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Local fallback is already recorded for this session.
    }
  }

  OfferModel _mapCoupon(Map<String, dynamic> json, List<String> claimedIds) {
    final discountType = (json['discount_type'] as String? ?? '').toLowerCase();
    final discountValue = (json['discount_value'] as num?)?.toDouble() ?? 0;
    final minOrderAmount = (json['min_order_amount'] as num?)?.toDouble() ?? 0;
    final maxDiscountAmount =
        (json['max_discount_amount'] as num?)?.toDouble() ?? 0;
    final startDate = DateTime.tryParse(json['start_date'] as String? ?? '');
    final endDate = DateTime.tryParse(json['end_date'] as String? ?? '');
    final titleBase = (json['name'] as String? ?? 'COUPON').toUpperCase();
    final discountLabel = discountType == 'percent'
        ? '${discountValue.toStringAsFixed(0)}% OFF'
        : _formatVnd(discountValue);

    final details = <String>[
      (json['description'] as String? ?? '').trim(),
      'Use for ticket, food, and combo checkout.',
      if (minOrderAmount > 0) 'Min order ${_formatVnd(minOrderAmount)}',
      if (discountType == 'percent' && maxDiscountAmount > 0)
        'Max discount ${_formatVnd(maxDiscountAmount)}',
      if (startDate != null && endDate != null)
        'Valid ${_dateLabel(startDate)} - ${_dateLabel(endDate)}',
    ]..removeWhere((line) => line.trim().isEmpty);

    final offerId = json['id'] as String? ?? '';
    return OfferModel(
      id: offerId,
      title: '$discountLabel • $titleBase',
      description: details.take(3).join('\n'),
      promoCode: json['code'] as String? ?? '',
      borderColor: _borderColorForType(discountType),
      showOverlayImage: false,
      isClaimed: claimedIds.contains(offerId),
      discountType: discountType,
      discountValue: discountValue,
      minOrderAmount: minOrderAmount,
      maxDiscountAmount: maxDiscountAmount,
      startDate: startDate,
      endDate: endDate,
    );
  }

  List<OfferModel> _fallbackOffers(List<String> claimedIds) {
    return [
      OfferModel(
        id: 'welcome10',
        title: '10% OFF • WELCOME',
        description:
            'New users get 10% off their first booking.\nApplies to tickets and snacks.',
        promoCode: 'WELCOME10',
        borderColor: appTheme.color33FFB3,
        showOverlayImage: true,
        isClaimed: claimedIds.contains('welcome10'),
        discountType: 'percent',
        discountValue: 10,
        minOrderAmount: 0,
        maxDiscountAmount: 50000,
      ),
      OfferModel(
        id: 'weekend20',
        title: '20% OFF • WEEKEND',
        description:
            'Save on weekend sessions.\nGreat for group bookings and combos.',
        promoCode: 'WEEKEND20',
        borderColor: appTheme.color33FFDF,
        showOverlayImage: false,
        isClaimed: claimedIds.contains('weekend20'),
        discountType: 'percent',
        discountValue: 20,
        minOrderAmount: 100000,
        maxDiscountAmount: 60000,
      ),
      OfferModel(
        id: 'snack50',
        title: '50K OFF • SNACKS',
        description:
            'Get VND 50,000 off on food orders above the minimum amount.',
        promoCode: 'SNACK50',
        borderColor: appTheme.color33FFB3,
        showOverlayImage: false,
        isClaimed: claimedIds.contains('snack50'),
        discountType: 'fixed',
        discountValue: 50000,
        minOrderAmount: 120000,
      ),
    ];
  }

  Color _borderColorForType(String discountType) {
    return switch (discountType) {
      'percent' => appTheme.color33FFB3,
      'fixed' => appTheme.color33FFDF,
      _ => appTheme.color33FFB3,
    };
  }

  double calculateDiscountForOffer(OfferModel offer, double subtotal) {
    final discountType = (offer.discountType ?? '').toLowerCase();
    final discountValue = offer.discountValue ?? 0;
    final minOrderAmount = offer.minOrderAmount ?? 0;
    final maxDiscountAmount = offer.maxDiscountAmount ?? 0;

    if (subtotal < minOrderAmount) return 0;

    if (discountType == 'percent') {
      final rawDiscount = subtotal * (discountValue / 100);
      return maxDiscountAmount > 0
          ? rawDiscount.clamp(0, maxDiscountAmount).toDouble()
          : rawDiscount;
    }

    return discountValue.clamp(0, subtotal).toDouble();
  }

  String _formatVnd(double amount) {
    return '${amount.round()} VND';
  }

  String _dateLabel(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}

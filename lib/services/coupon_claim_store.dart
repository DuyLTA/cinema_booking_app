class CouponClaimStore {
  const CouponClaimStore._();

  static final Set<String> _claimedOfferIds = <String>{};

  static bool isClaimed(String offerId) => _claimedOfferIds.contains(offerId);

  static void markClaimed(String offerId) {
    if (offerId.trim().isEmpty) return;
    _claimedOfferIds.add(offerId);
  }

  static List<String> get claimedOfferIds => _claimedOfferIds.toList();
}

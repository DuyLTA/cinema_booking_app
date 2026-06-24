import 'package:flutter/material.dart';

// ignore_for_file: must_be_immutable
class OfferModel {
  OfferModel({
    this.title,
    this.description,
    this.promoCode,
    this.borderColor,
    this.showOverlayImage,
    this.isClaimed,
    this.id,
    this.discountType,
    this.discountValue,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.startDate,
    this.endDate,
  }) {
    title = title ?? '';
    description = description ?? '';
    promoCode = promoCode ?? '';
    borderColor = borderColor ?? Color(0x33FFB3B2);
    showOverlayImage = showOverlayImage ?? false;
    isClaimed = isClaimed ?? false;
    id = id ?? '';
    discountType = discountType ?? '';
    discountValue = discountValue ?? 0;
    minOrderAmount = minOrderAmount ?? 0;
    maxDiscountAmount = maxDiscountAmount ?? 0;
  }

  String? title;
  String? description;
  String? promoCode;
  Color? borderColor;
  bool? showOverlayImage;
  bool? isClaimed;
  String? id;
  String? discountType;
  double? discountValue;
  double? minOrderAmount;
  double? maxDiscountAmount;
  DateTime? startDate;
  DateTime? endDate;

  OfferModel copyWith({
    String? title,
    String? description,
    String? promoCode,
    Color? borderColor,
    bool? showOverlayImage,
    bool? isClaimed,
    String? id,
    String? discountType,
    double? discountValue,
    double? minOrderAmount,
    double? maxDiscountAmount,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return OfferModel(
      title: title ?? this.title,
      description: description ?? this.description,
      promoCode: promoCode ?? this.promoCode,
      borderColor: borderColor ?? this.borderColor,
      showOverlayImage: showOverlayImage ?? this.showOverlayImage,
      isClaimed: isClaimed ?? this.isClaimed,
      id: id ?? this.id,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

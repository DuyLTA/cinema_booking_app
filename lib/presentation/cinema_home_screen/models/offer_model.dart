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
  }) {
    title = title ?? '';
    description = description ?? '';
    promoCode = promoCode ?? '';
    borderColor = borderColor ?? Color(0x33FFB3B2);
    showOverlayImage = showOverlayImage ?? false;
    isClaimed = isClaimed ?? false;
    id = id ?? '';
  }

  String? title;
  String? description;
  String? promoCode;
  Color? borderColor;
  bool? showOverlayImage;
  bool? isClaimed;
  String? id;

  OfferModel copyWith({
    String? title,
    String? description,
    String? promoCode,
    Color? borderColor,
    bool? showOverlayImage,
    bool? isClaimed,
    String? id,
  }) {
    return OfferModel(
      title: title ?? this.title,
      description: description ?? this.description,
      promoCode: promoCode ?? this.promoCode,
      borderColor: borderColor ?? this.borderColor,
      showOverlayImage: showOverlayImage ?? this.showOverlayImage,
      isClaimed: isClaimed ?? this.isClaimed,
      id: id ?? this.id,
    );
  }
}

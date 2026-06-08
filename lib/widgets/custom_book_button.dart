import 'package:flutter/material.dart';

import '../core/app_export.dart';

enum CustomBookButtonVariant { standard, hero, promo }

enum CustomBookButtonWidth { flexible, auto }

class CustomBookButton extends StatelessWidget {
  const CustomBookButton({
    Key? key,
    required this.buttonWidth,
    this.label,
    this.variant,
    this.widthType,
    this.onTap,
    this.margin,
  }) : super(key: key);

  final double buttonWidth;
  final String? label;
  final CustomBookButtonVariant? variant;
  final CustomBookButtonWidth? widthType;
  final VoidCallback? onTap;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final resolvedVariant = variant ?? CustomBookButtonVariant.standard;
    final resolvedWidthType = widthType ?? CustomBookButtonWidth.flexible;
    final resolvedLabel = label ?? 'BOOK NOW';

    return Container(
      width: resolvedWidthType == CustomBookButtonWidth.flexible
          ? buttonWidth
          : null,
      margin: margin,
      child: _buildButton(resolvedVariant, resolvedLabel),
    );
  }

  Widget _buildButton(
    CustomBookButtonVariant resolvedVariant,
    String resolvedLabel,
  ) {
    switch (resolvedVariant) {
      case CustomBookButtonVariant.hero:
        return _buildHeroButton(resolvedLabel);
      case CustomBookButtonVariant.promo:
        return _buildPromoButton(resolvedLabel);
      case CustomBookButtonVariant.standard:
        return _buildStandardButton(resolvedLabel);
    }
  }

  BoxDecoration _bookNowDecoration({required double radius}) {
    return BoxDecoration(
      color: appTheme.bookRedFill,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: appTheme.bookRedBorder, width: 1.h),
      boxShadow: [
        BoxShadow(
          color: appTheme.bookRedFill.withValues(alpha: 0.35),
          offset: Offset(0, 4.h),
          blurRadius: 10.h,
        ),
      ],
    );
  }

  TextStyle _bookNowTextStyle({double? fontSize, double letterSpacing = 1.5}) {
    return TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
      color: appTheme.orange_100,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      height: 1.2,
    );
  }

  Widget _buildStandardButton(String resolvedLabel) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.h),
        decoration: _bookNowDecoration(radius: 10.h),
        alignment: Alignment.center,
        child: Text(resolvedLabel, style: _bookNowTextStyle()),
      ),
    );
  }

  Widget _buildHeroButton(String resolvedLabel) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 36.h),
        decoration: _bookNowDecoration(radius: 12.h),
        child: Text(
          resolvedLabel,
          textAlign: TextAlign.center,
          style: _bookNowTextStyle(fontSize: 16.fSize, letterSpacing: 1.8),
        ),
      ),
    );
  }

  Widget _buildPromoButton(String resolvedLabel) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 12.h),
        decoration: _bookNowDecoration(radius: 4.h),
        child: Text(resolvedLabel, style: _bookNowTextStyle(letterSpacing: 1)),
      ),
    );
  }
}

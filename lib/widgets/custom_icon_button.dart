import 'package:flutter/material.dart';

import '../core/app_export.dart';
import 'custom_image_view.dart';

enum CustomIconButtonVariant { standard, styled }

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    Key? key,
    this.imagePath,
    this.size,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.onTap,
    this.variant,
  }) : super(key: key);

  final String? imagePath;
  final double? size;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final CustomIconButtonVariant? variant;

  @override
  Widget build(BuildContext context) {
    final resolvedVariant = variant ?? CustomIconButtonVariant.standard;
    final double buttonWidth = width ?? size ?? 48.h;
    final double buttonHeight = height ?? size ?? 48.h;

    final child = GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: resolvedVariant == CustomIconButtonVariant.styled
              ? appTheme.gray_900_04
              : backgroundColor,
          borderRadius: BorderRadius.circular(
            borderRadius ?? buttonWidth / 2,
          ),
          border: resolvedVariant == CustomIconButtonVariant.styled
              ? Border.all(color: appTheme.color33FFDF, width: 1.h)
              : borderColor != null
              ? Border.all(color: borderColor!, width: 1.h)
              : null,
        ),
        child: Center(
          child: CustomImageView(
            imagePath: imagePath,
            height: buttonHeight * 0.55,
            width: buttonWidth * 0.55,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );

    return child;
  }
}

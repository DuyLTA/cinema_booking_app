import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import 'custom_image_view.dart';

/// A customizable text input field widget supporting email, password,
/// and general text input types with optional left and right icons.
///
/// [labelText] - Optional label text displayed above the input field
/// [hintText] - Placeholder text shown inside the input field
/// [leftImagePath] - Path to the icon displayed on the left side of the input
/// [rightImagePath] - Path to the icon displayed on the right side (e.g., password toggle)
/// [isPasswordField] - Whether this field is a password input with toggle visibility
/// [inputType] - The keyboard input type for the field
/// [controller] - Optional TextEditingController for the input field
/// [focusNode] - Optional FocusNode for the input field
/// [validator] - Optional validation function
/// [onChanged] - Callback triggered when the input value changes
/// [onTap] - Callback triggered when the field is tapped
/// [fillColor] - Background color of the input field
/// [borderRadius] - Border radius for the input field
/// [textStyle] - Custom text style for input text
/// [hintStyle] - Custom text style for hint/placeholder text
/// [leftIconWidth] - Width of the left icon
/// [leftIconHeight] - Height of the left icon
/// [rightIconWidth] - Width of the right icon
/// [rightIconHeight] - Height of the right icon
/// [contentPadding] - Custom padding inside the input field
class CustomEditText extends StatefulWidget {
  const CustomEditText({
    Key? key,
    this.labelText,
    this.hintText,
    this.leftImagePath,
    this.rightImagePath,
    this.isPasswordField,
    this.inputType,
    this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onTap,
    this.fillColor,
    this.borderRadius,
    this.textStyle,
    this.hintStyle,
    this.leftIconWidth,
    this.leftIconHeight,
    this.rightIconWidth,
    this.rightIconHeight,
    this.contentPadding,
    this.width,
  }) : super(key: key);

  final String? labelText;
  final String? hintText;
  final String? leftImagePath;
  final String? rightImagePath;
  final bool? isPasswordField;
  final TextInputType? inputType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final Color? fillColor;
  final double? borderRadius;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final double? leftIconWidth;
  final double? leftIconHeight;
  final double? rightIconWidth;
  final double? rightIconHeight;
  final EdgeInsetsGeometry? contentPadding;
  final double? width;

  @override
  State<CustomEditText> createState() => _CustomEditTextState();
}

class _CustomEditTextState extends State<CustomEditText> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final bool isPassword = widget.isPasswordField ?? false;
    final double radius = widget.borderRadius ?? 8.h;
    final Color bgColor = widget.fillColor ?? appTheme.black_900;

    final TextStyle defaultTextStyle = TextStyleHelper
        .instance
        .title16RegularDMSans
        .copyWith(color: appTheme.gray_500, height: 21 / 16);

    final TextStyle defaultHintStyle = TextStyleHelper
        .instance
        .title16RegularDMSans
        .copyWith(color: appTheme.color66A48B, height: 21 / 16);

    return SizedBox(
      width: widget.width,
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: isPassword ? _obscureText : false,
        keyboardType: widget.inputType ?? TextInputType.text,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        validator: widget.validator,
        style: widget.textStyle ?? defaultTextStyle,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: widget.hintStyle ?? defaultHintStyle,
          labelText: widget.labelText,
          labelStyle: widget.hintStyle ?? defaultHintStyle,
          filled: true,
          fillColor: bgColor,
          contentPadding:
              widget.contentPadding ??
              EdgeInsets.only(
                top: 16.h,
                right: isPassword ? 34.h : 16.h,
                bottom: 16.h,
                left: isPassword ? 28.h : 32.h,
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(color: appTheme.redCustom, width: 1.h),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(color: appTheme.redCustom, width: 1.h),
          ),
          prefixIcon: widget.leftImagePath != null
              ? _buildPrefixIcon(widget.leftImagePath!)
              : null,
          suffixIcon: isPassword
              ? _buildPasswordToggle()
              : (widget.rightImagePath != null
                    ? _buildSuffixIcon(widget.rightImagePath!)
                    : null),
        ),
      ),
    );
  }

  Widget _buildPrefixIcon(String imagePath) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.h),
      child: CustomImageView(
        imagePath: imagePath,
        width: widget.leftIconWidth ?? 16.h,
        height: widget.leftIconHeight ?? 16.h,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildSuffixIcon(String imagePath) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.h),
      child: CustomImageView(
        imagePath: imagePath,
        width: widget.rightIconWidth ?? 18.h,
        height: widget.rightIconHeight ?? 16.h,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildPasswordToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.h),
        child: widget.rightImagePath != null
            ? CustomImageView(
                imagePath: widget.rightImagePath!,
                width: widget.rightIconWidth ?? 18.h,
                height: widget.rightIconHeight ?? 16.h,
                fit: BoxFit.contain,
              )
            : Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                size: 18.h,
                color: appTheme.gray_500,
              ),
      ),
    );
  }
}

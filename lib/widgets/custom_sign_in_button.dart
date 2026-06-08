import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// A customizable sign-in button with dark red background, top border accent,
/// Bebas Neue uppercase text, and box shadow styling.
///
/// Parameters:
/// - [text]: Button label text (default: "SIGN IN")
/// - [onPressed]: Callback when button is tapped
/// - [width]: Width of the button
/// - [isLoading]: Shows loading indicator when true
class CustomSignInButton extends StatelessWidget {
  const CustomSignInButton({
    Key? key,
    this.text,
    this.onPressed,
    required this.width,
    this.isLoading,
  }) : super(key: key);

  /// Label text displayed on the button
  final String? text;

  /// Callback triggered when the button is pressed
  final VoidCallback? onPressed;

  /// Width of the button (required for proper layout)
  final double width;

  /// Whether to show a loading indicator
  final bool? isLoading;

  @override
  Widget build(BuildContext context) {
    final bool loading = isLoading ?? false;
    final String label = text ?? "SIGN IN";

    return Container(
      width: width,
      margin: EdgeInsets.only(top: 24.h, left: 16.h, right: 16.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900,
        borderRadius: BorderRadius.circular(8.h),
        border: Border(
          top: BorderSide(color: appTheme.deep_orange_100_33, width: 1.h),
        ),
        boxShadow: [
          BoxShadow(
            color: appTheme.color0C665C,
            offset: Offset(0, 4.h),
            blurRadius: 15.h,
          ),
        ],
      ),
      child: Material(
        color: appTheme.transparentCustom,
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: BorderRadius.circular(8.h),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 30.h),
            child: Center(
              child: loading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.h,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFF0DFDB),
                        ),
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyleHelper.instance.title20RegularBebasNeue
                          .copyWith(letterSpacing: 2, height: 24 / 20),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

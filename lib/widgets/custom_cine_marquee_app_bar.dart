import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/// CustomCineMarqueeAppBar
///
/// A custom AppBar component for the Cine Booking application.
/// Displays a leading menu icon, centered/left-aligned title, and a trailing action icon.
/// Implements [PreferredSizeWidget] for use as a standard Flutter AppBar.
///
/// Arguments:
/// - [leadingImagePath]: Path to the leading icon image (SVG/PNG).
/// - [titleText]: The title text displayed in the center of the AppBar.
/// - [actionImagePath]: Path to the trailing action icon image (SVG/PNG).
/// - [onLeadingTap]: Callback triggered when the leading icon is tapped.
/// - [onActionTap]: Callback triggered when the trailing action icon is tapped.
/// - [verticalPadding]: Vertical padding for the AppBar content.
class CustomCineMarqueeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomCineMarqueeAppBar({
    Key? key,
    this.leadingImagePath,
    this.titleText,
    this.actionImagePath,
    this.onLeadingTap,
    this.onActionTap,
    this.verticalPadding,
  }) : super(key: key);

  /// Path to the leading icon (e.g., menu/burger icon SVG)
  final String? leadingImagePath;

  /// Title text displayed in the AppBar
  final String? titleText;

  /// Path to the trailing action icon SVG
  final String? actionImagePath;

  /// Callback when the leading icon is tapped
  final VoidCallback? onLeadingTap;

  /// Callback when the trailing action icon is tapped
  final VoidCallback? onActionTap;

  /// Vertical padding override for top and bottom of the AppBar content
  final double? verticalPadding;

  @override
  Size get preferredSize => Size.fromHeight(72.h);

  @override
  Widget build(BuildContext context) {
    final double vPadding = verticalPadding ?? 14.h;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: appTheme.colorE51912,
      elevation: 0,
      shadowColor: appTheme.transparentCustom,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: appTheme.colorE51912,
          boxShadow: [
            BoxShadow(
              color: appTheme.color4C5C06,
              offset: Offset(0, 4.h),
              blurRadius: 20.h,
            ),
          ],
          border: Border(
            bottom: BorderSide(color: appTheme.colorB24CFF, width: 1.h),
          ),
        ),
      ),
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: vPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_buildLeadingIcon(), _buildTitle(), _buildActionIcon()],
        ),
      ),
    );
  }

  /// Builds the leading menu/burger icon widget
  Widget _buildLeadingIcon() {
    return GestureDetector(
      onTap: onLeadingTap,
      child: CustomImageView(
        imagePath: leadingImagePath ?? ImageConstant.imgButton,
        height: 36.h,
        width: 32.h,
        fit: BoxFit.contain,
      ),
    );
  }

  /// Builds the centered title text widget
  Widget _buildTitle() {
    return Text(
      titleText ?? 'CINE BOOKING',
      style: TextStyleHelper.instance.headline30RegularBebasNeue.copyWith(
        letterSpacing: 2.h,
        height: 36.h / 30.fSize,
      ),
    );
  }

  /// Builds the trailing action icon widget
  Widget _buildActionIcon() {
    return GestureDetector(
      onTap: onActionTap,
      child: CustomImageView(
        imagePath: actionImagePath ?? ImageConstant.imgButtonDeepOrange100,
        height: 18.h,
        width: 18.h,
        fit: BoxFit.contain,
      ),
    );
  }
}

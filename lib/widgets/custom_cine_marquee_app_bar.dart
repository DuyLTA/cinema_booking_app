import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// CustomCineMarqueeAppBar
///
/// A custom AppBar component for the Cine Booking application.
/// Displays a notification icon, centered title, and search icon.
/// Implements [PreferredSizeWidget] for use as a standard Flutter AppBar.
///
/// Arguments:
/// - [titleText]: The title text displayed in the center of the AppBar.
/// - [onLeadingTap]: Callback triggered when the leading icon is tapped.
/// - [onActionTap]: Callback triggered when the trailing action icon is tapped.
class CustomCineMarqueeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomCineMarqueeAppBar({
    Key? key,
    this.titleText,
    this.onLeadingTap,
    this.onActionTap,
  }) : super(key: key);

  /// Title text displayed in the AppBar
  final String? titleText;

  /// Callback when the leading icon is tapped
  final VoidCallback? onLeadingTap;

  /// Callback when the trailing action icon is tapped
  final VoidCallback? onActionTap;

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: appTheme.gray_900_01,
      elevation: 0,
      shadowColor: appTheme.transparentCustom,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: appTheme.gray_900_01,
          border: Border(
            bottom: BorderSide(color: appTheme.bookRedBorder, width: 1.h),
          ),
        ),
      ),
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.h),
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
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 28.h,
        height: 36.h,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            Icon(Icons.notifications, color: appTheme.orange_100, size: 20.h),
            Positioned(
              top: 8.h,
              right: 4.h,
              child: Container(
                width: 6.h,
                height: 6.h,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF9F9F),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the centered title text widget
  Widget _buildTitle() {
    return Text(
      titleText ?? 'CINE BOOKING',
      textAlign: TextAlign.center,
      style: TextStyleHelper.instance.headline24RegularBebasNeue.copyWith(
        color: appTheme.orange_100,
        letterSpacing: 3,
      ),
    );
  }

  /// Builds the trailing action icon widget
  Widget _buildActionIcon() {
    return GestureDetector(
      onTap: onActionTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 28.h,
        height: 36.h,
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.search, color: appTheme.gray_300, size: 20.h),
        ),
      ),
    );
  }
}

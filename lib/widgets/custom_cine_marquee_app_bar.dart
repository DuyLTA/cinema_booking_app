import 'package:flutter/material.dart';

import '../core/app_export.dart';
import '../providers/auth_provider.dart';

/// CustomCineMarqueeAppBar
///
/// A custom AppBar component for the Cine Booking application.
/// Displays a profile avatar, centered brand, ticket shortcut, and menu icon.
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
    this.onTicketTap,
  }) : super(key: key);

  /// Title text displayed in the AppBar
  final String? titleText;

  /// Callback when the leading icon is tapped
  final VoidCallback? onLeadingTap;

  /// Callback when the trailing action icon is tapped
  final VoidCallback? onActionTap;

  /// Callback when the ticket shortcut is tapped
  final VoidCallback? onTicketTap;

  @override
  Size get preferredSize => Size.fromHeight(58.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: appTheme.gray_900_01,
      elevation: 0,
      shadowColor: appTheme.transparentCustom,
      actions: const [SizedBox.shrink()],
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
        padding: EdgeInsets.symmetric(horizontal: 18.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileAvatar(context),
            _buildTitle(),
            _buildHeaderActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final customer = authProvider.currentCustomer;
        final user = authProvider.currentUser;
        final name = (customer?.fullName.trim().isNotEmpty ?? false)
            ? customer!.fullName.trim()
            : (user?.email?.trim().isNotEmpty ?? false)
            ? user!.email!.trim()
            : 'Cine';
        final initial = name.characters.first.toUpperCase();

        return SizedBox(
          width: 74.h,
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onLeadingTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 34.h,
                height: 34.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appTheme.gray_900,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appTheme.bookRedBorder,
                    width: 1.5.h,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: appTheme.bookRedFill.withValues(alpha: 0.25),
                      blurRadius: 12.h,
                    ),
                  ],
                ),
                child: Text(
                  initial,
                  style: TextStyleHelper.instance.title20SemiBoldBodoniModa
                      .copyWith(color: appTheme.orange_100, fontSize: 18.fSize),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return SizedBox(
      width: 74.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildIconAction(
            icon: Icons.confirmation_number_outlined,
            onTap: onTicketTap,
          ),
          SizedBox(width: 8.h),
          _buildIconAction(
            icon: Icons.menu,
            onTap:
                onActionTap ??
                () {
                  final scaffold = Scaffold.maybeOf(context);
                  if (scaffold?.hasEndDrawer ?? false) {
                    scaffold?.openEndDrawer();
                  }
                },
          ),
        ],
      ),
    );
  }

  Widget _buildIconAction({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 30.h,
        height: 34.h,
        child: Center(
          child: Icon(icon, color: appTheme.gray_300, size: 22.h),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Expanded(
      child: Center(
        child: Text(
          titleText ?? 'CINE BOOKING',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyleHelper.instance.headline24RegularBebasNeue.copyWith(
            color: appTheme.orange_100,
            fontSize: 22.fSize,
            letterSpacing: 2.5,
          ),
        ),
      ),
    );
  }
}

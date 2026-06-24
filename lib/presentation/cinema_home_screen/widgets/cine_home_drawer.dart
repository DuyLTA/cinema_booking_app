import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../providers/auth_provider.dart';

class CineHomeDrawer extends StatelessWidget {
  const CineHomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.84,
      backgroundColor: appTheme.gray_900_01.withValues(alpha: 0.96),
      child: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final customer = authProvider.currentCustomer;
            final user = authProvider.currentUser;
            final name = (customer?.fullName.trim().isNotEmpty ?? false)
                ? customer!.fullName.trim()
                : user?.email ?? 'Cine Member';
            final email = customer?.email ?? user?.email ?? 'member@cine.app';
            final initial = name.characters.first.toUpperCase();

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(22.h, 18.h, 22.h, 28.h),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.menu,
                        color: appTheme.gray_300,
                        size: 28.h,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  _DrawerProfile(initial: initial, name: name, email: email),
                  SizedBox(height: 22.h),
                  const _MemberCard(),
                  SizedBox(height: 18.h),
                  const _BookingLinks(),
                  SizedBox(height: 20.h),
                  _DrawerNavigationTile(
                    icon: Icons.card_giftcard,
                    label: 'Offers',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(AppRoutes.offerScreen);
                    },
                  ),
                  SizedBox(height: 14.h),
                  const _DrawerActionGrid(),
                  SizedBox(height: 22.h),
                  _DrawerLogout(authProvider: authProvider),
                  SizedBox(height: 24.h),
                  Text(
                    'CINE BOOKING',
                    style: TextStyleHelper.instance.headline24RegularBebasNeue
                        .copyWith(
                          color: appTheme.gray_800.withValues(alpha: 0.7),
                          letterSpacing: 3,
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DrawerProfile extends StatelessWidget {
  const _DrawerProfile({
    required this.initial,
    required this.name,
    required this.email,
  });

  final String initial;
  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 82.h,
          height: 82.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: appTheme.gray_900,
            shape: BoxShape.circle,
            border: Border.all(color: appTheme.bookRedBorder, width: 2.h),
            boxShadow: [
              BoxShadow(
                color: appTheme.bookRedFill.withValues(alpha: 0.32),
                blurRadius: 24.h,
              ),
            ],
          ),
          child: Text(
            initial,
            style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
              color: appTheme.orange_100,
              fontSize: 32.fSize,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          name.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
            color: appTheme.gray_300,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
            color: appTheme.gray_500,
          ),
        ),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.h),
      decoration: BoxDecoration(
        color: appTheme.gray_300,
        borderRadius: BorderRadius.circular(6.h),
        border: Border.all(color: appTheme.orange_100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.h,
                height: 42.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appTheme.gray_900,
                  borderRadius: BorderRadius.circular(6.h),
                ),
                child: Text(
                  'CB',
                  style: TextStyleHelper.instance.body14RegularBebasNeue
                      .copyWith(color: appTheme.orange_100, letterSpacing: 1),
                ),
              ),
              SizedBox(width: 12.h),
              Expanded(
                child: Text(
                  'Cine Member',
                  style: TextStyleHelper.instance.title20SemiBoldBodoniModa
                      .copyWith(color: appTheme.black_900),
                ),
              ),
              Icon(Icons.arrow_forward, color: appTheme.black_900, size: 22.h),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            height: 1.h,
            color: appTheme.black_900.withValues(alpha: 0.28),
          ),
          SizedBox(height: 10.h),
          Text(
            'MEMBER ID  -  0000 0000 2026',
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              color: appTheme.black_900,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingLinks extends StatelessWidget {
  const _BookingLinks();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _WideAction(
          icon: Icons.movie_creation_outlined,
          label: 'Book by Movie',
          routeName: AppRoutes.movieListScreen,
        ),
        _WideAction(
          icon: Icons.location_on_outlined,
          label: 'Book by Cinema',
          routeName: AppRoutes.cinemaSelectionScreen,
        ),
      ],
    );
  }
}

class _DrawerNavigationTile extends StatelessWidget {
  const _DrawerNavigationTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: appTheme.color33A48B)),
        ),
        child: Row(
          children: [
            Icon(icon, color: appTheme.orange_100, size: 21.h),
            SizedBox(width: 12.h),
            Expanded(
              child: Text(
                label,
                style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
                  color: appTheme.gray_300,
                  fontSize: 16.fSize,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: appTheme.gray_500, size: 24.h),
          ],
        ),
      ),
    );
  }
}

class _WideAction extends StatelessWidget {
  const _WideAction({
    required this.icon,
    required this.label,
    required this.routeName,
  });

  final IconData icon;
  final String label;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(routeName);
      },
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: appTheme.color33A48B)),
        ),
        child: Row(
          children: [
            Icon(icon, color: appTheme.orange_100, size: 21.h),
            SizedBox(width: 12.h),
            Expanded(
              child: Text(
                label,
                style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
                  color: appTheme.gray_300,
                  fontSize: 16.fSize,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: appTheme.gray_500, size: 24.h),
          ],
        ),
      ),
    );
  }
}

class _DrawerActionGrid extends StatelessWidget {
  const _DrawerActionGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      _DrawerAction(Icons.home_outlined, 'Home'),
      _DrawerAction(Icons.person_outline, 'Profile'),
      _DrawerAction(Icons.info_outline, 'Cinemas'),
      _DrawerAction(Icons.star_border, 'Specials'),
      _DrawerAction(Icons.confirmation_number_outlined, 'Tickets'),
      _DrawerAction(Icons.local_movies_outlined, 'Movies'),
      _DrawerAction(Icons.redeem_outlined, 'Gifts'),
      _DrawerAction(Icons.workspace_premium_outlined, 'Rewards'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14.h,
        crossAxisSpacing: 10.h,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () {
            Navigator.of(context).pop();
            if (item.label == 'Profile') {
              Navigator.of(context).pushNamed(AppRoutes.profileScreen);
            } else if (item.label == 'Movies' || item.label == 'Tickets') {
              Navigator.of(context).pushNamed(AppRoutes.movieListScreen);
            } else if (item.label == 'Offers') {
              Navigator.of(context).pushNamed(AppRoutes.offerScreen);
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: appTheme.gray_300, size: 28.h),
              SizedBox(height: 8.h),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                  color: appTheme.gray_300,
                  fontSize: 11.fSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DrawerLogout extends StatelessWidget {
  const _DrawerLogout({required this.authProvider});

  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: authProvider.isLoading
          ? null
          : () async {
              await authProvider.logout();
              NavigatorService.navigatorKey.currentState
                  ?.pushNamedAndRemoveUntil(
                    AppRoutes.cinemaLoginScreen,
                    (route) => false,
                  );
            },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: appTheme.color33A48B),
            bottom: BorderSide(color: appTheme.color33A48B),
          ),
        ),
        child: Text(
          'Log out',
          textAlign: TextAlign.center,
          style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
            color: appTheme.gray_300,
          ),
        ),
      ),
    );
  }
}

class _DrawerAction {
  const _DrawerAction(this.icon, this.label);

  final IconData icon;
  final String label;
}

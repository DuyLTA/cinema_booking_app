import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

const double profileTypeScale = 0.75;

double profileFont(double baseSize) => (baseSize * profileTypeScale).fSize;

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58.h,
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_01,
        border: Border(bottom: BorderSide(color: appTheme.bookRedBorder)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackTap,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 42.h,
              height: 42.h,
              child: Icon(
                Icons.arrow_back,
                color: appTheme.orange_100,
                size: 28.h,
              ),
            ),
          ),
          SizedBox(width: 8.h),
          Expanded(
            child: Text(
              'Cine Member',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyleHelper.instance.title20SemiBoldBodoniModa
                  .copyWith(
                    color: appTheme.gray_300,
                    fontSize: profileFont(22),
                  ),
            ),
          ),
          Icon(
            Icons.confirmation_number_outlined,
            color: appTheme.orange_100,
            size: 24.h,
          ),
          SizedBox(width: 18.h),
          Icon(Icons.menu, color: appTheme.orange_100, size: 28.h),
        ],
      ),
    );
  }
}

class ProfileHero extends StatelessWidget {
  const ProfileHero({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.characters.first.toUpperCase();

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 132.h,
              height: 132.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appTheme.gray_900,
                shape: BoxShape.circle,
                border: Border.all(color: appTheme.bookRedBorder, width: 3.h),
                boxShadow: [
                  BoxShadow(
                    color: appTheme.bookRedFill.withValues(alpha: 0.28),
                    blurRadius: 28.h,
                  ),
                ],
              ),
              child: Text(
                initial,
                style: TextStyleHelper.instance.title20SemiBoldBodoniModa
                    .copyWith(
                      color: appTheme.orange_100,
                      fontSize: profileFont(54),
                    ),
              ),
            ),
            Positioned(
              right: 4.h,
              bottom: 2.h,
              child: Container(
                width: 36.h,
                height: 36.h,
                decoration: BoxDecoration(
                  color: appTheme.gray_900_02,
                  shape: BoxShape.circle,
                  border: Border.all(color: appTheme.gray_400, width: 2.h),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: appTheme.gray_400,
                  size: 19.h,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        Text(
          name.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
            color: appTheme.gray_300,
            fontSize: profileFont(24),
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class ProfileFanCard extends StatelessWidget {
  const ProfileFanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.h),
      padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 14.h),
      decoration: BoxDecoration(
        color: appTheme.bookRedFill.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.bookRedBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 52.h,
            height: 42.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: appTheme.gray_900,
              borderRadius: BorderRadius.circular(6.h),
            ),
            child: Text(
              'FanC',
              style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
                color: appTheme.orange_100,
                fontSize: profileFont(14),
                letterSpacing: 0.8,
              ),
            ),
          ),
          SizedBox(width: 12.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join FanC',
                  style: TextStyleHelper.instance.title20SemiBoldBodoniModa
                      .copyWith(
                        color: appTheme.gray_300,
                        fontSize: profileFont(20),
                      ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.h,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: appTheme.orange_100.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14.h),
                    border: Border.all(color: appTheme.orange_100),
                  ),
                  child: Text(
                    'Verify now',
                    style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                      color: appTheme.orange_100,
                      fontSize: profileFont(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward, color: appTheme.orange_100, size: 30.h),
        ],
      ),
    );
  }
}

class ProfileMenuItem {
  const ProfileMenuItem(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

class ProfileMenuGroup extends StatelessWidget {
  const ProfileMenuGroup({super.key, required this.items});

  final List<ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) => ProfileMenuTile(item: item)).toList(),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({super.key, required this.item});

  final ProfileMenuItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Container(
        height: 62.h,
        padding: EdgeInsets.symmetric(horizontal: 20.h),
        decoration: BoxDecoration(
          color: appTheme.gray_900_02,
          border: Border(bottom: BorderSide(color: appTheme.color19A48B)),
        ),
        child: Row(
          children: [
            Icon(item.icon, color: appTheme.orange_100, size: 26.h),
            SizedBox(width: 18.h),
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
                  color: appTheme.gray_300,
                  fontSize: profileFont(18),
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: appTheme.gray_500, size: 28.h),
          ],
        ),
      ),
    );
  }
}

class ProfileDividerBand extends StatelessWidget {
  const ProfileDividerBand({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 36.h, color: appTheme.gray_900_03);
  }
}

class ProfileAccountHeader extends StatelessWidget {
  const ProfileAccountHeader({super.key, required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_01,
        border: Border(bottom: BorderSide(color: appTheme.bookRedBorder)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackTap,
            child: Container(
              width: 36.h,
              height: 36.h,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back,
                color: appTheme.orange_100,
                size: 22.h,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'ACCOUNT',
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.headline24RegularBebasNeue
                  .copyWith(
                    color: appTheme.orange_100,
                    fontSize: profileFont(24),
                    letterSpacing: 3,
                  ),
            ),
          ),
          SizedBox(width: 36.h),
        ],
      ),
    );
  }
}

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyleHelper.instance.title18RegularBebasNeue.copyWith(
        color: appTheme.gray_300,
        fontSize: profileFont(18),
        letterSpacing: 1.5,
      ),
    );
  }
}

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
        color: enabled ? appTheme.gray_300 : appTheme.gray_500,
        fontSize: profileFont(14),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyleHelper.instance.body12MediumDMSans.copyWith(
          color: appTheme.gray_500,
          fontSize: profileFont(12),
        ),
        prefixIcon: Icon(icon, color: appTheme.orange_100, size: 19.h),
        filled: true,
        fillColor: appTheme.gray_900_02,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.h),
          borderSide: BorderSide(color: appTheme.color19A48B),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.h),
          borderSide: BorderSide(color: appTheme.color19A48B),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.h),
          borderSide: BorderSide(color: appTheme.orange_100),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.h),
          borderSide: BorderSide(color: appTheme.color19A48B),
        ),
      ),
    );
  }
}

class ProfileActionButton extends StatelessWidget {
  const ProfileActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
        color: outlined ? appTheme.orange_100 : Colors.white,
        fontSize: profileFont(14),
        letterSpacing: 1.4,
      ),
    );

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: 44.h,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: appTheme.orange_100,
            side: BorderSide(color: appTheme.bookRedBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.h),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: appTheme.bookRedFill,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.h),
          ),
        ),
        child: child,
      ),
    );
  }
}

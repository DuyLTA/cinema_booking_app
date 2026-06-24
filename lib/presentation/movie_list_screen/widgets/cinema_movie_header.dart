import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class CinemaMovieHeader extends StatelessWidget implements PreferredSizeWidget {
  const CinemaMovieHeader({
    super.key,
    required this.cinemaName,
    required this.onBack,
  });

  final String cinemaName;
  final VoidCallback onBack;

  @override
  Size get preferredSize => Size.fromHeight(58.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: appTheme.gray_900_01,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: appTheme.bookRedBorder, width: 1.h),
          ),
        ),
      ),
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.h),
        child: Row(
          children: [
            SizedBox(
              width: 44.h,
              height: 44.h,
              child: IconButton(
                tooltip: 'Back',
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back,
                  color: appTheme.gray_300,
                  size: 22.h,
                ),
              ),
            ),
            Expanded(
              child: Text(
                cinemaName.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyleHelper.instance.headline24RegularBebasNeue
                    .copyWith(
                      color: appTheme.orange_100,
                      fontSize: 21.fSize,
                      letterSpacing: 1.8,
                    ),
              ),
            ),
            SizedBox(width: 44.h),
          ],
        ),
      ),
    );
  }
}

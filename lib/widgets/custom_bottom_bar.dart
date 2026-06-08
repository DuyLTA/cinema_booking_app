import 'package:flutter/material.dart';

import '../core/app_export.dart';
import 'custom_image_view.dart';

class CustomBottomBarItem {
  CustomBottomBarItem({
    required this.iconPath,
    this.activeIconPath,
    required this.title,
    required this.routeName,
  });

  final String iconPath;
  final String? activeIconPath;
  final String title;
  final String routeName;
}

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({
    Key? key,
    required this.selectedIndex,
    required this.onChanged,
    required this.bottomBarItems,
  }) : super(key: key);

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<CustomBottomBarItem> bottomBarItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appTheme.screenBackground,
        border: Border(top: BorderSide(color: appTheme.color19A48B, width: 1.h)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(bottomBarItems.length, (index) {
              final item = bottomBarItems[index];
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () => onChanged(index),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 72.h,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomImageView(
                        imagePath: isSelected
                            ? (item.activeIconPath ?? item.iconPath)
                            : item.iconPath,
                        height: 20.h,
                        width: 20.h,
                        fit: BoxFit.contain,
                        color: isSelected
                            ? appTheme.orange_100
                            : appTheme.gray_500,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.title,
                        style: TextStyleHelper.instance.label10RegularDMSans
                            .copyWith(
                              color: isSelected
                                  ? appTheme.orange_100
                                  : appTheme.gray_500,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/booking_flow_models.dart';
import '../../../widgets/custom_image_view.dart';
import '../../session_selection_screen/widgets/session_selection_widgets.dart';

class FoodBeverageHeader extends BookingFlowHeader {
  const FoodBeverageHeader({super.key}) : super(title: 'CINE BOOKING');
}

class FoodBeverageTitle extends StatelessWidget {
  const FoodBeverageTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.h, 20.h, 14.h, 18.h),
      child: Column(
        children: [
          Text(
            'FOOD & BEVERAGE',
            style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
              color: appTheme.gray_300,
              fontSize: 24.fSize,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8.h),
          Container(width: 44.h, height: 2.h, color: appTheme.bookRedBorder),
        ],
      ),
    );
  }
}

class FoodCategorySelector extends StatelessWidget {
  const FoodCategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 14.h),
        itemCount: categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 10.h),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = selectedCategory == category;

          return GestureDetector(
            onTap: () => onSelected(category),
            child: Container(
              constraints: BoxConstraints(minWidth: 78.h),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              decoration: BoxDecoration(
                color: selected ? appTheme.orange_100 : appTheme.gray_900_03,
                borderRadius: BorderRadius.circular(20.h),
                border: Border.all(
                  color: selected ? appTheme.orange_100 : appTheme.color19A48B,
                ),
              ),
              child: Text(
                category.toUpperCase(),
                style: TextStyleHelper.instance.label10RegularBebasNeue
                    .copyWith(
                      color: selected ? appTheme.black_900 : appTheme.gray_300,
                      letterSpacing: 1,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FoodGrid extends StatelessWidget {
  const FoodGrid({
    super.key,
    required this.foods,
    required this.quantityOf,
    required this.onIncrement,
    required this.onDecrement,
  });

  final List<FoodItemModel> foods;
  final int Function(FoodItemModel food) quantityOf;
  final ValueChanged<FoodItemModel> onIncrement;
  final ValueChanged<FoodItemModel> onDecrement;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(14.h, 18.h, 14.h, 18.h),
      itemCount: foods.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.h,
        mainAxisSpacing: 18.h,
        childAspectRatio: 0.56,
      ),
      itemBuilder: (context, index) {
        final food = foods[index];
        return FoodCard(
          food: food,
          quantity: quantityOf(food),
          onIncrement: () => onIncrement(food),
          onDecrement: () => onDecrement(food),
        );
      },
    );
  }
}

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.food,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final FoodItemModel food;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appTheme.gray_900_02,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.color19A48B),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.h)),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomImageView(
                    imagePath: food.imageUrl.isEmpty
                        ? ImageConstant.imgImageNotFound
                        : food.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          appTheme.black_900.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyleHelper.instance.body14RegularBebasNeue
                        .copyWith(color: appTheme.gray_300, letterSpacing: 0.8),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    food.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                      color: appTheme.gray_500,
                      fontSize: 10.fSize,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatVnd(food.price),
                    style: TextStyleHelper.instance.title18RegularBebasNeue
                        .copyWith(
                          color: appTheme.orange_100,
                          fontSize: 18.fSize,
                        ),
                  ),
                  SizedBox(height: 8.h),
                  FoodQuantityStepper(
                    quantity: quantity,
                    onIncrement: onIncrement,
                    onDecrement: onDecrement,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FoodQuantityStepper extends StatelessWidget {
  const FoodQuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.h,
      decoration: BoxDecoration(
        color: appTheme.gray_800,
        borderRadius: BorderRadius.circular(18.h),
      ),
      child: Row(
        children: [
          _StepperButton(icon: Icons.remove, onTap: onDecrement),
          Expanded(
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
                color: appTheme.gray_300,
                letterSpacing: 1,
              ),
            ),
          ),
          _StepperButton(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 34.h,
        child: Icon(icon, color: appTheme.gray_300, size: 14.h),
      ),
    );
  }
}

class FoodBottomBar extends StatelessWidget {
  const FoodBottomBar({
    super.key,
    required this.itemCount,
    required this.total,
    required this.onProceed,
  });

  final int itemCount;
  final double total;
  final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.h, 10.h, 14.h, 12.h),
      decoration: BoxDecoration(
        color: appTheme.screenBackground,
        border: Border(top: BorderSide(color: appTheme.lime_900)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$itemCount ITEMS SELECTED',
                  style: TextStyleHelper.instance.label10RegularBebasNeue
                      .copyWith(color: appTheme.orange_100, letterSpacing: 0.8),
                ),
                SizedBox(height: 2.h),
                Text(
                  formatVnd(total),
                  style: TextStyleHelper.instance.title18RegularBebasNeue
                      .copyWith(color: appTheme.gray_300, fontSize: 18.fSize),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 164.h,
            height: 46.h,
            child: ElevatedButton(
              onPressed: onProceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme.bookRedFill,
                foregroundColor: appTheme.gray_300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.h),
                ),
              ),
              child: Text(
                'PROCEED TO CONFIRMATION',
                textAlign: TextAlign.center,
                style: TextStyleHelper.instance.label10RegularBebasNeue
                    .copyWith(letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

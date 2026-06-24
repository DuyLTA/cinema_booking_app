import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/booking_flow_models.dart';
import '../../food_beverage_screen/widgets/food_beverage_widgets.dart';

class PaymentHeader extends FoodBeverageHeader {
  const PaymentHeader({super.key});
}

class PaymentAmountSummary extends StatelessWidget {
  const PaymentAmountSummary({
    super.key,
    required this.total,
    required this.discountAmount,
    required this.appliedCouponCode,
    required this.seatCount,
    required this.foodCount,
  });

  final double total;
  final double discountAmount;
  final String? appliedCouponCode;
  final int seatCount;
  final int foodCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.h, 24.h, 14.h, 28.h),
      child: Column(
        children: [
          Text(
            'TOTAL AMOUNT',
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              color: appTheme.gray_500,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            formatVnd(total),
            textAlign: TextAlign.center,
            style: TextStyleHelper.instance.display48RegularBebasNeue.copyWith(
              color: appTheme.amber_A400,
              fontSize: 42.fSize,
              letterSpacing: 1,
              shadows: [
                Shadow(
                  color: appTheme.amber_A400.withValues(alpha: 0.5),
                  blurRadius: 12.h,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.h,
            runSpacing: 8.h,
            children: [
              _SummaryChip(label: '$seatCount Premium Seats'),
              _SummaryChip(label: '$foodCount Beverage items'),
              _SummaryChip(
                label: appliedCouponCode == null
                    ? 'No voucher'
                    : 'Voucher ${appliedCouponCode!}',
              ),
            ],
          ),
          if (discountAmount > 0) ...[
            SizedBox(height: 8.h),
            Text(
              'You saved ${formatVnd(discountAmount)}',
              style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                color: appTheme.orange_100,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 5.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_03,
        borderRadius: BorderRadius.circular(14.h),
      ),
      child: Text(
        label,
        style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
          color: appTheme.gray_400,
          fontSize: 10.fSize,
        ),
      ),
    );
  }
}

class PaymentMethodList extends StatelessWidget {
  const PaymentMethodList({
    super.key,
    required this.methods,
    required this.selectedType,
    required this.onSelected,
  });

  final List<PaymentMethodModel> methods;
  final PaymentMethodType selectedType;
  final ValueChanged<PaymentMethodType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PAYMENT METHOD',
            style: TextStyleHelper.instance.title18RegularBebasNeue.copyWith(
              color: appTheme.gray_300,
              fontSize: 18.fSize,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 10.h),
          ...methods.map(
            (method) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: PaymentMethodTile(
                method: method,
                selected: method.type == selectedType,
                onTap: () => onSelected(method.type),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethodModel method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 12.h),
        decoration: BoxDecoration(
          color: appTheme.gray_900_02,
          borderRadius: BorderRadius.circular(6.h),
          border: Border.all(
            color: selected ? appTheme.bookRedBorder : appTheme.color19A48B,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32.h,
              height: 32.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(method.iconColor),
                borderRadius: BorderRadius.circular(6.h),
              ),
              child: Text(
                method.shortLabel,
                textAlign: TextAlign.center,
                style: TextStyleHelper.instance.label10RegularBebasNeue
                    .copyWith(color: Colors.white, fontSize: 10.fSize),
              ),
            ),
            SizedBox(width: 12.h),
            Expanded(
              child: Text(
                method.name,
                style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
                  color: appTheme.gray_300,
                  fontSize: 14.fSize,
                ),
              ),
            ),
            Container(
              width: 18.h,
              height: 18.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? appTheme.amber_A400 : Colors.transparent,
                border: Border.all(
                  color: selected ? appTheme.orange_100 : appTheme.gray_500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PayNowBar extends StatelessWidget {
  const PayNowBar({
    super.key,
    required this.total,
    required this.isProcessing,
    required this.onPay,
  });

  final double total;
  final bool isProcessing;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.h, 12.h, 14.h, 14.h),
      decoration: BoxDecoration(
        color: appTheme.screenBackground,
        border: Border(top: BorderSide(color: appTheme.bookRedBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: isProcessing ? null : onPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme.bookRedFill,
                foregroundColor: appTheme.gray_300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.h),
                ),
              ),
              child: isProcessing
                  ? SizedBox(
                      width: 18.h,
                      height: 18.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.h,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          appTheme.orange_100,
                        ),
                      ),
                    )
                  : Text(
                      'PAY NOW (${formatVnd(total)})',
                      style: TextStyleHelper.instance.body14RegularBebasNeue
                          .copyWith(letterSpacing: 1.4),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/booking_flow_models.dart';
import '../../cinema_home_screen/models/offer_model.dart';
import '../../food_beverage_screen/widgets/food_beverage_widgets.dart';

class BookingConfirmationHeader extends FoodBeverageHeader {
  const BookingConfirmationHeader({super.key});
}

class ConfirmationTicketCard extends StatelessWidget {
  const ConfirmationTicketCard({
    super.key,
    required this.movieTitle,
    required this.session,
    required this.selectedSeats,
    required this.selectedFoods,
    required this.seatTotal,
    required this.foodTotal,
  });

  final String movieTitle;
  final BookingSessionModel session;
  final List<ShowtimeSeatModel> selectedSeats;
  final List<SelectedFoodItemModel> selectedFoods;
  final double seatTotal;
  final double foodTotal;

  @override
  Widget build(BuildContext context) {
    final seatText = selectedSeats.map((seat) => seat.seatCode).join(', ');
    return Container(
      margin: EdgeInsets.fromLTRB(14.h, 26.h, 14.h, 16.h),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_02,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.color19A48B),
      ),
      child: Column(
        children: [
          Text(
            movieTitle.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
              color: appTheme.amber_A400,
              fontSize: 20.fSize,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${session.format.toUpperCase()} EXPERIENCE',
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              color: appTheme.gray_500,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _TicketInfo(label: 'CINEMA', value: session.cinemaName),
              ),
              _TicketInfo(label: 'SEATS', value: seatText, alignRight: true),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _TicketInfo(
                  label: 'DATE',
                  value: _dateLabel(session.startTime),
                ),
              ),
              _TicketInfo(
                label: 'TIME',
                value: _timeLabel(session.startTime),
                alignRight: true,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _Manifest(
            selectedSeats: selectedSeats,
            selectedFoods: selectedFoods,
            seatTotal: seatTotal,
            foodTotal: foodTotal,
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _timeLabel(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _TicketInfo extends StatelessWidget {
  const _TicketInfo({
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
            color: appTheme.gray_500,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
            color: appTheme.gray_300,
          ),
        ),
      ],
    );
  }
}

class _Manifest extends StatelessWidget {
  const _Manifest({
    required this.selectedSeats,
    required this.selectedFoods,
    required this.seatTotal,
    required this.foodTotal,
  });

  final List<ShowtimeSeatModel> selectedSeats;
  final List<SelectedFoodItemModel> selectedFoods;
  final double seatTotal;
  final double foodTotal;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      _ManifestRow(
        label: '${selectedSeats.length}x Premium Seats',
        price: seatTotal,
      ),
      ...selectedFoods.map(
        (item) => _ManifestRow(
          label: '${item.quantity}x ${item.food.name}',
          price: item.lineTotal,
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ITEMIZED MANIFEST',
          style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
            color: appTheme.orange_100,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 8.h),
        ...rows,
      ],
    );
  }
}

class _ManifestRow extends StatelessWidget {
  const _ManifestRow({required this.label, required this.price});

  final String label;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '• $label',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                color: appTheme.gray_300,
              ),
            ),
          ),
          SizedBox(width: 10.h),
          Text(
            formatVnd(price),
            style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
              color: appTheme.gray_300,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class VoucherSelector extends StatelessWidget {
  const VoucherSelector({
    super.key,
    required this.vouchers,
    required this.onChanged,
    required this.isLoading,
    this.selectedVoucher,
    this.errorMessage,
  });

  final List<OfferModel> vouchers;
  final ValueChanged<OfferModel?> onChanged;
  final bool isLoading;
  final OfferModel? selectedVoucher;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.h, 0, 14.h, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROMOTIONAL VOUCHER',
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              color: appTheme.gray_500,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.h),
            decoration: BoxDecoration(
              color: appTheme.gray_900_02,
              borderRadius: BorderRadius.circular(6.h),
              border: Border.all(color: appTheme.color19A48B),
            ),
            child: isLoading
                ? SizedBox(
                    height: 48.h,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16.h,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: appTheme.orange_100,
                          ),
                        ),
                        SizedBox(width: 10.h),
                        Text(
                          'LOADING YOUR VOUCHERS...',
                          style: TextStyleHelper
                              .instance
                              .label10RegularBebasNeue
                              .copyWith(
                                color: appTheme.gray_500,
                                letterSpacing: 1,
                              ),
                        ),
                      ],
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<OfferModel>(
                      value: selectedVoucher,
                      isExpanded: true,
                      dropdownColor: appTheme.gray_900_02,
                      iconEnabledColor: appTheme.orange_100,
                      hint: Text(
                        vouchers.isEmpty
                            ? 'NO VOUCHERS OWNED'
                            : 'SELECT YOUR VOUCHER',
                        style: TextStyleHelper.instance.label10RegularBebasNeue
                            .copyWith(
                              color: appTheme.gray_500,
                              letterSpacing: 1,
                            ),
                      ),
                      items: vouchers
                          .map(
                            (voucher) => DropdownMenuItem<OfferModel>(
                              value: voucher,
                              child: _VoucherOption(voucher: voucher),
                            ),
                          )
                          .toList(),
                      onChanged: vouchers.isEmpty ? null : onChanged,
                    ),
                  ),
          ),
          if (selectedVoucher != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Applied: ${selectedVoucher?.promoCode ?? ''}',
                    style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                      color: appTheme.orange_100,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => onChanged(null),
                  child: Text(
                    'REMOVE',
                    style: TextStyleHelper.instance.label10RegularBebasNeue
                        .copyWith(
                          color: appTheme.deep_orange_100,
                          letterSpacing: 1,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
              ],
            ),
          ],
          if (errorMessage != null) ...[
            SizedBox(height: 6.h),
            Text(
              errorMessage!,
              style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                color: appTheme.deep_orange_100,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VoucherOption extends StatelessWidget {
  const _VoucherOption({required this.voucher});

  final OfferModel voucher;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 7.h, vertical: 3.h),
          decoration: BoxDecoration(
            color: appTheme.bookRedFill,
            borderRadius: BorderRadius.circular(4.h),
          ),
          child: Text(
            voucher.promoCode ?? '',
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              color: appTheme.orange_100,
              letterSpacing: 0.8,
            ),
          ),
        ),
        SizedBox(width: 10.h),
        Expanded(
          child: Text(
            voucher.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
              color: appTheme.gray_300,
            ),
          ),
        ),
      ],
    );
  }
}

class PriceSummaryCard extends StatelessWidget {
  const PriceSummaryCard({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  final double subtotal;
  final double discount;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(14.h, 0, 14.h, 14.h),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_02,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.color19A48B),
      ),
      child: Column(
        children: [
          _PriceRow(label: 'Subtotal', value: subtotal),
          SizedBox(height: 10.h),
          _PriceRow(label: 'Discount', value: discount),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'TOTAL PRICE',
                  style: TextStyleHelper.instance.label10RegularBebasNeue
                      .copyWith(color: appTheme.gray_300, letterSpacing: 1),
                ),
              ),
              Text(
                formatVnd(total),
                style: TextStyleHelper.instance.display48RegularBebasNeue
                    .copyWith(
                      color: appTheme.amber_A400,
                      fontSize: 34.fSize,
                      letterSpacing: 1,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
              color: appTheme.gray_400,
            ),
          ),
        ),
        Text(
          label == 'Discount'
              ? value == 0
                    ? formatVnd(0)
                    : '-${formatVnd(value)}'
              : formatVnd(value),
          style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
            color: appTheme.gray_300,
          ),
        ),
      ],
    );
  }
}

class ConfirmPayButton extends StatelessWidget {
  const ConfirmPayButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.h, 0, 14.h, 14.h),
      child: SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: appTheme.bookRedFill,
            foregroundColor: appTheme.gray_300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.h),
            ),
          ),
          child: Text(
            'CONFIRM & PAY NOW',
            style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

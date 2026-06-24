import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/booking_flow_models.dart';
import '../../payment_method_screen/widgets/payment_method_widgets.dart';

class ResultHeader extends PaymentHeader {
  const ResultHeader({super.key});
}

class SuccessHero extends StatelessWidget {
  const SuccessHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 24.h, bottom: 18.h),
      child: Column(
        children: [
          Container(
            width: 74.h,
            height: 74.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: appTheme.amber_A400, width: 2.h),
              boxShadow: [
                BoxShadow(
                  color: appTheme.amber_A400.withValues(alpha: 0.45),
                  blurRadius: 24.h,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 42.h,
                height: 42.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appTheme.amber_A400,
                ),
                child: Icon(Icons.check, color: appTheme.black_900, size: 26.h),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            'BOOKING SUCCESSFUL!',
            style: TextStyleHelper.instance.title18RegularBebasNeue.copyWith(
              color: appTheme.orange_100,
              fontSize: 22.fSize,
              letterSpacing: 3,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Enjoy the movie, you are all set.',
            style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
              color: appTheme.gray_400,
            ),
          ),
        ],
      ),
    );
  }
}

class SuccessTicket extends StatelessWidget {
  const SuccessTicket({
    super.key,
    required this.movieTitle,
    required this.session,
    required this.selectedSeats,
    required this.bookingId,
  });

  final String movieTitle;
  final BookingSessionModel session;
  final List<ShowtimeSeatModel> selectedSeats;
  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final seats = selectedSeats.map((seat) => seat.seatCode).join(', ');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.h),
      padding: EdgeInsets.all(14.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_02,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.color66A48B),
      ),
      child: Column(
        children: [
          Container(
            width: 150.h,
            height: 150.h,
            padding: EdgeInsets.all(10.h),
            color: appTheme.gray_300,
            child: const FauxQrCode(),
          ),
          SizedBox(height: 8.h),
          Text(
            'Scan QR at the self-service kiosk or entrance gate',
            textAlign: TextAlign.center,
            style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
              color: appTheme.gray_500,
              fontSize: 10.fSize,
            ),
          ),
          SizedBox(height: 20.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              movieTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyleHelper.instance.title20SemiBoldBodoniModa
                  .copyWith(color: appTheme.orange_100, fontSize: 18.fSize),
            ),
          ),
          SizedBox(height: 4.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_timeLabel(session.startTime)} - ${_dateLabel(session.startTime)}',
              style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                color: appTheme.gray_300,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _TicketDetail(label: 'BOOKING ID', value: bookingId),
              ),
              _TicketDetail(label: 'SEATS', value: seats, alignRight: true),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _TicketDetail(
                  label: 'LOCATION',
                  value: session.cinemaName,
                ),
              ),
              _TicketDetail(
                label: 'SCREEN',
                value: session.roomName,
                alignRight: true,
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Container(
            height: 26.h,
            padding: EdgeInsets.symmetric(horizontal: 10.h),
            color: appTheme.orange_100,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'CINE BOOKING PREMIUM TICKET',
                    style: TextStyleHelper.instance.label10RegularBebasNeue
                        .copyWith(color: appTheme.black_900),
                  ),
                ),
                Text(
                  'VALID FOR ADMISSION',
                  style: TextStyleHelper.instance.label10RegularBebasNeue
                      .copyWith(color: appTheme.black_900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _dateLabel(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class FauxQrCode extends StatelessWidget {
  const FauxQrCode({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 121,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 11,
      ),
      itemBuilder: (context, index) {
        final x = index % 11;
        final y = index ~/ 11;
        final finder = (x < 3 && y < 3) || (x > 7 && y < 3) || (x < 3 && y > 7);
        final filled = finder || ((x * 7 + y * 5 + index) % 4 == 0);
        return Container(
          margin: EdgeInsets.all(1.h),
          color: filled ? appTheme.black_900 : appTheme.gray_300,
        );
      },
    );
  }
}

class _TicketDetail extends StatelessWidget {
  const _TicketDetail({
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
            color: appTheme.orange_100,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
            color: appTheme.gray_300,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class ResultActionButtons extends StatelessWidget {
  const ResultActionButtons({
    super.key,
    required this.onHome,
    this.primaryLabel = 'GET SUPPORT',
    this.onPrimary,
    this.onTryAgain,
    this.showTryAgain = false,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onTryAgain;
  final VoidCallback onHome;
  final bool showTryAgain;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.h, 14.h, 14.h, 14.h),
      child: Column(
        children: [
          if (showTryAgain) ...[
            _ResultButton(
              label: 'TRY AGAIN',
              onTap: onTryAgain ?? onPrimary ?? () {},
              filled: true,
            ),
            SizedBox(height: 12.h),
          ],
          _ResultButton(
            label: primaryLabel,
            onTap: onPrimary ?? () {},
            filled: true,
          ),
          SizedBox(height: 12.h),
          _ResultButton(label: 'BACK TO HOME', onTap: onHome, filled: false),
        ],
      ),
    );
  }
}

class _ResultButton extends StatelessWidget {
  const _ResultButton({
    required this.label,
    required this.onTap,
    required this.filled,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? appTheme.bookRedFill : Colors.transparent,
          foregroundColor: filled ? appTheme.gray_300 : appTheme.orange_100,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.h),
            side: BorderSide(
              color: filled ? appTheme.bookRedBorder : appTheme.orange_100,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class PaymentErrorContent extends StatelessWidget {
  const PaymentErrorContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.h, 34.h, 24.h, 0),
      child: Column(
        children: [
          Container(
            width: 80.h,
            height: 80.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appTheme.bookRedFill.withValues(alpha: 0.35),
              border: Border.all(color: appTheme.bookRedBorder),
            ),
            child: Icon(
              Icons.error,
              color: appTheme.deep_orange_100,
              size: 34.h,
            ),
          ),
          SizedBox(height: 28.h),
          Text(
            'TRANSACTION FAILED',
            style: TextStyleHelper.instance.title18RegularBebasNeue.copyWith(
              color: appTheme.deep_orange_100,
              fontSize: 22.fSize,
              letterSpacing: 2.4,
            ),
          ),
          SizedBox(height: 10.h),
          Container(width: 48.h, height: 1.h, color: appTheme.deep_orange_100),
          SizedBox(height: 28.h),
          Text(
            'The payment could not be processed due to insufficient funds or a temporary server timeout.',
            textAlign: TextAlign.center,
            style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
              color: appTheme.gray_400,
              fontSize: 14.fSize,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

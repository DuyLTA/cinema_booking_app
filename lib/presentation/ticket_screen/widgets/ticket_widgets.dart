import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/booked_ticket_model.dart';
import '../../../models/booking_flow_models.dart';

class BookedTicketCard extends StatelessWidget {
  const BookedTicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  final BookedTicketModel ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(14.h),
        decoration: BoxDecoration(
          color: appTheme.gray_900_02,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: appTheme.color19A48B),
        ),
        child: Row(
          children: [
            TicketQrPreview(payload: ticket.qrPayload, size: 58.h),
            SizedBox(width: 12.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.movieTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyleHelper.instance.title20SemiBoldBodoniModa
                        .copyWith(
                          color: appTheme.orange_100,
                          fontSize: 17.fSize,
                        ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${_formatDate(ticket.session.startTime)} • ${_formatTime(ticket.session.startTime)}',
                    style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                      color: appTheme.gray_400,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${ticket.session.cinemaName} • ${ticket.seatsLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                      color: appTheme.gray_500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.h),
            Icon(Icons.chevron_right, color: appTheme.orange_100, size: 24.h),
          ],
        ),
      ),
    );
  }
}

class TicketDetailHeader extends StatelessWidget {
  const TicketDetailHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58.h,
      decoration: BoxDecoration(
        color: appTheme.gray_900_01,
        border: Border(bottom: BorderSide(color: appTheme.bookRedBorder)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(Icons.arrow_back, color: appTheme.gray_300, size: 22.h),
          ),
          Expanded(
            child: Text(
              'TICKET DETAIL',
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.headline24RegularBebasNeue
                  .copyWith(
                    color: appTheme.orange_100,
                    fontSize: 22.fSize,
                    letterSpacing: 2.4,
                  ),
            ),
          ),
          SizedBox(width: 48.h),
        ],
      ),
    );
  }
}

class TicketDetailCard extends StatelessWidget {
  const TicketDetailCard({super.key, required this.ticket});

  final BookedTicketModel ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_02,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.color66A48B),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: TicketQrPreview(payload: ticket.qrPayload, size: 170.h),
          ),
          SizedBox(height: 8.h),
          Text(
            'Scan this QR at the cinema counter or entrance gate',
            textAlign: TextAlign.center,
            style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
              color: appTheme.gray_500,
              fontSize: 10.fSize,
            ),
          ),
          SizedBox(height: 22.h),
          Text(
            ticket.movieTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
              color: appTheme.orange_100,
              fontSize: 20.fSize,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${ticket.session.format} • ${ticket.session.roomName}',
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              color: appTheme.gray_500,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 18.h),
          TicketInfoGrid(
            items: [
              TicketInfoItem('BOOKING ID', ticket.id),
              TicketInfoItem('SEATS', ticket.seatsLabel),
              TicketInfoItem('DATE', _formatDate(ticket.session.startTime)),
              TicketInfoItem('TIME', _formatTime(ticket.session.startTime)),
              TicketInfoItem('CINEMA', ticket.session.cinemaName),
              TicketInfoItem('LOCATION', ticket.session.cinemaAddress),
              TicketInfoItem('PAYMENT', ticket.paymentMethod),
              TicketInfoItem('TOTAL', formatVnd(ticket.total)),
            ],
          ),
          if (ticket.selectedFoods.isNotEmpty) ...[
            SizedBox(height: 18.h),
            TicketFoodManifest(foods: ticket.selectedFoods),
          ],
          SizedBox(height: 18.h),
          Container(
            height: 28.h,
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
}

class TicketInfoItem {
  const TicketInfoItem(this.label, this.value);

  final String label;
  final String value;
}

class TicketInfoGrid extends StatelessWidget {
  const TicketInfoGrid({super.key, required this.items});

  final List<TicketInfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 14.h,
      children: items.map((item) {
        return SizedBox(
          width: MediaQuery.sizeOf(context).width / 2 - 28.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: TextStyleHelper.instance.label10RegularBebasNeue
                    .copyWith(color: appTheme.orange_100, letterSpacing: 1),
              ),
              SizedBox(height: 4.h),
              Text(
                item.value.isEmpty ? '-' : item.value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                  color: appTheme.gray_300,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class TicketFoodManifest extends StatelessWidget {
  const TicketFoodManifest({super.key, required this.foods});

  final List<SelectedFoodItemModel> foods;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: appTheme.screenBackground,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.color19A48B),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FOOD & BEVERAGE',
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              color: appTheme.orange_100,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 10.h),
          ...foods.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.food.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyleHelper.instance.body12MediumDMSans
                          .copyWith(color: appTheme.gray_300),
                    ),
                  ),
                  Text(
                    formatVnd(item.lineTotal),
                    style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                      color: appTheme.orange_100,
                      fontWeight: FontWeight.w700,
                    ),
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

class TicketQrPreview extends StatelessWidget {
  const TicketQrPreview({super.key, required this.payload, required this.size});

  final String payload;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      color: appTheme.gray_300,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 121,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 11,
        ),
        itemBuilder: (context, index) {
          final x = index % 11;
          final y = index ~/ 11;
          final finder =
              (x < 3 && y < 3) || (x > 7 && y < 3) || (x < 3 && y > 7);
          final payloadSeed = payload.codeUnits.fold<int>(
            0,
            (sum, code) => (sum + code) % 997,
          );
          final filled =
              finder || ((x * 17 + y * 11 + index + payloadSeed) % 4 == 0);
          return Container(
            margin: EdgeInsets.all(1.h),
            color: filled ? appTheme.black_900 : appTheme.gray_300,
          );
        },
      ),
    );
  }
}

class TicketEmptyState extends StatelessWidget {
  const TicketEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: appTheme.orange_100, size: 48.h),
            SizedBox(height: 14.h),
            Text(
              title,
              style: TextStyleHelper.instance.title20SemiBoldBodoniModa
                  .copyWith(color: appTheme.gray_300),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
                color: appTheme.gray_500,
                fontSize: 14.fSize,
              ),
            ),
            SizedBox(height: 18.h),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme.bookRedFill,
                foregroundColor: appTheme.gray_300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.h),
                ),
              ),
              child: Text(
                actionLabel,
                style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _formatTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

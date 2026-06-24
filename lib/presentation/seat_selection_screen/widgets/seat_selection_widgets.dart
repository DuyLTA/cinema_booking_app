import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/booking_flow_models.dart';
import '../../session_selection_screen/widgets/session_selection_widgets.dart';

class SeatMovieHeader extends StatelessWidget {
  const SeatMovieHeader({
    super.key,
    required this.title,
    required this.session,
  });

  final String title;
  final BookingSessionModel session;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.h, 20.h, 18.h, 14.h),
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyleHelper.instance.title20SemiBoldBodoniModa.copyWith(
              color: appTheme.gray_300,
              fontSize: 22.fSize,
              height: 1.1,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '${session.cinemaName.toUpperCase()} - ${_formatTime(session.startTime)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              color: appTheme.gray_500,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 18.h),
          Container(
            height: 5.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: appTheme.orange_100,
              borderRadius: BorderRadius.circular(6.h),
              boxShadow: [
                BoxShadow(
                  color: appTheme.orange_100.withValues(alpha: 0.8),
                  blurRadius: 8.h,
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'THE SCREEN',
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              color: appTheme.orange_100,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class SeatGrid extends StatelessWidget {
  const SeatGrid({
    super.key,
    required this.seats,
    required this.isSelected,
    required this.onSeatTap,
  });

  final List<ShowtimeSeatModel> seats;
  final bool Function(ShowtimeSeatModel seat) isSelected;
  final ValueChanged<ShowtimeSeatModel> onSeatTap;

  @override
  Widget build(BuildContext context) {
    final groupedRows = <String, List<ShowtimeSeatModel>>{};
    for (final seat in seats) {
      groupedRows.putIfAbsent(seat.rowLabel, () => []).add(seat);
    }

    final rows = groupedRows.keys.toList()
      ..sort((a, b) => _compareNatural(a, b));
    final columnNumbers =
        seats
            .map((seat) => seat.seatNumber)
            .where((seatNumber) => seatNumber > 0)
            .toSet()
            .toList()
          ..sort();
    final maxSeatCount = columnNumbers.isEmpty
        ? groupedRows.values.fold<int>(0, (max, rowSeats) {
            final rowMax = rowSeats.fold<int>(
              0,
              (rowMax, seat) =>
                  seat.seatNumber > rowMax ? seat.seatNumber : rowMax,
            );
            return rowMax > max ? rowMax : max;
          })
        : columnNumbers.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 7.h;
        final availableWidth = constraints.maxWidth - 28.h;
        final rawSeatSize = maxSeatCount == 0
            ? 20.h
            : (availableWidth - (gap * (maxSeatCount - 1))) / maxSeatCount;
        final seatSize = rawSeatSize.clamp(18.h, 28.h).toDouble();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.h),
          child: Column(
            children: rows.map((row) {
              final rowSeats = [...groupedRows[row]!]
                ..sort((a, b) => a.seatNumber.compareTo(b.seatNumber));
              final seatsByNumber = {
                for (final seat in rowSeats) seat.seatNumber: seat,
              };

              return Padding(
                padding: EdgeInsets.only(bottom: gap),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    columnNumbers.isEmpty ? maxSeatCount : columnNumbers.length,
                    (index) {
                      final seatNumber = columnNumbers.isEmpty
                          ? index + 1
                          : columnNumbers[index];
                      final seat = seatsByNumber[seatNumber];
                      final isLastSeat =
                          index ==
                          (columnNumbers.isEmpty
                              ? maxSeatCount - 1
                              : columnNumbers.length - 1);

                      Widget seatWidget = SizedBox(
                        width: seatSize,
                        height: seatSize,
                        child: const SizedBox.shrink(),
                      );

                      if (seat != null) {
                        seatWidget = SeatTile(
                          seat: seat,
                          selected: isSelected(seat),
                          size: seatSize,
                          onTap: () => onSeatTap(seat),
                        );
                      }

                      return Padding(
                        padding: EdgeInsets.only(right: isLastSeat ? 0 : gap),
                        child: seatWidget,
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  int _compareNatural(String left, String right) {
    final leftMatch = RegExp(r'^([A-Za-z]+)(\d+)?$').firstMatch(left.trim());
    final rightMatch = RegExp(r'^([A-Za-z]+)(\d+)?$').firstMatch(right.trim());

    if (leftMatch != null && rightMatch != null) {
      final leftPrefix = leftMatch.group(1)!.toUpperCase();
      final rightPrefix = rightMatch.group(1)!.toUpperCase();
      final prefixCompare = leftPrefix.compareTo(rightPrefix);
      if (prefixCompare != 0) return prefixCompare;

      final leftNumber = int.tryParse(leftMatch.group(2) ?? '') ?? 0;
      final rightNumber = int.tryParse(rightMatch.group(2) ?? '') ?? 0;
      return leftNumber.compareTo(rightNumber);
    }

    return left.toUpperCase().compareTo(right.toUpperCase());
  }
}

class SeatTile extends StatelessWidget {
  const SeatTile({
    super.key,
    required this.seat,
    required this.selected,
    required this.size,
    required this.onTap,
  });

  final ShowtimeSeatModel seat;
  final bool selected;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final booked = seat.isUnavailable;
    final vip = seat.normalizedType == 'vip';

    Color fillColor;
    Color borderColor;
    double opacity;
    if (selected) {
      fillColor = appTheme.orange_100;
      borderColor = appTheme.orange_100;
      opacity = 1;
    } else if (booked) {
      fillColor = appTheme.gray_800.withValues(alpha: 0.9);
      borderColor = appTheme.color7FA48B;
      opacity = 0.55;
    } else if (vip) {
      fillColor = Colors.transparent;
      borderColor = appTheme.bookRedBorder;
      opacity = 1;
    } else {
      fillColor = Colors.transparent;
      borderColor = appTheme.color33A48B;
      opacity = 1;
    }

    return GestureDetector(
      onTap: booked ? null : onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(2.h),
            border: Border.all(color: borderColor, width: 1.h),
          ),
        ),
      ),
    );
  }
}

class SeatLegend extends StatelessWidget {
  const SeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(14.h, 22.h, 14.h, 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 12.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_02,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.color19A48B),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 18.h,
        runSpacing: 10.h,
        children: const [
          _LegendItem(label: 'REGULAR', colorType: _LegendColor.regular),
          _LegendItem(label: 'VIP', colorType: _LegendColor.vip),
          _LegendItem(label: 'BOOKED', colorType: _LegendColor.booked),
          _LegendItem(label: 'SELECTED', colorType: _LegendColor.selected),
        ],
      ),
    );
  }
}

enum _LegendColor { regular, vip, booked, selected }

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.colorType});

  final String label;
  final _LegendColor colorType;

  @override
  Widget build(BuildContext context) {
    final style = switch (colorType) {
      _LegendColor.regular => _LegendStyle(
        fill: Colors.transparent,
        border: appTheme.color33A48B,
      ),
      _LegendColor.vip => _LegendStyle(
        fill: Colors.transparent,
        border: appTheme.bookRedBorder,
      ),
      _LegendColor.booked => _LegendStyle(
        fill: appTheme.gray_800.withValues(alpha: 0.9),
        border: appTheme.color7FA48B,
      ),
      _LegendColor.selected => _LegendStyle(
        fill: appTheme.orange_100,
        border: appTheme.orange_100,
      ),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14.h,
          height: 14.h,
          decoration: BoxDecoration(
            color: style.fill,
            border: Border.all(color: style.border),
          ),
        ),
        SizedBox(width: 6.h),
        Text(
          label,
          style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
            color: appTheme.gray_300,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _LegendStyle {
  const _LegendStyle({required this.fill, required this.border});

  final Color fill;
  final Color border;
}

class SeatBottomSummary extends StatelessWidget {
  const SeatBottomSummary({
    super.key,
    required this.selectedSeats,
    required this.totalAmount,
    required this.onConfirm,
  });

  final List<ShowtimeSeatModel> selectedSeats;
  final double totalAmount;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final seatText = selectedSeats.isEmpty
        ? 'NONE'
        : selectedSeats.map((seat) => seat.seatCode).join(', ');

    return Container(
      padding: EdgeInsets.fromLTRB(14.h, 12.h, 14.h, 14.h),
      decoration: BoxDecoration(
        color: appTheme.screenBackground,
        border: Border(top: BorderSide(color: appTheme.bookRedBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SummaryValue(label: 'SELECTED SEATS', value: seatText),
              ),
              _SummaryValue(
                label: 'TOTAL AMOUNT',
                value: formatVnd(totalAmount),
                alignRight: true,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedSeats.isEmpty ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme.bookRedFill,
                disabledBackgroundColor: appTheme.gray_900_03,
                foregroundColor: appTheme.gray_300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.h),
                ),
                padding: EdgeInsets.symmetric(vertical: 13.h),
              ),
              child: Text(
                'CONFIRM SEATS',
                style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
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
          style: TextStyleHelper.instance.body14RegularBebasNeue.copyWith(
            color: alignRight ? appTheme.orange_100 : appTheme.gray_300,
            fontSize: 16.fSize,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class SeatSelectionHeader extends BookingFlowHeader {
  const SeatSelectionHeader({super.key}) : super(title: 'CINE BOOKING');
}

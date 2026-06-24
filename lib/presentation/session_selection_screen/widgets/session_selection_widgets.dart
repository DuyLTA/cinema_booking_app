import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/booking_flow_models.dart';
import '../../../widgets/custom_image_view.dart';

class BookingFlowHeader extends StatelessWidget {
  const BookingFlowHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54.h,
      padding: EdgeInsets.symmetric(horizontal: 14.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_01,
        border: Border(bottom: BorderSide(color: appTheme.color19A48B)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.arrow_back, color: appTheme.gray_300, size: 22.h),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyleHelper.instance.headline24RegularBebasNeue
                  .copyWith(
                    color: appTheme.orange_100,
                    fontSize: 22.fSize,
                    letterSpacing: 2.5,
                  ),
            ),
          ),
          SizedBox(width: 22.h),
        ],
      ),
    );
  }
}

class SessionMovieSummary extends StatelessWidget {
  const SessionMovieSummary({
    super.key,
    required this.title,
    required this.posterUrl,
    required this.genre,
    required this.ageRating,
  });

  final String title;
  final String posterUrl;
  final String genre;
  final String ageRating;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.h, 12.h, 14.h, 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.h),
            child: CustomImageView(
              imagePath: posterUrl,
              width: 68.h,
              height: 102.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 14.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyleHelper.instance.title20SemiBoldBodoniModa
                      .copyWith(
                        color: appTheme.amber_A400,
                        fontSize: 20.fSize,
                        height: 1.1,
                        letterSpacing: 0.5,
                      ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 6.h,
                  runSpacing: 6.h,
                  children: [
                    _MetaChip(label: '2D'),
                    if (genre.isNotEmpty) _MetaChip(label: genre),
                    if (ageRating.isNotEmpty) _MetaChip(label: ageRating),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.h, vertical: 3.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_03,
        borderRadius: BorderRadius.circular(4.h),
        border: Border.all(color: appTheme.color66A48B),
      ),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
          color: appTheme.gray_400,
        ),
      ),
    );
  }
}

class SessionDateSelector extends StatelessWidget {
  const SessionDateSelector({
    super.key,
    required this.dates,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<DateTime> dates;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return SizedBox(
      height: 58.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.h),
        itemCount: dates.length,
        separatorBuilder: (context, index) => SizedBox(width: 16.h),
        itemBuilder: (context, index) {
          final date = dates[index];
          final selected = selectedIndex == index;
          final label = index == 0 ? 'TODAY' : dayLabels[date.weekday - 1];

          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              width: 70.h,
              padding: EdgeInsets.symmetric(vertical: 7.h),
              decoration: BoxDecoration(
                color: selected ? appTheme.bookRedFill : appTheme.gray_900_03,
                borderRadius: BorderRadius.circular(8.h),
                border: Border.all(
                  color: selected
                      ? appTheme.bookRedBorder
                      : appTheme.color19A48B,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyleHelper.instance.label10RegularBebasNeue
                        .copyWith(color: appTheme.gray_300, letterSpacing: 0.4),
                  ),
                  Text(
                    '${_monthLabel(date.month)} ${date.day}',
                    style: TextStyleHelper.instance.body14RegularBebasNeue
                        .copyWith(color: appTheme.gray_300, fontSize: 16.fSize),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _monthLabel(int month) {
    const labels = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return labels[month - 1];
  }
}

class RegionSelector extends StatelessWidget {
  const RegionSelector({
    super.key,
    required this.regions,
    required this.selectedRegion,
    required this.onSelected,
  });

  final List<String> regions;
  final String selectedRegion;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.h, 22.h, 0, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECT REGION',
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              color: appTheme.gray_500,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: regions.map((region) {
                final selected = selectedRegion == region;
                return Padding(
                  padding: EdgeInsets.only(right: 8.h),
                  child: GestureDetector(
                    onTap: () => onSelected(region),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.h,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? appTheme.bookRedFill
                            : appTheme.gray_900_03,
                        borderRadius: BorderRadius.circular(18.h),
                        border: Border.all(
                          color: selected
                              ? appTheme.bookRedBorder
                              : appTheme.color19A48B,
                        ),
                      ),
                      child: Text(
                        region.toUpperCase(),
                        style: TextStyleHelper.instance.label10RegularBebasNeue
                            .copyWith(color: appTheme.gray_300),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class CinemaSessionCard extends StatelessWidget {
  const CinemaSessionCard({
    super.key,
    required this.cinemaName,
    required this.location,
    required this.sessions,
    required this.selectedSession,
    required this.expanded,
    required this.onSessionSelected,
  });

  final String cinemaName;
  final String location;
  final List<BookingSessionModel> sessions;
  final BookingSessionModel? selectedSession;
  final bool expanded;
  final ValueChanged<BookingSessionModel> onSessionSelected;

  @override
  Widget build(BuildContext context) {
    final groupedSessions = _groupSessionsByFormat(sessions);

    return Container(
      margin: EdgeInsets.fromLTRB(4.h, 0, 4.h, 14.h),
      padding: EdgeInsets.fromLTRB(14.h, 12.h, 14.h, expanded ? 14.h : 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [appTheme.gray_900_02, appTheme.gray_900_06],
        ),
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.color19A48B),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              BookingSessionModel? firstAvailableSession;
              for (final session in sessions) {
                if (!session.startTime.isBefore(DateTime.now())) {
                  firstAvailableSession = session;
                  break;
                }
              }

              if (firstAvailableSession != null) {
                onSessionSelected(firstAvailableSession);
              }
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    cinemaName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyleHelper.instance.title20SemiBoldBodoniModa
                        .copyWith(
                          color: expanded
                              ? appTheme.orange_100
                              : appTheme.gray_400,
                          fontSize: 18.fSize,
                          letterSpacing: 0.3,
                        ),
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: expanded ? appTheme.orange_100 : appTheme.gray_500,
                  size: 18.h,
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            _displayLocation(location),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
              color: appTheme.gray_500,
            ),
          ),
          if (expanded) ...[
            SizedBox(height: 16.h),
            ...groupedSessions.entries.map(
              (entry) => _SessionFormatGroup(
                label: _formatGroupLabel(entry.key),
                sessions: entry.value,
                selectedSession: selectedSession,
                onSessionSelected: onSessionSelected,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, List<BookingSessionModel>> _groupSessionsByFormat(
    List<BookingSessionModel> sessions,
  ) {
    final grouped = <String, List<BookingSessionModel>>{};
    for (final session in sessions) {
      grouped.putIfAbsent(session.format, () => []).add(session);
    }
    for (final value in grouped.values) {
      value.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
    return grouped;
  }

  String _formatGroupLabel(String format) {
    final upper = format.toUpperCase();
    if (upper.contains('IMAX')) return '$upper EXPERIENCE';
    return '$upper STANDARD';
  }

  String _displayLocation(String location) {
    final trimmed = location.trim();
    if (trimmed.isEmpty) return 'Ho Chi Minh City';
    if (trimmed.toLowerCase().contains('ho chi minh')) return trimmed;
    return '$trimmed, Ho Chi Minh City';
  }
}

class _SessionFormatGroup extends StatelessWidget {
  const _SessionFormatGroup({
    required this.label,
    required this.sessions,
    required this.selectedSession,
    required this.onSessionSelected,
  });

  final String label;
  final List<BookingSessionModel> sessions;
  final BookingSessionModel? selectedSession;
  final ValueChanged<BookingSessionModel> onSessionSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '| $label',
            style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
              color: appTheme.amber_A400,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 10.h,
            runSpacing: 10.h,
            children: sessions.map((session) {
              final selected = selectedSession?.id == session.id;
              final disabled = session.startTime.isBefore(DateTime.now());

              return GestureDetector(
                onTap: disabled ? null : () => onSessionSelected(session),
                child: Container(
                  width: 72.h,
                  height: 36.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? appTheme.amber_A400
                        : disabled
                        ? appTheme.gray_900_05
                        : appTheme.gray_900_03,
                    borderRadius: BorderRadius.circular(5.h),
                    border: Border.all(
                      color: selected
                          ? appTheme.orange_100
                          : appTheme.color19A48B,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: appTheme.amber_A400.withValues(alpha: 0.4),
                              blurRadius: 8.h,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    _formatTime(session.startTime),
                    style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
                      color: selected
                          ? appTheme.black_900
                          : disabled
                          ? appTheme.gray_500
                          : appTheme.gray_300,
                      fontSize: 11.fSize,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class SessionContinueBar extends StatelessWidget {
  const SessionContinueBar({
    super.key,
    required this.session,
    required this.onContinue,
  });

  final BookingSessionModel? session;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isSessionActive =
        session != null && !session!.startTime.isBefore(DateTime.now());

    return Container(
      margin: EdgeInsets.fromLTRB(4.h, 0, 4.h, 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 10.h),
      decoration: BoxDecoration(
        color: isSessionActive ? appTheme.bookRedFill : appTheme.gray_900_03,
        borderRadius: BorderRadius.circular(7.h),
        border: Border.all(
          color: isSessionActive
              ? appTheme.bookRedBorder
              : appTheme.color19A48B,
        ),
      ),
      child: GestureDetector(
        onTap: isSessionActive ? onContinue : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                !isSessionActive
                    ? 'SELECT AN AVAILABLE SESSION'
                    : '${session!.format.toUpperCase()} - ${_formatTime(session!.startTime)}\n${session!.cinemaName.toUpperCase()}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyleHelper.instance.label10RegularBebasNeue
                    .copyWith(color: appTheme.gray_300, letterSpacing: 1),
              ),
            ),
            Text(
              'CONTINUE TO SEATING',
              style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
                color: isSessionActive ? appTheme.gray_300 : appTheme.gray_500,
                letterSpacing: 1,
              ),
            ),
            SizedBox(width: 6.h),
            Icon(
              Icons.arrow_forward,
              size: 16.h,
              color: isSessionActive ? appTheme.gray_300 : appTheme.gray_500,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

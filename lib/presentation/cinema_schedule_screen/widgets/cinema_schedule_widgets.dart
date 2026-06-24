import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/booking_flow_models.dart';
import '../../../models/cinema_schedule_model.dart';

class CinemaScheduleDateStrip extends StatelessWidget {
  const CinemaScheduleDateStrip({
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
    if (dates.isEmpty) return const SizedBox.shrink();
    final selectedDate = dates[selectedIndex];

    return Container(
      color: appTheme.gray_900_01,
      padding: EdgeInsets.only(top: 14.h, bottom: 16.h),
      child: Column(
        children: [
          SizedBox(
            height: 74.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.h),
              itemCount: dates.length,
              separatorBuilder: (_, _) => SizedBox(width: 8.h),
              itemBuilder: (context, index) {
                final date = dates[index];
                final selected = index == selectedIndex;
                return InkWell(
                  onTap: () => onSelected(index),
                  borderRadius: BorderRadius.circular(24.h),
                  child: SizedBox(
                    width: 48.h,
                    child: Column(
                      children: [
                        Text(
                          index == 0 ? 'TODAY' : _weekday(date.weekday),
                          style: TextStyleHelper
                              .instance
                              .label10RegularBebasNeue
                              .copyWith(
                                color: selected
                                    ? appTheme.deep_orange_100
                                    : appTheme.gray_500,
                                letterSpacing: 0.6,
                              ),
                        ),
                        SizedBox(height: 7.h),
                        Container(
                          width: 42.h,
                          height: 42.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? appTheme.bookRedFill
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(color: appTheme.bookRedBorder)
                                : null,
                          ),
                          child: Text(
                            '${date.day}',
                            style: TextStyleHelper
                                .instance
                                .title20SemiBoldBodoniModa
                                .copyWith(
                                  color: selected
                                      ? appTheme.gray_300
                                      : appTheme.gray_400,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '${_weekdayLong(selectedDate.weekday)}, ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
              color: appTheme.gray_300,
            ),
          ),
        ],
      ),
    );
  }

  static String _weekday(int weekday) =>
      const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][weekday - 1];

  static String _weekdayLong(int weekday) => const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][weekday - 1];
}

class CinemaScheduleMovieCard extends StatelessWidget {
  const CinemaScheduleMovieCard({
    super.key,
    required this.schedule,
    required this.isAvailable,
    required this.onSessionTap,
  });

  final CinemaMovieScheduleModel schedule;
  final bool Function(BookingSessionModel session) isAvailable;
  final ValueChanged<BookingSessionModel> onSessionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.h, 16.h, 16.h, 18.h),
      decoration: BoxDecoration(
        color: appTheme.gray_900_02,
        border: Border(bottom: BorderSide(color: appTheme.color19A48B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  schedule.movie.title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyleHelper.instance.title20SemiBoldBodoniModa
                      .copyWith(color: appTheme.gray_300, fontSize: 18.fSize),
                ),
              ),
              if ((schedule.movie.ageRating ?? '').isNotEmpty)
                _AgeBadge(label: schedule.movie.ageRating!),
              SizedBox(width: 4.h),
              Icon(Icons.chevron_right, color: appTheme.gray_500, size: 24.h),
            ],
          ),
          SizedBox(height: 14.h),
          ...schedule.sessionsByFormat.entries.map(
            (entry) => _FormatSessions(
              format: entry.key,
              language: _languageLabel(),
              sessions: entry.value,
              isAvailable: isAvailable,
              onSessionTap: onSessionTap,
            ),
          ),
        ],
      ),
    );
  }

  String _languageLabel() {
    final language = schedule.movie.language?.trim() ?? '';
    final subtitle = schedule.movie.subtitle?.trim() ?? '';
    if (language.isNotEmpty && subtitle.isNotEmpty) {
      return '$language • $subtitle';
    }
    return language.isNotEmpty ? language : subtitle;
  }
}

class _FormatSessions extends StatelessWidget {
  const _FormatSessions({
    required this.format,
    required this.language,
    required this.sessions,
    required this.isAvailable,
    required this.onSessionTap,
  });

  final String format;
  final String language;
  final List<BookingSessionModel> sessions;
  final bool Function(BookingSessionModel session) isAvailable;
  final ValueChanged<BookingSessionModel> onSessionTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7.h,
                height: 7.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: appTheme.amber_A400, width: 2.h),
                ),
              ),
              SizedBox(width: 7.h),
              Expanded(
                child: Text(
                  [
                    format,
                    language,
                  ].where((value) => value.isNotEmpty).join('  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
                    color: appTheme.gray_300,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 9.h),
          Wrap(
            spacing: 9.h,
            runSpacing: 9.h,
            children: sessions.map((session) {
              final available = isAvailable(session);
              return InkWell(
                onTap: available ? () => onSessionTap(session) : null,
                borderRadius: BorderRadius.circular(5.h),
                child: Container(
                  width: 78.h,
                  height: 38.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: available
                        ? appTheme.gray_900_03
                        : appTheme.gray_900_01,
                    borderRadius: BorderRadius.circular(5.h),
                    border: Border.all(
                      color: available
                          ? appTheme.color33A48B
                          : appTheme.color19A48B,
                    ),
                  ),
                  child: Text(
                    _time(session.startTime),
                    style: TextStyleHelper.instance.body14RegularBebasNeue
                        .copyWith(
                          color: available
                              ? appTheme.gray_300
                              : appTheme.gray_500.withValues(alpha: 0.48),
                          letterSpacing: 0.8,
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

  String _time(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _AgeBadge extends StatelessWidget {
  const _AgeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.h, vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.h),
        border: Border.all(color: appTheme.deep_orange_100),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
          color: appTheme.deep_orange_100,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

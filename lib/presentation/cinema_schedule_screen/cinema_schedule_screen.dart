import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/booking_flow_models.dart';
import '../movie_list_screen/widgets/cinema_movie_header.dart';
import 'provider/cinema_schedule_provider.dart';
import 'widgets/cinema_schedule_widgets.dart';

class CinemaScheduleScreen extends StatelessWidget {
  const CinemaScheduleScreen({
    super.key,
    required this.cinemaId,
    required this.cinemaName,
  });

  final String cinemaId;
  final String cinemaName;

  static Widget builder(BuildContext context) {
    return fromRouteSettings(ModalRoute.of(context)?.settings);
  }

  static Widget fromRouteSettings(RouteSettings? routeSettings) {
    final args = routeSettings?.arguments as Map<String, dynamic>? ?? {};
    final cinemaId = args['cinemaId'] as String? ?? '';
    final cinemaName = args['cinemaName'] as String? ?? 'Cinema';

    return ChangeNotifierProvider(
      create: (_) => CinemaScheduleProvider(cinemaId: cinemaId)..loadSchedule(),
      child: CinemaScheduleScreen(cinemaId: cinemaId, cinemaName: cinemaName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      appBar: CinemaMovieHeader(
        cinemaName: cinemaName,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Consumer<CinemaScheduleProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              CinemaScheduleDateStrip(
                dates: provider.dates,
                selectedIndex: provider.selectedDateIndex,
                onSelected: provider.selectDate,
              ),
              Expanded(child: _buildSchedule(context, provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSchedule(BuildContext context, CinemaScheduleProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: appTheme.orange_100),
      );
    }

    if (provider.errorMessage != null) {
      return _ScheduleMessage(
        message: provider.errorMessage!,
        onRetry: provider.loadSchedule,
      );
    }

    final schedules = provider.schedules;
    if (schedules.isEmpty) {
      return const _ScheduleMessage(
        message: 'No sessions available for this date.',
      );
    }

    return ListView.builder(
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return CinemaScheduleMovieCard(
          schedule: schedule,
          isAvailable: provider.isSessionAvailable,
          onSessionTap: (session) =>
              _openSeatSelection(context, schedule.movie.title, session),
        );
      },
    );
  }

  void _openSeatSelection(
    BuildContext context,
    String movieTitle,
    BookingSessionModel session,
  ) {
    Navigator.of(context).pushNamed(
      AppRoutes.seatSelectionScreen,
      arguments: {'movieTitle': movieTitle, 'session': session},
    );
  }
}

class _ScheduleMessage extends StatelessWidget {
  const _ScheduleMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
                color: appTheme.gray_500,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 14.h),
              TextButton(onPressed: onRetry, child: const Text('TRY AGAIN')),
            ],
          ],
        ),
      ),
    );
  }
}

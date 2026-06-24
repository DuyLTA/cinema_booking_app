import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/booking_flow_models.dart';
import 'provider/session_selection_provider.dart';
import 'widgets/session_selection_widgets.dart';

class SessionSelectionScreen extends StatelessWidget {
  const SessionSelectionScreen({
    super.key,
    required this.movieId,
    required this.movieTitle,
    required this.posterUrl,
    required this.genre,
    required this.ageRating,
  });

  final String movieId;
  final String movieTitle;
  final String posterUrl;
  final String genre;
  final String ageRating;

  static Widget builder(BuildContext context) {
    return fromRouteSettings(ModalRoute.of(context)?.settings);
  }

  static Widget fromRouteSettings(RouteSettings? routeSettings) {
    final args = routeSettings?.arguments as Map<String, dynamic>? ?? {};
    final movieId = args['movieId'] as String? ?? '';

    return ChangeNotifierProvider(
      create: (context) => SessionSelectionProvider()..loadSessions(movieId),
      child: SessionSelectionScreen(
        movieId: movieId,
        movieTitle: args['movieTitle'] as String? ?? 'Movie',
        posterUrl:
            args['posterUrl'] as String? ?? ImageConstant.imgImageNotFound,
        genre: args['genre'] as String? ?? '',
        ageRating: args['ageRating'] as String? ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: SafeArea(
        child: Consumer<SessionSelectionProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                const BookingFlowHeader(title: 'CINE BOOKING'),
                Expanded(child: _buildBody(context, provider)),
                SessionContinueBar(
                  session: provider.selectedSession,
                  onContinue: () =>
                      _openSeatSelection(context, provider.selectedSession),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SessionSelectionProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(appTheme.orange_100),
        ),
      );
    }

    if (provider.errorMessage != null) {
      return _MessageState(message: provider.errorMessage!);
    }

    if (provider.sessions.isEmpty) {
      return const _MessageState(message: 'No sessions available.');
    }

    final grouped = provider.sessionsByCinema;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SessionMovieSummary(
            title: movieTitle,
            posterUrl: posterUrl,
            genre: genre,
            ageRating: ageRating,
          ),
          SessionDateSelector(
            dates: provider.dates,
            selectedIndex: provider.selectedDateIndex,
            onSelected: provider.selectDate,
          ),
          RegionSelector(
            regions: provider.regions,
            selectedRegion: provider.selectedRegion,
            onSelected: provider.selectRegion,
          ),
          if (grouped.isEmpty)
            const _MessageState(message: 'No sessions for this filter.')
          else
            ...grouped.entries.map(
              (entry) => CinemaSessionCard(
                cinemaName: entry.key,
                location: entry.value.first.cinemaLocation,
                sessions: entry.value,
                selectedSession: provider.selectedSession,
                expanded:
                    provider.selectedSession == null ||
                    entry.value.any(
                      (session) => session.id == provider.selectedSession!.id,
                    ),
                onSessionSelected: provider.selectSession,
              ),
            ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  void _openSeatSelection(BuildContext context, BookingSessionModel? session) {
    if (session == null) return;

    Navigator.of(context).pushNamed(
      AppRoutes.seatSelectionScreen,
      arguments: {
        'movieId': movieId,
        'movieTitle': movieTitle,
        'posterUrl': posterUrl,
        'genre': genre,
        'ageRating': ageRating,
        'session': session,
      },
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.h),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
            color: appTheme.gray_500,
          ),
        ),
      ),
    );
  }
}

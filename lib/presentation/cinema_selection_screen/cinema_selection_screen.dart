import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/cinema_entity_model.dart';
import 'provider/cinema_selection_provider.dart';
import 'widgets/cinema_selection_card.dart';

class CinemaSelectionScreen extends StatelessWidget {
  const CinemaSelectionScreen({super.key});

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CinemaSelectionProvider()..loadCinemas(),
      child: const CinemaSelectionScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      appBar: AppBar(
        backgroundColor: appTheme.gray_900_01,
        foregroundColor: appTheme.gray_300,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'SELECT CINEMA',
          style: TextStyleHelper.instance.headline24RegularBebasNeue.copyWith(
            color: appTheme.orange_100,
            fontSize: 22.fSize,
            letterSpacing: 2.5,
          ),
        ),
      ),
      body: Consumer<CinemaSelectionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: appTheme.orange_100),
            );
          }

          if (provider.errorMessage != null) {
            return _CinemaMessageState(
              message: provider.errorMessage!,
              actionLabel: 'TRY AGAIN',
              onAction: provider.loadCinemas,
            );
          }

          if (provider.cinemas.isEmpty) {
            return const _CinemaMessageState(
              message: 'No cinemas are available for booking.',
            );
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(16.h, 20.h, 16.h, 28.h),
            itemCount: provider.cinemas.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final cinema = provider.cinemas[index];
              return CinemaSelectionCard(
                cinema: cinema,
                onTap: () => _openCinemaMovies(context, cinema),
              );
            },
          );
        },
      ),
    );
  }

  void _openCinemaMovies(BuildContext context, CinemaEntityModel cinema) {
    Navigator.of(context).pushNamed(
      AppRoutes.cinemaScheduleScreen,
      arguments: {'cinemaId': cinema.id, 'cinemaName': cinema.name},
    );
  }
}

class _CinemaMessageState extends StatelessWidget {
  const _CinemaMessageState({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.theaters_outlined, color: appTheme.gray_500, size: 42.h),
            SizedBox(height: 14.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
                color: appTheme.gray_500,
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: 18.h),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

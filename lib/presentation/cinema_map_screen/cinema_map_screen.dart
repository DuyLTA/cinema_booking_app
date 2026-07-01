import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/cinema_entity_model.dart';
import '../../models/geo_position_model.dart';
import '../../services/location_service.dart';
import 'provider/cinema_map_provider.dart';
import 'widgets/cinema_map_widgets.dart';

class CinemaMapScreen extends StatefulWidget {
  const CinemaMapScreen({
    super.key,
    required this.cinema,
    required this.userPosition,
  });

  final CinemaEntityModel cinema;
  final GeoPositionModel userPosition;

  static Widget builder(BuildContext context) {
    return fromRouteSettings(ModalRoute.of(context)?.settings);
  }

  static Widget fromRouteSettings(RouteSettings? routeSettings) {
    final args = routeSettings?.arguments as Map<String, dynamic>? ?? {};
    final cinema = args['cinema'] as CinemaEntityModel?;
    final userPosition =
        args['userPosition'] as GeoPositionModel? ??
        LocationService.defaultUserPosition;

    if (cinema == null) {
      return const _InvalidCinemaMapState();
    }

    return ChangeNotifierProvider(
      create: (_) =>
          CinemaMapProvider(cinema: cinema, initialPosition: userPosition)
            ..loadRoute(),
      child: CinemaMapScreen(cinema: cinema, userPosition: userPosition),
    );
  }

  @override
  State<CinemaMapScreen> createState() => _CinemaMapScreenState();
}

class _CinemaMapScreenState extends State<CinemaMapScreen> {
  final GlobalKey<RouteGoogleMapState> _mapKey =
      GlobalKey<RouteGoogleMapState>();

  @override
  Widget build(BuildContext context) {
    final address = [
      widget.cinema.address,
      widget.cinema.location,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(', ');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      body: SafeArea(
        child: Consumer<CinemaMapProvider>(
          builder: (context, provider, _) {
            return Stack(
              children: [
                Positioned.fill(
                  child: CinemaMapCanvas(
                    mapKey: _mapKey,
                    userLatitude: provider.userPosition.latitude,
                    userLongitude: provider.userPosition.longitude,
                    hasUserLocation: provider.hasRealUserLocation,
                    cinemaLatitude: widget.cinema.latitude,
                    cinemaLongitude: widget.cinema.longitude,
                    routePoints: provider.route?.points ?? const [],
                  ),
                ),
                Positioned(
                  top: 12.h,
                  left: 12.h,
                  child: _MapIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.h,
                  child: _MapIconButton(
                    icon: Icons.share_outlined,
                    onPressed: () {},
                  ),
                ),
                Positioned(
                  right: 14.h,
                  top: 214.h,
                  child: Column(
                    children: [
                      _MapIconButton(
                        icon: Icons.my_location,
                        onPressed: () => _moveToMyLocation(provider),
                      ),
                      SizedBox(height: 12.h),
                      _MapIconButton(
                        icon: Icons.layers_outlined,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                if (provider.isLoadingRoute)
                  Positioned(
                    top: 62.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _RouteStatusChip(message: 'Finding route...'),
                    ),
                  ),
                DraggableScrollableSheet(
                  initialChildSize: 0.28,
                  minChildSize: 0.14,
                  maxChildSize: 0.52,
                  snap: true,
                  snapSizes: const [0.14, 0.28, 0.52],
                  builder: (context, scrollController) {
                    return CinemaMapBottomSheet(
                      controller: scrollController,
                      cinema: widget.cinema,
                      address: address,
                      distanceText: provider.distanceText,
                      durationText: provider.durationText,
                      routeMessage: provider.routeMessage,
                      onRefreshRoute: () => _moveToMyLocation(provider),
                      onViewMovies: () => _openSchedule(context),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openSchedule(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRoutes.cinemaScheduleScreen,
      arguments: {
        'cinemaId': widget.cinema.id,
        'cinemaName': widget.cinema.name,
      },
    );
  }

  Future<void> _moveToMyLocation(CinemaMapProvider provider) async {
    await provider.loadRoute();
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapKey.currentState?.moveToUserLocation();
    });
  }
}

class _MapIconButton extends StatelessWidget {
  const _MapIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 38.h,
          height: 38.h,
          child: Icon(icon, color: const Color(0xFF4E342E), size: 19.h),
        ),
      ),
    );
  }
}

class _RouteStatusChip extends StatelessWidget {
  const _RouteStatusChip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 12.h,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 8.h),
        child: Text(
          message,
          style: TextStyleHelper.instance.body12MediumDMSans.copyWith(
            color: const Color(0xFF4E342E),
          ),
        ),
      ),
    );
  }
}

class _InvalidCinemaMapState extends StatelessWidget {
  const _InvalidCinemaMapState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: Center(
        child: Text(
          'Cinema data is missing.',
          style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
            color: appTheme.gray_500,
          ),
        ),
      ),
    );
  }
}

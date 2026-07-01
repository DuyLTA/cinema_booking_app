import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/app_export.dart';
import '../../../models/cinema_entity_model.dart';

class CinemaMapCanvas extends StatelessWidget {
  const CinemaMapCanvas({
    super.key,
    required this.mapKey,
    required this.userLatitude,
    required this.userLongitude,
    required this.hasUserLocation,
    required this.cinemaLatitude,
    required this.cinemaLongitude,
    required this.routePoints,
  });

  final GlobalKey<RouteGoogleMapState> mapKey;
  final double userLatitude;
  final double userLongitude;
  final bool hasUserLocation;
  final double? cinemaLatitude;
  final double? cinemaLongitude;
  final List<LatLng> routePoints;

  @override
  Widget build(BuildContext context) {
    final userPoint = LatLng(userLatitude, userLongitude);
    final cinemaPoint = cinemaLatitude == null || cinemaLongitude == null
        ? null
        : LatLng(cinemaLatitude!, cinemaLongitude!);
    final cameraTarget = cinemaPoint == null
        ? userPoint
        : !hasUserLocation
        ? cinemaPoint
        : LatLng(
            (userPoint.latitude + cinemaPoint.latitude) / 2,
            (userPoint.longitude + cinemaPoint.longitude) / 2,
          );

    return RouteGoogleMap(
      key: mapKey,
      initialTarget: cameraTarget,
      userPoint: userPoint,
      cinemaPoint: cinemaPoint,
      hasUserLocation: hasUserLocation,
      routePoints: routePoints,
    );
  }
}

class RouteGoogleMap extends StatefulWidget {
  const RouteGoogleMap({
    super.key,
    required this.initialTarget,
    required this.userPoint,
    required this.cinemaPoint,
    required this.hasUserLocation,
    required this.routePoints,
  });

  final LatLng initialTarget;
  final LatLng userPoint;
  final LatLng? cinemaPoint;
  final bool hasUserLocation;
  final List<LatLng> routePoints;

  @override
  RouteGoogleMapState createState() => RouteGoogleMapState();
}

class RouteGoogleMapState extends State<RouteGoogleMap> {
  GoogleMapController? _controller;

  @override
  void didUpdateWidget(covariant RouteGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routePoints != widget.routePoints ||
        oldWidget.cinemaPoint != widget.cinemaPoint ||
        oldWidget.userPoint != widget.userPoint) {
      _fitCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) {
        _controller = controller;
        _fitCamera();
      },
      initialCameraPosition: CameraPosition(
        target: widget.initialTarget,
        zoom: 13.2,
      ),
      mapType: MapType.normal,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      markers: {
        if (widget.hasUserLocation)
          Marker(
            markerId: const MarkerId('user-location'),
            position: widget.userPoint,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRose,
            ),
            infoWindow: const InfoWindow(title: 'Your location'),
          ),
        if (widget.cinemaPoint != null)
          Marker(
            markerId: const MarkerId('cinema-location'),
            position: widget.cinemaPoint!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow,
            ),
            infoWindow: const InfoWindow(title: 'Cinema'),
          ),
      },
      polylines: {
        if (widget.routePoints.isNotEmpty)
          Polyline(
            polylineId: const PolylineId('route-to-cinema'),
            points: widget.routePoints,
            color: appTheme.bookRedBorder,
            width: 6,
          ),
        if (widget.routePoints.isEmpty &&
            widget.cinemaPoint != null &&
            widget.hasUserLocation)
          Polyline(
            polylineId: const PolylineId('user-to-cinema'),
            points: [widget.userPoint, widget.cinemaPoint!],
            color: appTheme.bookRedBorder.withValues(alpha: 0.45),
            width: 3,
          ),
      },
    );
  }

  Future<void> moveToUserLocation() async {
    final controller = _controller;
    if (controller == null || !widget.hasUserLocation) return;

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(widget.userPoint, 16),
    );
  }

  void _fitCamera() {
    final controller = _controller;
    if (controller == null) return;

    final points = widget.routePoints.isNotEmpty
        ? widget.routePoints
        : [
            if (widget.hasUserLocation) widget.userPoint,
            if (widget.cinemaPoint != null) widget.cinemaPoint!,
          ];

    if (points.isEmpty) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(widget.initialTarget, 14),
      );
      return;
    }
    if (points.length == 1) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(points.first, 14));
      return;
    }

    final bounds = _boundsFrom(points);
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 72));
  }

  LatLngBounds _boundsFrom(List<LatLng> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final point in points.skip(1)) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}

class CinemaMapBottomSheet extends StatelessWidget {
  const CinemaMapBottomSheet({
    super.key,
    required this.controller,
    required this.cinema,
    required this.address,
    required this.distanceText,
    required this.durationText,
    required this.routeMessage,
    required this.onRefreshRoute,
    required this.onViewMovies,
  });

  final ScrollController controller;
  final CinemaEntityModel cinema;
  final String address;
  final String distanceText;
  final String durationText;
  final String? routeMessage;
  final VoidCallback onRefreshRoute;
  final VoidCallback onViewMovies;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.h)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 22.h,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: controller,
        padding: EdgeInsets.fromLTRB(16.h, 10.h, 16.h, 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.h,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFD2C8C1),
                  borderRadius: BorderRadius.circular(6.h),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cinema.name.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyleHelper
                            .instance
                            .title20SemiBoldBodoniModa
                            .copyWith(
                              color: const Color(0xFF3B2F2A),
                              fontSize: 18.fSize,
                              height: 1.05,
                            ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        address.isEmpty ? 'Cinema location available' : address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyleHelper.instance.body12MediumDMSans
                            .copyWith(
                              color: const Color(0xFF7A6A62),
                              height: 1.25,
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      distanceText,
                      style: TextStyleHelper.instance.body14RegularBebasNeue
                          .copyWith(
                            color: appTheme.amber_A400,
                            fontSize: 18.fSize,
                            letterSpacing: 1,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      durationText,
                      style: TextStyleHelper.instance.label10RegularDMSans
                          .copyWith(color: const Color(0xFF7A6A62)),
                    ),
                  ],
                ),
              ],
            ),
            if (routeMessage != null) ...[
              SizedBox(height: 10.h),
              TextButton.icon(
                onPressed: onRefreshRoute,
                icon: Icon(Icons.my_location, size: 16.h),
                label: Text(routeMessage!),
                style: TextButton.styleFrom(
                  foregroundColor: appTheme.bookRedBorder,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _CinemaTag(
                    icon: Icons.confirmation_number_outlined,
                    label: '${cinema.totalScreens ?? 0} screens',
                  ),
                ),
                SizedBox(width: 8.h),
                Expanded(
                  child: _CinemaTag(
                    icon: Icons.schedule,
                    label: (cinema.workingHours ?? '').trim().isEmpty
                        ? 'Open daily'
                        : cinema.workingHours!,
                  ),
                ),
                SizedBox(width: 8.h),
                Expanded(
                  child: _CinemaTag(
                    icon: Icons.local_parking,
                    label: 'Free parking',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                SizedBox(
                  width: 64.h,
                  height: 48.h,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4E342E),
                      side: const BorderSide(color: Color(0xFFD7CCC8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.h),
                      ),
                    ),
                    child: Icon(Icons.near_me_outlined, size: 20.h),
                  ),
                ),
                SizedBox(width: 10.h),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onViewMovies,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appTheme.bookRedFill,
                      foregroundColor: appTheme.gray_300,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.h),
                      ),
                    ),
                    child: Text(
                      'VIEW AVAILABLE MOVIES',
                      style: TextStyleHelper.instance.body14RegularBebasNeue
                          .copyWith(letterSpacing: 1.2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CinemaTag extends StatelessWidget {
  const _CinemaTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26.h,
      padding: EdgeInsets.symmetric(horizontal: 7.h),
      decoration: BoxDecoration(
        color: appTheme.bookRedFill.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(4.h),
        border: Border.all(color: appTheme.bookRedBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: appTheme.gray_300, size: 12.h),
          SizedBox(width: 4.h),
          Flexible(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyleHelper.instance.label10RegularBebasNeue.copyWith(
                color: appTheme.gray_300,
                fontSize: 8.5.fSize,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

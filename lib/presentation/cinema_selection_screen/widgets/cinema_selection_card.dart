import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../models/cinema_entity_model.dart';

class CinemaSelectionCard extends StatelessWidget {
  const CinemaSelectionCard({
    super.key,
    required this.cinema,
    required this.onTap,
  });

  final CinemaEntityModel cinema;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final address = [
      cinema.location,
      cinema.address,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' • ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.h),
        child: Ink(
          padding: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
            color: appTheme.gray_900_02,
            borderRadius: BorderRadius.circular(8.h),
            border: Border.all(color: appTheme.color19A48B),
          ),
          child: Row(
            children: [
              Container(
                width: 48.h,
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appTheme.bookRedFill.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(6.h),
                  border: Border.all(color: appTheme.bookRedBorder),
                ),
                child: Icon(
                  Icons.theaters_outlined,
                  color: appTheme.orange_100,
                  size: 25.h,
                ),
              ),
              SizedBox(width: 14.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cinema.name.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyleHelper.instance.title18RegularBebasNeue
                          .copyWith(
                            color: appTheme.orange_100,
                            letterSpacing: 1,
                          ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      address.isEmpty
                          ? 'Cinema information available'
                          : address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyleHelper.instance.body12MediumDMSans
                          .copyWith(color: appTheme.gray_500, height: 1.3),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.h,
                      runSpacing: 5.h,
                      children: [
                        if ((cinema.totalScreens ?? 0) > 0)
                          _CinemaMeta(
                            icon: Icons.tv_outlined,
                            label: '${cinema.totalScreens} screens',
                          ),
                        if ((cinema.workingHours ?? '').trim().isNotEmpty)
                          _CinemaMeta(
                            icon: Icons.schedule,
                            label: cinema.workingHours!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.h),
              Icon(Icons.chevron_right, color: appTheme.gray_500, size: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _CinemaMeta extends StatelessWidget {
  const _CinemaMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: appTheme.gray_500, size: 13.h),
        SizedBox(width: 4.h),
        Text(
          label,
          style: TextStyleHelper.instance.label10RegularDMSans.copyWith(
            color: appTheme.gray_500,
          ),
        ),
      ],
    );
  }
}

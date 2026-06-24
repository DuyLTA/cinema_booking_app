import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/booked_ticket_model.dart';
import 'widgets/ticket_widgets.dart';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({super.key, required this.ticket});

  final BookedTicketModel ticket;

  static Widget builder(BuildContext context) {
    return fromRouteSettings(ModalRoute.of(context)?.settings);
  }

  static Widget fromRouteSettings(RouteSettings? routeSettings) {
    final args = routeSettings?.arguments as Map<String, dynamic>? ?? {};
    final ticket = args['ticket'];

    if (ticket is! BookedTicketModel) {
      return const _InvalidTicketDetailState();
    }

    return TicketDetailScreen(ticket: ticket);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            TicketDetailHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(14.h, 16.h, 14.h, 24.h),
                child: TicketDetailCard(ticket: ticket),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvalidTicketDetailState extends StatelessWidget {
  const _InvalidTicketDetailState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: Center(
        child: Text(
          'Ticket data is missing.',
          style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
            color: appTheme.gray_500,
          ),
        ),
      ),
    );
  }
}

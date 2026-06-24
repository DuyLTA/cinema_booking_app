import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/booked_ticket_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/custom_cine_marquee_app_bar.dart';
import '../cinema_home_screen/widgets/cine_home_drawer.dart';
import 'widgets/ticket_widgets.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  static Widget builder(BuildContext context) {
    return const TicketScreen();
  }

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  String? _loadedUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (_loadedUserId == userId) return;

    _loadedUserId = userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TicketProvider>().loadTickets(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      appBar: CustomCineMarqueeAppBar(
        titleText: 'MY TICKETS',
        onLeadingTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.profileScreen),
        onTicketTap: () {},
      ),
      endDrawer: const CineHomeDrawer(),
      body: Consumer<TicketProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(appTheme.orange_100),
              ),
            );
          }

          if (provider.errorMessage != null) {
            return TicketEmptyState(
              icon: Icons.error_outline,
              title: 'Tickets unavailable',
              message: 'We could not load your booked tickets right now.',
              actionLabel: 'TRY AGAIN',
              onAction: () => provider.loadTickets(_loadedUserId),
            );
          }

          if (provider.tickets.isEmpty) {
            return TicketEmptyState(
              icon: Icons.confirmation_number_outlined,
              title: 'No tickets yet',
              message: 'Booked tickets will appear here after payment success.',
              actionLabel: 'BOOK A MOVIE',
              onAction: () =>
                  Navigator.of(context).pushNamed(AppRoutes.movieListScreen),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(14.h, 16.h, 14.h, 24.h),
            itemCount: provider.tickets.length,
            itemBuilder: (context, index) {
              final ticket = provider.tickets[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: BookedTicketCard(
                  ticket: ticket,
                  onTap: () => _openTicketDetail(context, ticket),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openTicketDetail(BuildContext context, BookedTicketModel ticket) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.ticketDetailScreen, arguments: {'ticket': ticket});
  }
}

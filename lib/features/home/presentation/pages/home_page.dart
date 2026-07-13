import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ur_stylist/features/home/presentation/bloc/home_bloc.dart';
import 'package:ur_stylist/features/home/presentation/widgets/active_booking_card.dart';
import 'package:ur_stylist/features/home/presentation/widgets/awaiting_payment_card.dart';
import 'package:ur_stylist/features/home/presentation/widgets/booking_history_tile.dart';
import 'package:ur_stylist/features/home/presentation/widgets/pending_booking_card.dart';
import 'package:ur_stylist/features/home/presentation/widgets/today_summary_card.dart';
import 'package:ur_stylist/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:ur_stylist/features/wallet/presentation/widgets/deposit_banner.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(RefreshHomeData());
      },
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          final message = state.errorMessage ?? state.successMessage;
          if (message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.black,
                content: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },

        child: DefaultTabController(
          length: 4,
          child: SafeArea(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state.isLoading && state.bookings.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, walletState) {
                    final wallet = walletState.wallet;
                    final gated = wallet?.requiresDeposit == true;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Column(
                            children: [
                              gated
                                  ? DepositBanner(
                                      requiredAmount: wallet!.minimumDeposit,
                                      onTap: () => context
                                          .read<WalletBloc>()
                                          .add(const WalletRefreshed()),
                                    )
                                  : TodaySummaryCard(summary: state.summary),
                              const SizedBox(height: 12),
                              const TabBar(
                                labelColor: Colors.pink,
                                tabs: [
                                  Tab(text: 'Pending'),
                                  Tab(text: 'Active'),
                                  Tab(text: 'Awaiting Payment'),
                                  Tab(text: 'History'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: gated
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text(
                                      'Verify your security deposit to start accepting bookings.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : TabBarView(
                                  children: [
                                    _PendingList(state: state),
                                    _ActiveList(state: state),
                                    _AwaitingPaymentList(state: state),
                                    _HistoryList(state: state),
                                  ],
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingList extends StatelessWidget {
  final HomeState state;
  const _PendingList({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.pendingBookings.isEmpty) {
      return const Center(child: Text('No pending requests.'));
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(RefreshHomeData());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, index) =>
            PendingBookingCard(booking: state.pendingBookings[index]),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: state.pendingBookings.length,
      ),
    );
  }
}

class _ActiveList extends StatelessWidget {
  final HomeState state;
  const _ActiveList({required this.state});

  @override
  Widget build(BuildContext context) {
    final active = state.activeBookings;

    if (active.isEmpty) {
      return const Center(child: Text('No active booking right now.'));
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(RefreshHomeData());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final booking in active)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ActiveBookingCard(booking: booking),
            ),
        ],
      ),
    );
  }
}

class _AwaitingPaymentList extends StatelessWidget {
  final HomeState state;
  const _AwaitingPaymentList({required this.state});

  @override
  Widget build(BuildContext context) {
    final awaiting = state.awaitingPaymentBookings;

    if (awaiting.isEmpty) {
      return const Center(
        child: Text('No payment awaiting booking right now.'),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(RefreshHomeData());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final booking in awaiting)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AwaitingPaymentCard(booking: booking),
            ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final HomeState state;
  const _HistoryList({required this.state});

  @override
  Widget build(BuildContext context) {
    final filters = {
      'all': 'All',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
    };
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: filters.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: state.historyFilter == entry.key,
                  label: Text(entry.value),
                  onSelected: (_) => context.read<HomeBloc>().add(
                    HomeHistoryFilterChanged(entry.key),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(RefreshHomeData());
            },
            child: state.historyBookings.isEmpty
                ? const Center(child: Text('No booking history yet.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (_, index) => BookingHistoryTile(
                      booking: state.historyBookings[index],
                    ),
                    separatorBuilder: (_, __) => const Divider(),
                    itemCount: state.historyBookings.length,
                  ),
          ),
        ),
      ],
    );
  }
}

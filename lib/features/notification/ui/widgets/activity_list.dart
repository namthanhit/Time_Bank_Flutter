import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification_models.dart';
import 'async_states.dart';
import 'transaction_notification_card.dart';

class ActivityList extends StatelessWidget {
  const ActivityList({
    super.key,
    required this.state,
    required this.onRefresh,
  });

  final AsyncValue<List<AppNotification>> state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => const AsyncShimmerList(),
      error: (e, _) => AsyncErrorView(message: e.toString(), onRetry: onRefresh),
      data: (items) {
        if (items.isEmpty) {
          return const AsyncEmptyView(
            title: 'Chưa có biến động',
            subtitle: 'Khi có giao dịch mới, chúng sẽ xuất hiện tại đây.',
          );
        }
        return RefreshIndicator(
          onRefresh: onRefresh,
          color: Colors.white,
          backgroundColor: Colors.black54,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) {
              final n = items[i];
              return TransactionNotificationCard(
                date: n.dateText ?? '',
                account: n.account ?? '',
                change: n.change ?? '',
                balance: n.balance ?? '',
                note: n.note ?? '',
                time: n.timeText ?? '',
              );
            },
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification_models.dart';
import '../../providers/notification_providers.dart';
import 'async_states.dart';
import 'transaction_notification_card.dart';

class ActivityList extends ConsumerStatefulWidget {
  const ActivityList({
    super.key,
    required this.state,
    required this.onRefresh,
  });

  final AsyncValue<List<AppNotification>> state;
  final Future<void> Function() onRefresh;

  @override
  ConsumerState<ActivityList> createState() => _ActivityListState();
}

class _ActivityListState extends ConsumerState<ActivityList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Gọi loadMore khi cuộn gần đến cuối
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(activityNotificationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final onRefresh = widget.onRefresh;

    // ===== BƯỚC 1: Đưa RefreshIndicator ra ngoài làm cha =====
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Colors.white,
      backgroundColor: Colors.black54,
      child: state.when(
        // ===== TRẠNG THÁI LOADING =====
        loading: () => const AsyncShimmerList(), // ListView, đã scrollable

        // ===== TRẠNG THÁI LỖI =====
        error: (e, _) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Cho phép cuộn
          child: SizedBox(
            // Đặt chiều cao để căn giữa
            height: MediaQuery.of(context).size.height * 0.6,
            child: AsyncErrorView(
              message: e.toString(),
              onRetry: onRefresh, // Nút "Thử lại" gọi hàm onRefresh
            ),
          ),
        ),

        // ===== TRẠNG THÁI CÓ DATA =====
        data: (items) {
          if (items.isEmpty) {
            // ----- 1. Data nhưng rỗng -----
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Cho phép cuộn
              child: SizedBox(
                // Đặt chiều cao để căn giữa
                height: MediaQuery.of(context).size.height * 0.6,
                child: const AsyncEmptyView(
                  title: 'Chưa có biến động',
                  subtitle: 'Khi có giao dịch mới, chúng sẽ xuất hiện tại đây.',
                ),
              ),
            );
          }

          // ----- 2. Data có nội dung -----
          return ListView.separated(
            controller: _scrollController, // Gắn controller để tải thêm
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) {
              final notification = items[i];
              return TransactionNotificationCard(notification: notification);
            },
          );
        },
      ),
    );
  }
}
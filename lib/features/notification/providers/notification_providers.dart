import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notification/data/notification_repository.dart';
import '../../notification/domain/models/notification_models.dart';
import '../../auth/providers/auth_providers.dart';
/// Cung cấp repository cho notification
final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  // Dòng này bây BE GIỜ sẽ hoạt động vì 'authedApiClientProvider'
  // đã được import từ file auth chuẩn
  final api = ref.watch(authedApiClientProvider);
  return NotificationRepository(api);
});


/// StateNotifier cho danh sách "Biến động" (có pagination)
final activityNotificationsProvider =
StateNotifierProvider<ActivityNotifier, AsyncValue<List<AppNotification>>>(
      (ref) => ActivityNotifier(ref),
);

class ActivityNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  ActivityNotifier(this._ref) : super(const AsyncLoading()) {
    refresh();
  }
  final Ref _ref;
  bool _isLoadingMore = false;

  INotificationRepository get _repo =>
      _ref.read(notificationRepositoryProvider);

  Future<void> refresh() async {
    state = const AsyncLoading();
    _isLoadingMore = false;
    try {
      final list = await _repo.getActivity();
      state = AsyncData(list);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !state.hasValue) return;

    final currentList = state.value!;
    if (currentList.isEmpty) return;

    _isLoadingMore = true;
    final String cursor = currentList.last.id;

    try {
      final newList = await _repo.getActivity(cursor: cursor);
      if (newList.isNotEmpty) {
        state = AsyncData([...currentList, ...newList]);
      }
    } catch (e, st) {
      print('Failed to load more: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> markAllVisibleAsRead() async {
    final currentList = state.valueOrNull;
    if (currentList == null) return;

    final unreadIds = currentList
        .where((n) => !n.read)
        .map((n) => n.id)
        .toList();

    if (unreadIds.isEmpty) return;

    try {
      await _repo.markRead(unreadIds);

      final updatedList = currentList.map((n) {
        if (unreadIds.contains(n.id)) {
          // Giả sử bạn đã thêm copyWith vào AppNotification
          return n.copyWith(read: true);
        }
        return n;
      }).toList();

      state = AsyncData(updatedList);
    } catch (e, st) {
      print('Failed to mark read: $e');
    }
  }
  void upsertFromPush(AppNotification n) {
    // ===== SỬA LỖI: Thêm kiểu tường minh List<AppNotification> =====
    final List<AppNotification> cur = [...(state.value ?? [])];

    final i = cur.indexWhere((x) => x.id == n.id);

    // Cập nhật: Luôn đảm bảo item mới (hoặc được cập nhật) lên đầu danh sách
    if (i >= 0) {
      cur.removeAt(i); // Xóa ở vị trí cũ
    }
    cur.insert(0, n); // Chèn lên đầu

    state = AsyncData(cur); // Sẽ hết lỗi
  }
}
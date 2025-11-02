import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/home_repository.dart';
import '../data/mock_home_repository.dart';
// Use service mock as source for "my services" -> map to Activity
import '../../service/data/mock_service_repository.dart';
import '../../service/domain/models/service.dart' as svc;
import '../domain/models/home_models.dart';

// Swap ở đây khi có API thật:
// final homeRepoProvider = Provider<HomeRepository>((_) => HttpHomeRepository(dio));
final homeRepoProvider = Provider<HomeRepository>((_) => MockHomeRepository());

final homeSummaryProvider = FutureProvider<HomeSummary>((ref) async {
  final repo = ref.watch(homeRepoProvider);
  return repo.fetchSummary();
});

final activitiesProvider = FutureProvider<List<Activity>>((ref) async {
  final repo = ref.watch(homeRepoProvider);
  return repo.fetchActivities();
});

/// Activities dedicated for the "My" section (phần của tôi)
final myActivitiesProvider = FutureProvider<List<Activity>>((ref) async {
  // Fetch services owned by current user from service mock repository
  final List<svc.Service> services = await MockServiceRepository()
      .fetchServicesByUser(MockServiceRepository.currentUserId);

  // Map Service -> Activity
  String _formatTimeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 30) return '${diff.inDays} ngày trước';
    return '${diff.inDays ~/ 30} tháng trước';
  }

  List<Activity> mapServiceToActivity(List<svc.Service> list) {
    return list.map((s) {
      final created = s.createdAt;
      final taskTime =
          '${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')} ${created.day.toString().padLeft(2, '0')}/${created.month.toString().padLeft(2, '0')}/${created.year}';

      return Activity(
        user: s.providerName ?? MockServiceRepository.currentUserName,
        // use relative time like ServiceCard
        timeAgo: _formatTimeAgo(created),
        title: s.title,
        taskTime: taskTime,
        duration: MockServiceRepository.formatDuration(s.time),
        location: s.regionCode ?? s.place,
        tags: MockServiceRepository.getSkillNamesFromIds(s.skillIds),
        status: s.status,
        avatarUrl: s.providerAvatar,
      );
    }).toList();
  }

  return mapServiceToActivity(services);
});

/// Ẩn/hiện số dư
final balanceHiddenProvider = StateProvider<bool>((_) => false);

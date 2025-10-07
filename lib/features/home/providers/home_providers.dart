import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/home_repository.dart';
import '../data/mock_home_repository.dart';
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

/// Ẩn/hiện số dư
final balanceHiddenProvider = StateProvider<bool>((_) => false);

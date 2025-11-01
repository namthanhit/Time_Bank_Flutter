import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_profile_repository.dart';
import '../domain/profile.dart';
import '../domain/review.dart';
import '../../home/domain/models/home_models.dart';

final profileRepositoryProvider = Provider<MockProfileRepository>((ref) {
  return MockProfileRepository();
});

/// FutureProvider for the current user profile
final myProfileProvider = FutureProvider<Profile>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchMyProfile();
});

/// FutureProvider.family to fetch an arbitrary user's profile by id
final profileByIdProvider = FutureProvider.family<Profile, String>((ref, userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchProfileById(userId);
});

/// Reviews for a user (mock)
final reviewsProvider = FutureProvider.family<List<Review>, String>((ref, userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchReviews(userId);
});

/// Activities / services posted by a user (mock)
final activitiesProvider = FutureProvider.family<List<Activity>, String>((ref, userId) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchActivities(userId);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_settings_repository.dart';
import '../domain/user.dart';

final settingsRepositoryProvider = Provider((ref) => MockSettingsRepository());

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.loadProfile();
});

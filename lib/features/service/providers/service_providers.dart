// lib/features/service/providers/service_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/service.dart';
import '../domain/repositories/service_repository.dart';
import '../data/mock_service_repository.dart';

/// Provider gốc cho repository — có thể đổi sang HttpServiceRepository sau này
final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return MockServiceRepository();
});

/// Provider lấy danh sách dịch vụ public
final publicServicesProvider = FutureProvider<List<Service>>((ref) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.fetchPublicServices();
});

/// Provider lấy danh sách dịch vụ của một user (ví dụ: "Của tôi")
final servicesByUserProvider =
    FutureProvider.family<List<Service>, int>((ref, userId) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.fetchServicesByUser(userId);
});

/// Provider lấy 1 dịch vụ theo ID
final serviceByIdProvider =
    FutureProvider.family<Service?, int>((ref, id) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.fetchServiceById(id);
});

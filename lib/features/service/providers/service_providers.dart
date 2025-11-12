import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/api_service_repository.dart';
import '../domain/models/offer.dart';
import '../domain/models/pagination.dart';
import '../domain/models/service.dart';
import '../domain/repositories/service_repository.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final authedApi = ref.watch(authedApiClientProvider);
  return ApiServiceRepository(authedApi);
});

final myJobsProvider =
FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final repo = ref.watch(serviceRepositoryProvider);
  final pagingInfo = PaginationRequestDto(page: 1, pageSize: 10);
  return repo.getMyJobs(pagingInfo: pagingInfo);
});

/// Provider để lấy danh sách dịch vụ cộng đồng
final findJobCommunityProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final repo = ref.watch(serviceRepositoryProvider);
  final pagingInfo = PaginationRequestDto(page: 1, pageSize: 10);
  return repo.findJobCommunity(pagingInfo: pagingInfo);
});

/// Provider lấy 1 dịch vụ theo ID
final serviceByIdProvider =
FutureProvider.family<Service?, String>((ref, id) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.fetchServiceById(id);
});

/// Provider lấy chi tiết dịch vụ cộng đồng theo ID
final detailJobCommunityByIdProvider =
    FutureProvider.family<Service?, String>((ref, id) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.getdetaillJobCommunityById(id);
});

/// Provider trạng thái (AsyncValue<List<Offer>>)
final offerListProvider =
FutureProvider.family<List<Offer>, String>((ref, jobId) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.getOffersForMyJob(jobId);
});

final allMyPendingOffersProvider = FutureProvider<List<Offer>>((ref) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.fetchMyPendingOffers();
});

final updateOfferStatusAcceptedProvider = FutureProvider.family<void,
    ({String offerId, String jobId, String status})>((ref, params) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.updateOfferStatusAccepted(
    offerId: params.offerId,
    jobId: params.jobId,
    status: params.status,
  );
});

final updateOfferStatusRejectedProvider = FutureProvider.family<void,
    ({String offerId, String jobId, String status})>((ref, params) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.updateOfferStatusRejected(
    offerId: params.offerId,
    jobId: params.jobId,
    status: params.status,
  );
});
import 'package:time_bank_flutter/features/service/domain/models/offer.dart';

import '../models/pagination.dart';
import '../models/service.dart';

abstract class ServiceRepository {
  // Lấy danh sách dịch vụ đang public
  Future<List<Service>> fetchPublicServices();

  // Lấy danh sách dịch vụ của 1 user cụ thể (accepts int or String)
  Future<List<Service>> fetchServicesByUser(Object userId);

  // Lấy danh sách công việc của người dùng với phân trang và lọc
  Future<Map<String, dynamic>> getMyJobs({
    required PaginationRequestDto pagingInfo,
  });

  /// Lấy chi tiết dịch vụ theo ID (accepts int or String)
  Future<Service?> fetchServiceById(Object jobId);

  Future<List<Offer>> getOffersForMyJob(Object jobId);

  Future<List<Offer>> fetchMyPendingOffers();

  Future<void> updateOfferStatusAccepted({
    required String offerId,
    required String jobId,
    required String status,
  });

  Future<void> updateOfferStatusRejected({
    required String offerId,
    required String jobId,
    required String status,
  });
}

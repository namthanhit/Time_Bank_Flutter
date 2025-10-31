// lib/features/service/domain/repositories/service_repository.dart
import '../models/service.dart';

/// Lớp trừu tượng để lấy dữ liệu dịch vụ (mock hoặc từ API)
abstract class ServiceRepository {
  /// Lấy danh sách dịch vụ đang public
  Future<List<Service>> fetchPublicServices();

  /// Lấy chi tiết dịch vụ theo ID (accepts int or String)
  Future<Service?> fetchServiceById(Object id);

  /// Lấy danh sách dịch vụ của 1 user cụ thể (accepts int or String)
  Future<List<Service>> fetchServicesByUser(Object userId);
}

// lib/features/service/domain/repositories/service_repository.dart
import '../models/service.dart';

/// Lớp trừu tượng để lấy dữ liệu dịch vụ (mock hoặc từ API)
abstract class ServiceRepository {
  /// Lấy danh sách dịch vụ đang public
  Future<List<Service>> fetchPublicServices();

  /// Lấy chi tiết dịch vụ theo ID
  Future<Service?> fetchServiceById(int id);

  /// Lấy danh sách dịch vụ của 1 user cụ thể
  Future<List<Service>> fetchServicesByUser(int userId);
}

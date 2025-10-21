// lib/features/service/domain/models/service.dart
class Service {
  final int id;
  final int userId;
  final int skillId;
  final String title;
  final String? description;
  final String? regionCode;
  final int minSlotMinutes;
  final bool isPublic;
  final double ratingAvg;
  final int ratingCount;
  final DateTime createdAt;

  // Thông tin từ bảng users (nếu JOIN)
  final String? providerName;
  final String? providerAvatar;
  final String? providerSpecialization;

  // Ảnh minh họa dịch vụ
  final List<String>? serviceImages;

  // Status and priority information
  final String? status; // e.g., 'Mới', 'Cấp', 'Hoàn thành'
  final bool isUrgent;
  final bool isFeatured;

  const Service({
    required this.id,
    required this.userId,
    required this.skillId,
    required this.title,
    this.description,
    this.regionCode,
    required this.minSlotMinutes,
    required this.isPublic,
    required this.ratingAvg,
    required this.ratingCount,
    required this.createdAt,
    this.providerName,
    this.providerAvatar,
    this.providerSpecialization,
    this.serviceImages,
    this.status,
    this.isUrgent = false,
    this.isFeatured = false,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      skillId: json['skill_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      regionCode: json['region_code'] as String?,
      minSlotMinutes: json['min_slot_minutes'] as int,
      isPublic: json['visibility'] == 'public',
      ratingAvg: (json['rating_avg'] as num).toDouble(),
      ratingCount: json['rating_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      providerName: json['provider_name'] as String?,
      providerAvatar: json['provider_avatar'] as String?,
      providerSpecialization: json['provider_specialization'] as String?,
    );
  }
}

import 'package:time_bank_flutter/features/service/domain/repositories/service_repository.dart';
import '../domain/models/service.dart';
import 'package:flutter/material.dart';

class MockServiceRepository implements ServiceRepository {
  // Mock data cho applicants
  static final List<Map<String, dynamic>> mockApplicants = [
    {
      'id': 1,
      'name': 'Nguyễn Văn An',
      'specialization': 'Âm nhạc, Guitar, Sáng tác',
      'rating': 4.8,
      'requestType': 'receive', // receive hoặc cancel
      'requestTime': '09:15 15/10/2025',
      'status': 'pending',
      'statusText': 'Chờ duyệt',
      'statusColor': Colors.orange,
      'avatar': null,
    },
    {
      'id': 2,
      'name': 'Trần Thị Bình',
      'specialization': 'Công nghệ, Thiết kế, Marketing',
      'rating': 4.2,
      'requestType': 'cancel',
      'requestTime': '14:30 14/10/2025',
      'status': 'pending',
      'statusText': 'Chờ duyệt',
      'statusColor': Colors.orange,
      'avatar': null,
    },
    {
      'id': 3,
      'name': 'Lê Hoàng Cường',
      'specialization': 'Sức khỏe, Yoga, Thiền định',
      'rating': 4.5,
      'requestType': 'receive',
      'requestTime': '11:45 13/10/2025',
      'status': 'approved',
      'statusText': 'Duyệt',
      'statusColor': Colors.green,
      'avatar': null,
    },
    {
      'id': 4,
      'name': 'Phạm Thị Dung',
      'specialization': 'Ngôn ngữ, Dịch thuật',
      'rating': 4.9,
      'requestType': 'receive',
      'requestTime': '16:20 12/10/2025',
      'status': 'approved',
      'statusText': 'Duyệt',
      'statusColor': Colors.green,
      'avatar': null,
    },
    {
      'id': 5,
      'name': 'Võ Minh Hiếu',
      'specialization': 'Ẩm thực, Nấu ăn',
      'rating': 4.3,
      'requestType': 'cancel',
      'requestTime': '08:30 11/10/2025',
      'status': 'pending',
      'statusText': 'Chờ duyệt',
      'statusColor': Colors.orange,
      'avatar': null,
    },
  ];

  final List<Service> _mockData = [
    Service(
      id: 1,
      userId: 10,
      skillId: 1,
      title: 'Dạy guitar cơ bản',
      description: 'Học các hợp âm và kỹ thuật đệm hát trong 4 buổi.',
      regionCode: 'HNI',
      minSlotMinutes: 60,
      isPublic: true,
      ratingAvg: 4.8,
      ratingCount: 32,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      providerName: 'Nguyễn Hữu An',
      providerAvatar:
          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400',
      providerSpecialization: 'Âm nhạc, Guitar, Sáng tác',
      serviceImages: [
        'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500',
        'https://images.unsplash.com/photo-1564186763535-ebb21ef5277f?w=500',
        'https://hokaguitar.com/wp-content/uploads/2022/07/thu-tu-day-dan-guitar-1.jpg',
        'https://vietthuong.vn/upload/content/images/tuvan/guitar/not-danh-dan-guitar-co-ban-cho-nguoi-moi-04.jpg',
      ],
      status: 'Mới',
      isFeatured: true,
    ),
    Service(
      id: 2,
      userId: 11,
      skillId: 2,
      title: 'Sửa laptop cơ bản',
      description:
          'Dịch vụ sửa laptop cơ bản bao gồm các công việc như vệ sinh, làm sạch bụi bẩn trong máy, thay keo tản nhiệt giúp cải thiện hiệu suất làm mát, và kiểm tra tổng thể hệ thống phần cứng. '
          'Ngoài ra, tôi sẽ hỗ trợ cài đặt, tối ưu và khắc phục các lỗi phần mềm thường gặp như máy chạy chậm, lỗi driver, hoặc xung đột ứng dụng. '
          'Dịch vụ phù hợp cho sinh viên, nhân viên văn phòng, hoặc bất kỳ ai muốn bảo dưỡng định kỳ để laptop hoạt động mượt mà và ổn định hơn.',
      regionCode: 'HCM',
      minSlotMinutes: 90,
      isPublic: true,
      ratingAvg: 4.6,
      ratingCount: 21,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      providerName: 'Trần Văn Minh',
      providerAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      providerSpecialization: 'Công nghệ, Thiết kế, Marketing',
      serviceImages: [
        'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800',
        'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800',
      ],
      status: 'Cấp',
      isUrgent: true,
    ),
    Service(
      id: 3,
      userId: 12,
      skillId: 3,
      title: 'Hướng dẫn Yoga',
      description:
          'Dịch vụ hướng dẫn Yoga cơ bản dành cho người mới bắt đầu muốn rèn luyện sức khỏe, cải thiện sự dẻo dai và cân bằng tinh thần. '
          'Buổi học tập trung vào các tư thế nền tảng như hít thở đúng cách, giữ thăng bằng, và giãn cơ nhẹ nhàng, giúp cơ thể làm quen dần với nhịp tập. '
          'Ngoài ra, tôi sẽ hướng dẫn cách điều chỉnh tư thế phù hợp với từng thể trạng, kết hợp thư giãn và thiền ngắn để giảm căng thẳng sau giờ học hoặc làm việc. '
          'Bạn chỉ cần chuẩn bị thảm tập và tinh thần thoải mái – tôi sẽ đồng hành, giúp bạn xây dựng thói quen luyện tập an toàn, hiệu quả và bền vững.',
      regionCode: 'DN',
      minSlotMinutes: 45,
      isPublic: true,
      ratingAvg: 4.9,
      ratingCount: 58,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      providerName: 'Lê Thị Hồng',
      providerAvatar:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
      providerSpecialization: 'Sức khỏe, Yoga, Thiền định, Dinh dưỡng',
      serviceImages: [
        'https://suckhoedoisong.qltns.mediacdn.vn/324455921873985536/2022/9/28/tu-the-chien-binh-3-2-1664351573296410151956.jpg',
      ],
      status: 'Hoạt động',
    ),
    Service(
      id: 4,
      userId: 13,
      skillId: 4,
      title: 'Dịch thuật tiếng Anh',
      description: 'Dịch tài liệu kỹ thuật và văn bản chuyên ngành.',
      regionCode: 'HN',
      minSlotMinutes: 120,
      isPublic: true,
      ratingAvg: 4.7,
      ratingCount: 12,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      providerName: 'Pham Quang',
      providerAvatar:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      providerSpecialization: 'Ngôn ngữ',
      status: 'Mới',
    ),
    // Community-only mock
    Service(
      id: 5,
      userId: 14,
      skillId: 5,
      title: 'Lớp nấu ăn chay',
      description: 'Học các món chay cơ bản trong 3 buổi thực hành.',
      regionCode: 'HCM',
      minSlotMinutes: 90,
      isPublic: true,
      ratingAvg: 4.5,
      ratingCount: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      providerName: 'Ngô Thị Mai',
      providerAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      providerSpecialization: 'Ẩm thực',
      serviceImages: [
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=500',
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500',
      ],
      status: 'Mở',
    ),
    // My-service mock (belongs to userId 11)
    Service(
      id: 6,
      userId: 11,
      skillId: 6,
      title: 'Hỗ trợ CV tiếng Anh',
      description: 'Chỉnh sửa CV và luyện phỏng vấn tiếng Anh, 1:1.',
      regionCode: 'Toàn quốc',
      minSlotMinutes: 60,
      isPublic: false,
      ratingAvg: 4.4,
      ratingCount: 5,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      providerName: 'Trần Văn Minh',
      providerAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      providerSpecialization: 'Công nghệ, Thiết kế, Marketing',
      serviceImages: [
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=500',
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500',
      ],
      status: 'Riêng tư',
    ),
    Service(
      id: 7,
      userId: 11,
      skillId: 5,
      title: 'Hỗ trợ CV tiếng Anh',
      description: 'Chỉnh sửa CV và luyện phỏng vấn tiếng Anh, 1:1.',
      regionCode: 'Toàn quốc',
      minSlotMinutes: 60,
      isPublic: false,
      ratingAvg: 4.4,
      ratingCount: 5,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      providerName: 'Trần Văn Minh',
      providerAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      providerSpecialization: 'Công nghệ, Thiết kế, Marketing',
      status: 'Riêng tư',
    ),
  ];

  @override
  Future<List<Service>> fetchPublicServices() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockData.where((s) => s.isPublic).toList();
  }

  @override
  Future<Service?> fetchServiceById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockData.firstWhere((s) => s.id == id);
  }

  @override
  Future<List<Service>> fetchServicesByUser(int userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockData.where((s) => s.userId == userId).toList();
  }
}

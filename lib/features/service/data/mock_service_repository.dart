import 'package:time_bank_flutter/features/service/domain/repositories/service_repository.dart';
import '../domain/models/service.dart';
import 'package:flutter/material.dart';

class MockServiceRepository implements ServiceRepository {
  // Trạng thái ứng tuyển cho job (để sync giữa community và my service)
  static final Map<int, String> _applicationStatus = {
    // serviceId -> status: 'none', 'pending', 'approved', 'cancelled'
  };

  // Lưu trạng thái trước khi cancel để restore khi reject cancel request
  static final Map<int, String> _previousStatus = {};

  // Current user ID (người dùng hiện tại)
  static const int currentUserId = 11;

  // Listeners để notify khi có thay đổi
  static final List<VoidCallback> _changeListeners = [];

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
      'avatar':
          'https://anhavatardep.com/wp-content/uploads/2025/05/avatar-don-gian-1.jpg',
      'serviceId': 2, // link tới service
    },
    {
      'id': 2,
      'name': 'Trần Thị Bình',
      'specialization': 'Công nghệ, Thiết kế, Marketing',
      'rating': 4.2,
      'requestType': 'receive',
      'requestTime': '14:30 14/10/2025',
      'status': 'pending',
      'statusText': 'Chờ duyệt',
      'statusColor': Colors.orange,
      'avatar':
          'https://anhavatardep.com/wp-content/uploads/2025/05/avatar-don-gian-3.jpg',
      'serviceId': 8, // link tới job test (Photoshop)
    },
    {
      'id': 3,
      'name': 'Lê Hoàng Cường',
      'specialization': 'Sức khỏe, Yoga, Thiền định',
      'rating': 4.5,
      'requestType': 'receive',
      'requestTime': '11:45 13/10/2025',
      'status': 'pending',
      'statusText': 'Chờ duyệt',
      'statusColor': Colors.green,
      'avatar': 'https://betapto.edu.vn/upload/2025/08/avatar-con-tho-03.webp',
      'serviceId': 6, // link tới service
    },
    {
      'id': 4,
      'name': 'Phạm Thị Dung',
      'specialization': 'Ngôn ngữ, Dịch thuật',
      'rating': 4.9,
      'requestType': 'receive',
      'requestTime': '16:20 12/10/2025',
      'status': 'pending',
      'statusText': 'Chờ duyệt',
      'statusColor': Colors.green,
      'avatar':
          'https://anhavatardep.com/wp-content/uploads/2025/05/avatar-don-gian-2.jpg',
      'serviceId': 7, // link tới service
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
      'avatar':
          'https://cdn-media.sforum.vn/storage/app/media/thanhhuyen/h%C3%ACnh%20n%E1%BB%81n%20th%E1%BB%8F%20b%E1%BA%A3y%20m%C3%A0u/1.2/hinh-nen-tho-bay-mau-19.jpg',
      'serviceId': 6, // link tới service
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
      regionCode: 'Hai Duong',
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
      regionCode: 'Hai Duong',
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
    // Job test để sync giữa Community và My Service
    Service(
      id: 8,
      userId: 11, // Current user - sẽ hiện ở cả Community và My Service
      skillId: 7,
      title: 'Dạy Photoshop cơ bản',
      description:
          'Hướng dẫn sử dụng Photoshop từ cơ bản đến nâng cao cho người mới bắt đầu.',
      regionCode: 'HCM',
      minSlotMinutes: 120,
      isPublic: true, // Hiện ở Community
      ratingAvg: 4.6,
      ratingCount: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      providerName: 'Trần Văn Minh',
      providerAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      providerSpecialization: 'Công nghệ, Thiết kế, Marketing',
      serviceImages: [
        'https://images.unsplash.com/photo-1572044162444-ad60f128bdea?w=800',
      ],
      status: 'Mới',
      isFeatured: true,
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

  // Method để lấy service theo ID
  static Service? getServiceById(int serviceId) {
    final repository = MockServiceRepository();
    return repository._mockData.where((s) => s.id == serviceId).firstOrNull;
  }

  // Method chuyển đổi minSlotMinutes thành format HH:MM:SS
  static String formatDuration(int minSlotMinutes) {
    final int hours = minSlotMinutes ~/ 60;
    final int minutes = minSlotMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00';
  }

  // Methods để quản lý trạng thái ứng tuyển
  static String getApplicationStatus(int serviceId) {
    return _applicationStatus[serviceId] ?? 'none';
  }

  static void setApplicationStatus(int serviceId, String status) {
    _applicationStatus[serviceId] = status;
  }

  // Apply cho job (từ Community)
  static void applyForJob(int serviceId) {
    _applicationStatus[serviceId] = 'pending';

    // Thêm applicant mới vào mockApplicants
    final newApplicant = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': 'Trần Văn Minh', // Current user name
      'specialization': 'Công nghệ, Thiết kế, Marketing',
      'rating': 4.5,
      'requestType': 'receive',
      'requestTime':
          '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
      'status': 'pending',
      'statusText': 'Chờ duyệt',
      'statusColor': Colors.orange,
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      'serviceId': serviceId,
    };

    mockApplicants.add(newApplicant);

    // Notify all listeners
    _notifyListeners();
  }

  // Approve applicant (từ My Service)
  static void approveApplicant(int serviceId, Map<String, dynamic> applicant) {
    print('🎯 Approving applicant for serviceId: $serviceId'); // Debug
    print('📝 Applicant before update: ${applicant.toString()}');

    // Update applicant status
    applicant['status'] = 'approved';
    applicant['statusText'] = 'Đã duyệt';
    applicant['statusColor'] = Colors.green;

    print('📝 Applicant after update: ${applicant.toString()}');

    // Update application status
    _applicationStatus[serviceId] = 'approved';
    print(
        '✅ Set application status to approved for serviceId: $serviceId'); // Debug
    print('📊 Current _applicationStatus: $_applicationStatus'); // Debug

    // Debug: Check if applicant is still in mockApplicants list
    final foundApplicant = mockApplicants.firstWhere(
        (a) => a['serviceId'] == serviceId && a['name'] == applicant['name'],
        orElse: () => {});
    print('🔍 Found applicant in list: ${foundApplicant.isNotEmpty}');
    if (foundApplicant.isNotEmpty) {
      print('📋 Applicant in list status: ${foundApplicant['status']}');
    }

    // Notify all listeners
    _notifyListeners();
  }

  // Approve cancel request (từ My Service) - reset về trạng thái ban đầu
  static void approveCancelRequest(int serviceId) {
    print('✅ Approving cancel request for serviceId: $serviceId');

    // Reset application status về none (như chưa từng apply)
    _applicationStatus[serviceId] = 'none';

    // Remove applicant from list
    mockApplicants.removeWhere((applicant) =>
        applicant['serviceId'] == serviceId &&
        applicant['name'] == 'Trần Văn Minh');

    print('🔄 Reset application status to none and removed applicant');

    // Clear previous status
    _previousStatus.remove(serviceId);

    // Notify all listeners
    _notifyListeners();
  }

  // Reject cancel request (từ My Service) - giữ nguyên trạng thái trước đó
  static void rejectCancelRequest(int serviceId) {
    print('❌ Rejecting cancel request for serviceId: $serviceId');

    // Tìm applicant với requestType 'cancel'
    final applicantIndex = mockApplicants.indexWhere((applicant) =>
        applicant['serviceId'] == serviceId &&
        applicant['name'] == 'Trần Văn Minh' &&
        applicant['requestType'] == 'cancel');

    if (applicantIndex != -1) {
      final applicant = mockApplicants[applicantIndex];

      // Restore về trạng thái trước khi cancel
      final previousStatus = _previousStatus[serviceId] ?? 'pending';
      _applicationStatus[serviceId] = previousStatus;

      // QUAN TRỌNG: Thay vì xóa, chuyển applicant về receive request
      applicant['requestType'] = 'receive';
      applicant['requestTime'] =
          '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';

      // Set status dựa trên previousStatus
      if (previousStatus == 'pending') {
        applicant['status'] = 'pending';
        applicant['statusText'] = 'Chờ duyệt';
        applicant['statusColor'] = Colors.orange;
      } else if (previousStatus == 'approved') {
        applicant['status'] = 'approved';
        applicant['statusText'] = 'Đã duyệt';
        applicant['statusColor'] = Colors.green;
      }

      print('🔄 Converted cancel request back to receive request');
      print(
          '📝 Restored status: $previousStatus, requestType: ${applicant['requestType']}');

      // Clear previous status sau khi restore
      _previousStatus.remove(serviceId);
    } else {
      print('❌ No cancel request found to reject');
    }

    // Notify all listeners
    _notifyListeners();
  } // Cancel application (từ Community)

  static void cancelApplication(int serviceId) {
    print(
        '🗑️ MockServiceRepository.cancelApplication called for serviceId: $serviceId');

    // Lưu trạng thái hiện tại trước khi cancel
    final currentStatus = _applicationStatus[serviceId] ?? 'none';
    _previousStatus[serviceId] = currentStatus;
    print('💾 Saved previous status: $currentStatus');

    _applicationStatus[serviceId] = 'cancelled';

    // Thay vì xóa, chuyển applicant thành cancel request
    final applicantIndex = mockApplicants.indexWhere((applicant) =>
        applicant['serviceId'] == serviceId &&
        applicant['name'] == 'Trần Văn Minh');

    if (applicantIndex != -1) {
      final applicant = mockApplicants[applicantIndex];

      // Chuyển đổi thành cancel request
      applicant['requestType'] = 'cancel';
      applicant['requestTime'] =
          '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';
      applicant['status'] = 'pending'; // Vẫn pending để admin xử lý
      applicant['statusText'] = 'Chờ duyệt';
      applicant['statusColor'] = Colors.orange;

      print('🔄 Converted applicant to cancel request');
      print('📝 Updated requestType: ${applicant['requestType']}');
    } else {
      print('❌ No applicant found to convert to cancel request');
    }

    // Notify all listeners
    _notifyListeners();
  }

  // Methods để quản lý listeners
  static void addListener(VoidCallback listener) {
    _changeListeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _changeListeners.remove(listener);
  }

  static void _notifyListeners() {
    for (final listener in _changeListeners) {
      listener();
    }
  }

  // Reset application (từ My Service khi reject)
  static void resetApplication(int serviceId) {
    _applicationStatus[serviceId] = 'none';

    // Remove applicant from list
    mockApplicants.removeWhere((applicant) =>
        applicant['serviceId'] == serviceId &&
        applicant['name'] == 'Trần Văn Minh');

    // Notify all listeners
    _notifyListeners();
  }
}

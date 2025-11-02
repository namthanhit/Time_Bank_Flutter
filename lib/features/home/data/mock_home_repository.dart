import 'dart:async';
import 'home_repository.dart';
import '../domain/models/home_models.dart';

class MockHomeRepository implements HomeRepository {
  @override
  Future<HomeSummary> fetchSummary() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return HomeSummary(rating: 4.9, timeBalance: "22:45:30");
  }

  @override
  Future<List<Activity>> fetchActivities() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      Activity(
        user: 'nam',
        timeAgo: '5 phút trước',
        title: 'Rửa bát nấu cơm',
        taskTime: '11:30 06/09/2025',
        duration: '01:30:00',
        location: 'Yên Nghĩa - Hà Đông - Hà Nội',
        tags: ['Nội trợ', 'Việc nhà', 'Ưu tiên', 'Nhi nhi', 'Thảo Nhi'],
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        status: 'Đã nhận',
      ),
      Activity(
        user: 'nam',
        timeAgo: '15 phút trước',
        title: 'Rửa bát nấu cơm',
        taskTime: '11:30 06/09/2025',
        duration: '01:30:00',
        location: 'Yên Nghĩa - Hà Đông - Hà Nội',
        tags: ['Nội trợ', 'Việc nhà'],
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
        status: 'Đã nhận',
      ),
    ];
  }

  @override
  Future<List<Activity>> fetchMyActivities() async {
    // Mock activities specifically for "phần của tôi" (my section)
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      Activity(
        user: 'tôi',
        timeAgo: '2 phút trước',
        title: 'Giúp con học bài',
        taskTime: '18:00 02/11/2025',
        duration: '00:45:00',
        location: 'Nhà riêng',
        tags: ['Giáo dục', 'Gia đình'],
        avatarUrl:
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
        status: 'Đang thực hiện',
      ),
      Activity(
        user: 'tôi',
        timeAgo: '1 ngày trước',
        title: 'Tư vấn CV',
        taskTime: '10:00 01/11/2025',
        duration: '01:00:00',
        location: 'Trực tuyến',
        tags: ['Kỹ năng', 'Trực tuyến'],
        avatarUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
        status: 'Đã hoàn thành',
      ),
    ];
  }
}

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
        tag1: 'Nội trợ',
        tag2: 'Việc nhà',
        status: 'Đã nhận',
      ),
      Activity(
        user: 'nam',
        timeAgo: '15 phút trước',
        title: 'Rửa bát nấu cơm',
        taskTime: '11:30 06/09/2025',
        duration: '01:30:00',
        location: 'Yên Nghĩa - Hà Đông - Hà Nội',
        tag1: 'Nội trợ',
        tag2: 'Việc nhà',
        status: 'Đã nhận',
      ),
    ];
  }
}

import '../domain/profile.dart';
import '../domain/review.dart';
import '../../home/domain/models/home_models.dart';

class MockProfileRepository {
  /// Simulate fetching the current user's profile
  Future<Profile> fetchMyProfile() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return Profile(
      id: 'me',
      name: 'Lê Thành Ngu',
      avatarUrl: null,
      birthDate: DateTime(1990, 1, 1),
      gender: Gender.male,
      description: 'Thích ăn thịt chó, yêu thỏ nhưng thỏ không yêu',
      regionId: 'phutho',
      street: 'Đường A',
      workAddress: 'Phenikaa X',
      studyAddress: 'Phenikaa-Uni',
      socialNetwork: {
        'facebook': 'https://facebook.com/lethanhnam',
        'insta': 'https://instagram.com/lethanhnam',
        'linkin': 'HCM-Q1'
      },
      followers: 1000000,
      following: 100,
      points: 10,
    );
  }

  /// Simulate fetching another user's profile by id
  Future<Profile> fetchProfileById(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return Profile(
      id: id,
      name: 'Người dùng $id',
      avatarUrl: null,
      birthDate: null,
      gender: Gender.unknown,
      description: 'Mô tả tóm tắt',
      regionId: null,
      street: null,
      workAddress: null,
      studyAddress: null,
      socialNetwork: {'facebook': 'linkfb', 'insta': 'linkinsta'},
      followers: 120,
      following: 5,
      points: 3,
    );
  }

  /// Simulate fetching reviews for a user
  Future<List<Review>> fetchReviews(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mocked reviews for demo / UI
    return [
      Review(author: 'An', text: 'Rất nhiệt tình và chuyên nghiệp', rating: 5, date: DateTime(2025, 9, 10)),
      Review(author: 'Bình', text: 'Tốt, đúng giờ', rating: 4, date: DateTime(2025, 9, 12)),
      Review(author: 'Cô D', text: 'Ổn, nhưng nên cải thiện', rating: 3, date: DateTime(2025, 8, 1)),
      Review(author: 'Em E', text: 'Không hài lòng', rating: 2, date: DateTime(2025, 7, 21)),
      Review(author: 'Bạn G', text: 'Rất tệ', rating: 1, date: DateTime(2025, 6, 30)),
      Review(author: 'Khách H', text: 'Tuyệt vời, sẽ giới thiệu', rating: 5, date: DateTime(2025, 10, 3)),
      Review(author: 'Khách I', text: 'Ổn', rating: 4, date: DateTime(2025, 9, 20)),
    ];
  }

  /// Simulate fetching services/activities for a user (used by Profile -> Services)
  Future<List<Activity>> fetchActivities(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      const Activity(
        user: 'Lê Thành Ngu',
        timeAgo: '2 giờ trước',
        title: 'Rửa bát & Nấu cơm',
        taskTime: '11:30 06/09/2025',
        duration: '02:00',
        location: 'Yên Nghĩa - Hà Đông - Hà Nội',
        tags: ['Gia đình', 'Nhà bếp'],
        status: 'Hoạt động',
      ),
      const Activity(
        user: 'Lê Thành Ngu',
        timeAgo: '1 ngày trước',
        title: 'Trông trẻ buổi chiều',
        taskTime: '15:00 05/09/2025',
        duration: '03:00',
        location: 'Cầu Giấy - Hà Nội',
        tags: ['Chăm sóc', 'Trẻ em'],
        status: 'Đã nhận',
      ),
      const Activity(
        user: 'Lê Thành Ngu',
        timeAgo: '3 ngày trước',
        title: 'Dọn dẹp nhà cửa',
        taskTime: '09:00 03/09/2025',
        duration: '04:00',
        location: 'Hoàn Kiếm - Hà Nội',
        tags: ['Dọn dẹp'],
        status: 'Hoàn thành',
      ),
    ];
  }
}

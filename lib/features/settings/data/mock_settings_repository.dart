import '../domain/user.dart';

class MockSettingsRepository {
  Future<UserProfile> loadProfile() async {
    await Future.delayed(Duration(milliseconds: 200));
    return UserProfile(
      id: 'u1',
      name: 'Nguyễn Văn A',
      email: 'nguyenvana@email.com',
      avatarUrl: 'assets/images/avatar_placeholder.png',
    );
  }
}

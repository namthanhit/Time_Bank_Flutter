import 'auth_repository.dart';

class MockAuthRepository extends AuthRepository {
  MockAuthRepository() : super.forMock();

  @override
  Future<bool> loginPhone({required String phone, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return phone == '0123456789' && password == '12345678';
  }
}

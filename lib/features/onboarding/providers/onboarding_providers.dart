import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/network/api_client.dart';
import '../../../core/app_config.dart';
import '../../../core/network/auth_http_client.dart'; // nếu sau cần gọi API có Bearer
import '../data/onboarding_api.dart';
import '../data/onboarding_repository.dart';
import 'onboarding_state.dart';
import '../domain/models/models.dart';
import 'package:http/http.dart' as http;
import 'onboarding_controller.dart';


// Lấy AppConfig một chỗ
final appConfigProvider = Provider<AppConfig>((_) => AppConfig.fromEnv);

final baseHttpProvider = Provider<http.Client>((_) => http.Client());

// ApiClient KHÔNG auth cho onboarding (check-phone, skills, signup)
final publicApiClientProvider = Provider<ApiClient>((ref) {
  // dùng http.Client trần từ nơi bạn đã khai báo (nếu có)
  // nếu chưa có, có thể tạo tạm:
  // final baseHttp = http.Client();
  // return ApiClient(baseHttp, ref.read(appConfigProvider));
  // Nhưng theo setup trước, bạn đã có baseHttpProvider, tái dùng nó:
  final baseHttp = ref.read(baseHttpProvider); // nếu ở file khác, import vào
  return ApiClient(baseHttp, ref.read(appConfigProvider));
});

// OnboardingApi
final onboardingApiProvider = Provider<OnboardingApi>(
      (ref) => OnboardingApi(ref.read(publicApiClientProvider)),
);

// Repository
final onboardingRepoProvider = Provider<OnboardingRepository>(
      (ref) => OnboardingRepository(
    ref.read(onboardingApiProvider),
    FirebaseAuth.instance,
  ),
);

// Load skills từ backend (/skills)
final skillsProvider = FutureProvider<List<SkillDto>>((ref) {
  final api = ref.read(onboardingApiProvider);
  return api.fetchSkills();
});

// Controller
final onboardingControllerProvider =
StateNotifierProvider<OnboardingController, OnboardingState>(
      (ref) => OnboardingController(ref.read(onboardingRepoProvider)),
);

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';      // <-- dùng ApiClient chung
import '../domain/models/models.dart';

/// API client cho luồng Onboarding (không cần Bearer)
class OnboardingApi {
  OnboardingApi(this._api);
  final ApiClient _api;

  /// GET /auth/check-phone?phone=...
  Future<CheckPhoneResp> checkPhone(String phone) async {
    final res = await _api.get('/auth/check-phone', query: {'phone': phone});
    _ensureOK(res);
    final data = _decodeJson(res.body);
    return CheckPhoneResp(
      exists: data['exists'] == true,
      phoneToken: data['phone_token'] as String?,
    );
  }

  /// GET /skills -> lấy toàn bộ danh sách kỹ năng (đổ dropdown)
  Future<List<SkillDto>> fetchSkills() async {
    final res = await _api.get('/skills');
    _ensureOK(res);
    final json = _decodeJson(res.body);
    final list = (json['data'] as List).cast<Map<String, dynamic>>();
    return list.map((e) => SkillDto.fromJson(e)).toList();
  }

  /// POST /auth/signup/create
  /// Gửi phone_token + thông tin cá nhân + pin + password + skill_id
  Future<CreateUserResp> signupCreate({
    required String phoneToken,
    required PersonalDto personal,
    required String pin,
    required String password,
    required String skillId,
  }) async {
    final res = await _api.post('/auth/signup/create', body: {
      'phone_token': phoneToken,
      'personal': personal.toJson(),
      'pin': pin,
      'password': password,
      'skill_id': skillId,
    });
    _ensureOK(res);
    final data = _decodeJson(res.body);
    return CreateUserResp(
      ok: data['ok'] == true,
      userId: data['userId'] as String?,
    );
  }

  // ---- helpers ----
  void _ensureOK(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }

  Map<String, dynamic> _decodeJson(String source) {
    final raw = jsonDecode(source);
    if (raw is Map<String, dynamic>) return raw;
    throw const FormatException('Unexpected JSON shape');
  }
}






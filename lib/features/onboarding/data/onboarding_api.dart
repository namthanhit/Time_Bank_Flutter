import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/models/models.dart';

/// API client cho luồng Onboarding
class OnboardingApi {
  OnboardingApi(this.baseUrl, {http.Client? client})
      : _http = client ?? http.Client();

  final String baseUrl;
  final http.Client _http;

  /// GET /auth/check-phone?phone=...
  Future<CheckPhoneResp> checkPhone(String phone) async {
    final uri = Uri.parse('$baseUrl/auth/check-phone')
        .replace(queryParameters: {'phone': phone});
    final res = await _http.get(uri);
    final data = _decodeJson(res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return CheckPhoneResp(
        exists: data['exists'] == true,
        phoneToken: data['phone_token'] as String?,
      );
    }
    throw Exception('checkPhone failed: ${res.statusCode} ${res.body}');
  }

  /// GET /skills  -> lấy toàn bộ danh sách kỹ năng (để đổ dropdown)
  Future<List<SkillDto>> fetchSkills() async {
    final uri = Uri.parse('$baseUrl/skills');
    final res = await _http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('fetchSkills failed: ${res.statusCode} ${res.body}');
    }

    final json = _decodeJson(res.body);
    final list = (json['data'] as List).cast<Map<String, dynamic>>();
    return list.map((e) => SkillDto.fromJson(e)).toList();
  }

  /// POST /auth/signup/create
  /// Gửi phone_token + thông tin cá nhân + pin + password + skill_id (dropdown)
  Future<CreateUserResp> signupCreate({
    required String phoneToken,
    required PersonalDto personal,
    required String pin,
    required String password,
    required String skillId, // ✅ skill đã chọn từ dropdown
  }) async {
    final uri = Uri.parse('$baseUrl/auth/signup/create');
    final body = {
      'phone_token': phoneToken,
      'personal': personal.toJson(),
      'pin': pin,
      'password': password,
      'skill_id': skillId, // ✅ gửi lên backend để ghi vào UserSkill
    };

    final res = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = _decodeJson(res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return CreateUserResp(
        ok: data['ok'] == true,
        userId: data['userId'] as String?,
      );
    }
    throw Exception('signup/create failed: ${res.statusCode} ${res.body}');
  }

  Map<String, dynamic> _decodeJson(String source) {
    final raw = jsonDecode(source);
    if (raw is Map<String, dynamic>) return raw;
    throw const FormatException('Unexpected JSON shape');
  }
}

/// ================= Models =================

class CheckPhoneResp {
  final bool exists;
  final String? phoneToken;
  CheckPhoneResp({required this.exists, this.phoneToken});
}

class CreateUserResp {
  final bool ok;
  final String? userId;
  CreateUserResp({required this.ok, this.userId});
}

class PersonalDto {
  final String fullName;
  final String? citizenId;
  final String? email;
  final DateTime? birthDate;
  /// "male" | "female" | "other" | "unknown"
  final String? gender;
  final String? address;
  final String? specializationOrDescription;

  PersonalDto({
    required this.fullName,
    this.citizenId,
    this.email,
    this.birthDate,
    this.gender,
    this.address,
    this.specializationOrDescription,
  });

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'citizen_id': citizenId,
    'email': email,
    'birth_date': birthDate?.toIso8601String(),
    'gender': gender,
    'address': address,
    'specialization_or_description': specializationOrDescription,
  };
}

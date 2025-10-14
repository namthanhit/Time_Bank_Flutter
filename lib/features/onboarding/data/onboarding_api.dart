import 'dart:convert';
import 'package:http/http.dart' as http;

class OnboardingApi {
  OnboardingApi(this.baseUrl, {http.Client? client}) : _http = client ?? http.Client();
  final String baseUrl;
  final http.Client _http;

  Future<CheckPhoneResp> checkPhone(String phone) async {
    final uri = Uri.parse('$baseUrl/auth/check-phone').replace(queryParameters: {'phone': phone});
    final res = await _http.get(uri);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return CheckPhoneResp(
        exists: data['exists'] == true,
        phoneToken: data['phone_token'] as String?,
      );
    }
    throw Exception('checkPhone failed: ${res.statusCode} ${res.body}');
  }

  Future<CreateUserResp> signupCreate({
    required String phoneToken,
    required PersonalDto personal,
    required String pin,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/signup/create');
    final body = {
      'phone_token': phoneToken,
      'personal': personal.toJson(),
      'pin': pin,
      'password': password,
    };
    final res = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return CreateUserResp(ok: data['ok'] == true, userId: data['userId'] as String?);
    }
    throw Exception('signup/create failed: ${res.statusCode} ${res.body}');
  }
}

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
  final String? gender; // "male"|"female"|"other"|"unknown"
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

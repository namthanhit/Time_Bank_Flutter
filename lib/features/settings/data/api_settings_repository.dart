import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../domain/user.dart';

class ApiSettingsRepository {
  ApiSettingsRepository(this._api);

  final ApiClient _api;

  Future<UserProfile> loadProfile() async {
    try {
      final res = await _api.get('/users/me');
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Lỗi ${res.statusCode} khi tải profile: ${res.body}');
      }
      final data = jsonDecode(res.body);

      final Map<String, dynamic> userJson = (data is Map && data.containsKey('data'))
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;

      return UserProfile.fromJson(userJson);

    } catch (e) {
      debugPrint('ApiSettingsRepository Error: $e');
      rethrow;
    }
  }
}
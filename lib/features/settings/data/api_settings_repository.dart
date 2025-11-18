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

  /// Change user's password
  /// body: { current_password, new_password }
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      final res = await _api.post('/auth/change-password', body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Lỗi ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      debugPrint('ApiSettingsRepository.changePassword Error: $e');
      rethrow;
    }
  }

  /// Change user's PIN
  /// body: { current_pin, new_pin }
  Future<void> changePin({String? currentPin, required String newPin}) async {
    try {
      final body = <String, dynamic>{'new_pin': newPin};
      if (currentPin != null && currentPin.isNotEmpty) body['current_pin'] = currentPin;
      final res = await _api.post('/auth/change-pin', body: body);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        // Try to parse server-provided message/error
        try {
          final Map<String, dynamic> data = jsonDecode(res.body);
          if (data.containsKey('message')) {
            final m = data['message'];
            if (m is String) throw Exception(m);
            if (m is List && m.isNotEmpty) throw Exception(m.join(', '));
          }
          if (data.containsKey('error')) throw Exception(data['error'].toString());
          throw Exception('Lỗi ${res.statusCode}: ${res.body}');
        } catch (e) {
          throw Exception('Lỗi ${res.statusCode}: ${res.body}');
        }
      }
    } catch (e) {
      debugPrint('ApiSettingsRepository.changePin Error: $e');
      rethrow;
    }
  }

  /// Verify current PIN without changing it. Returns true if correct.
  Future<bool> verifyPin({required String currentPin}) async {
    try {
      final res = await _api.post('/auth/check-pin', body: {'current_pin': currentPin});
      if (res.statusCode >= 200 && res.statusCode < 300) return true;
      // try parse body for message
      try {
        final Map<String, dynamic> data = jsonDecode(res.body);
        if (data.containsKey('message')) {
          // message may be string or array
          final m = data['message'];
          if (m is String) throw Exception(m);
          if (m is List && m.isNotEmpty) throw Exception(m.join(', '));
        }
        if (data.containsKey('error')) throw Exception(data['error'].toString());
        throw Exception('Lỗi ${res.statusCode}: ${res.body}');
      } catch (e) {
        throw Exception('Lỗi ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      debugPrint('ApiSettingsRepository.verifyPin Error: $e');
      rethrow;
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/auth_api_client.dart';
import '../domain/models/notification_models.dart';

abstract class INotificationRepository {
  Future<List<AppNotification>> getActivity({String? cursor});
  Future<void> markRead(List<String> ids);
  Future<void> setFcmToken(String token);
}

class NotificationRepository implements INotificationRepository {
  NotificationRepository(this._api);
  final AuthApiClient _api;

  @override
  Future<List<AppNotification>> getActivity({String? cursor}) async {
    final http.Response res = await _api.get(
      '/notifications/activity',
      query: { if (cursor != null) 'cursor': cursor },
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load activity: ${res.statusCode}');
    }
    final List data = jsonDecode(res.body) as List;
    return data.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> markRead(List<String> ids) async {
    final http.Response res = await _api.patch('/notifications/mark-read', body: {'ids': ids});
    if (res.statusCode != 200) {
      throw Exception('Failed to mark read: ${res.statusCode}');
    }
  }

  @override
  Future<void> setFcmToken(String token) async {
    final http.Response res = await _api.patch('/notifications/fcm-token', body: {'token': token});
    if (res.statusCode != 200) {
      throw Exception('Failed to set fcm token: ${res.statusCode}');
    }
  }
}

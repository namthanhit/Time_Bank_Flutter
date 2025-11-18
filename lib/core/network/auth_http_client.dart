import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import '../../features/auth/data/auth_repository.dart';

/// Dùng client này cho các API cần auth.
/// Nó sẽ gắn header Authorization nếu có access token
/// và khi gặp 401 sẽ tự refresh + retry đúng 1 lần.
class AuthHttpClient extends http.BaseClient {
  AuthHttpClient(this._inner, this._repo, {required this.apiBase});
  final http.Client _inner;
  final AuthRepository _repo;
  final String apiBase;

  static bool _isAuthPath(Uri uri) {
    final p = uri.path;
    return p.contains('/auth/login') || p.contains('/auth/refresh') || p.contains('/auth/logout');
  }

  Future<String?> _deviceInfo() async {
    try {
      final info = await DeviceInfoPlugin().deviceInfo;
      return info.data['model']?.toString();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // gắn bearer nếu có
    final token = _repo.accessToken;
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    // debug: in ra URL và token rút gọn (chỉ dev)
    try {
      final short = token == null ? 'null' : (token.length > 8 ? '${token.substring(0, 6)}...' : token);
      print('[AuthHttpClient] Request ${request.method} ${request.url} Authorization=$short');
    } catch (_) {}
    // Read and buffer the request body so we can retry if needed.
    // We don't call `request` again after finalizing it; instead we create
    // new StreamedRequest instances for the initial send and possible retry.
    final bodyBytes = await request.finalize().toBytes();

    http.StreamedRequest _buildStreamed(String method, Uri url, Map<String, String> headers, List<int> bytes) {
      final r = http.StreamedRequest(method, url);
      r.headers.addAll(headers);
      if (bytes.isNotEmpty) {
        r.sink.add(bytes);
      }
      r.sink.close();
      return r;
    }

    final initial = _buildStreamed(request.method, request.url, Map<String, String>.from(request.headers), bodyBytes);
    final first = await _inner.send(initial);
    print('[AuthHttpClient] Response ${first.statusCode} for ${request.method} ${request.url}');
    if (first.statusCode != 401 || _isAuthPath(request.url)) {
      return first;
    }

    // 401: thử refresh
    final dev = await _deviceInfo();
    print('[AuthHttpClient] Got 401 for ${request.url}, attempting refresh...');
    final refreshData = await _repo.refreshIfPossible(deviceInfo: dev);
    if (refreshData == null) {
      print('[AuthHttpClient] Refresh failed or no refresh token available');
      return first; // fail: để UI xử lý (đẩy về login)
    }

    final newAccess = refreshData['access_token'] as String?;
    if (newAccess == null || newAccess.isEmpty) {
      print('[AuthHttpClient] Refresh succeeded but access_token missing');
      return first;
    }

    // retry 1 lần with same body and new Authorization header
    final headers = Map<String, String>.from(request.headers);
    headers['Authorization'] = 'Bearer $newAccess';
    try {
      final short2 = newAccess.length > 8 ? '${newAccess.substring(0,6)}...' : newAccess;
      print('[AuthHttpClient] Retry with new token $short2');
    } catch (_) {}
    final replay = _buildStreamed(request.method, request.url, headers, bodyBytes);
    return _inner.send(replay);
  }
}

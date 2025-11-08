import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_providers.dart';
import 'widgets/notification_header.dart';
import 'widgets/activity_list.dart';
// import 'widgets/general_list.dart'; // Tạm thời không dùng

import '../domain/models/notification_models.dart';
// ===== THÊM CÁC IMPORT NÀY CHO FCM =====
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});
  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  int _tabIndex = 0;
  void _switchTab(int i) {
    if (i == 1) return;
    setState(() => _tabIndex = i);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Tải dữ liệu
        final notifier = ref.read(activityNotificationsProvider.notifier);
        notifier.refresh();

        // ===== LỖI Ở ĐÂY: XÓA BỎ _setupMarkReadListener() =====
        // _setupMarkReadListener(); // <--- DÒNG NÀY GÂY LỖI

        // Khởi tạo FCM (Hàm này dùng ref.read, nên an toàn)
        _initializeFcm();
      }
    });
  }

  // ❌ XÓA HÀM NÀY, VÌ TA SẼ ĐƯA NÓ VÀO `build`
  // void _setupMarkReadListener() {
  //   ref.listen<AsyncValue<List<AppNotification>>>(...);
  // }

  // ===== CÁC HÀM FCM (Giữ nguyên) =====
  Future<void> _initializeFcm() async {
    // 1. Lấy token và gửi lên server
    await _sendTokenToServer();

    // 2. Lắng nghe nếu token thay đổi -> gửi lại
    FirebaseMessaging.instance.onTokenRefresh.listen(_sendTokenToServer);

    // 3. Lắng nghe thông báo khi app đang MỞ (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = _parseFcmMessage(message);
      if (notification != null) {
        ref.read(activityNotificationsProvider.notifier).upsertFromPush(notification);
      }
    });

    // 4. Lắng nghe khi user BẤM vào thông báo (mở app từ Terminated)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        // TODO: Điều hướng
      }
    });

    // 5. Lắng nghe khi user BẤM vào thông báo (mở app từ Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // TODO: Điều hướng
    });
  }

  Future<void> _sendTokenToServer([String? token]) async {
    final fcmToken = token ?? await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      try {
        await ref.read(notificationRepositoryProvider).setFcmToken(fcmToken);
        print('FCM Token updated: $fcmToken');
      } catch (e) {
        print('Failed to send FCM token: $e');
      }
    }
  }

  AppNotification? _parseFcmMessage(RemoteMessage message) {
    // ... (Giữ nguyên logic parse của bạn) ...
    try {
      final data = message.data;
      final notification = message.notification;
      if (notification == null) return null;
      final String typeString = data['subtype'] == 'IN' ? 'TRANSFER_IN' : 'TRANSFER_OUT';
      final Map<String, dynamic> notifData = {
        'transferId': data['transferId'],
        'secs': data['secs'],
        'createdAt': data['createdAt'],
      };
      return AppNotification(
        id: data['notificationId'] as String,
        title: notification.title ?? 'Thông báo',
        body: notification.body ?? '',
        type: _mapType(typeString),
        createdAt: DateTime.parse(data['createdAt'] as String),
        read: false,
        data: notifData,
      );
    } catch (e) {
      print('Failed to parse FCM message: $e');
      return null;
    }
  }

  NotificationType _mapType(String s) {
    // ... (Giữ nguyên logic _mapType) ...
    switch (s) {
      case 'TRANSFER_OUT': return NotificationType.transferOut;
      case 'TRANSFER_IN':  return NotificationType.transferIn;
      default:             return NotificationType.systemAlert;
    }
  }
  // ===== KẾT THÚC HÀM FCM =====


  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    // ===== SỬA LỖI: ĐẶT ref.listen VÀO ĐÂY =====
    ref.listen<AsyncValue<List<AppNotification>>>(activityNotificationsProvider, (previous, next) {
      // Khi state chuyển sang CÓ DỮ LIỆU
      // VÀ chúng ta đang ở tab "Hoạt động" (tabIndex == 0)
      if (next.hasValue && !next.isLoading && _tabIndex == 0) {
        ref.read(activityNotificationsProvider.notifier).markAllVisibleAsRead();
      }
    });
    // ==========================================

    final activity = ref.watch(activityNotificationsProvider);
    const general = AsyncValue<List<AppNotification>>.data([]); // State giả

    return Scaffold(
      // ... (Rest of your build method is correct) ...
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          SizedBox(height: top),
          NotificationHeader(current: _tabIndex, onChanged: _switchTab),
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _tabIndex == 0
                  ? ActivityList(
                key: const ValueKey('activity'),
                state: activity,
                onRefresh: () => ref.read(activityNotificationsProvider.notifier).refresh(),
              )
                  : Container(
                key: const ValueKey('general'),
                child: const Center(child: Text('Tab "Chung" chưa làm')),
              ),
            ),
          )
        ],
      ),
    );
  }
}
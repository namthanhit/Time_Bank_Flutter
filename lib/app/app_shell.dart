import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:time_bank_flutter/main.dart';
import 'package:time_bank_flutter/features/notification/domain/models/notification_models.dart';
import 'package:time_bank_flutter/features/notification/providers/notification_providers.dart';
import 'package:time_bank_flutter/features/service/ui/page/service_page.dart';
import '../features/home/ui/home_page.dart';
import 'navigation/bottom_nav_bar.dart';
import 'navigation/nav_item_data.dart';
import '../features/qr/ui/qr_scanner_page.dart';
import '../features/settings/ui/settings_page.dart';
import '../features/chat/ui/chat_list_page.dart';
import '../features/time_transfer/ui/transfer_page.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _brand = Color(0xFF003E77);
  int _currentPageIndex = 0;

  late final List<Widget> _pages = [
    const HomePage(),
    ServicePage(),
    const ChatListPage(),
    const SettingsPage(),
  ];

  static const List<NavItemData> _navItems = [
    NavItemData(icon: Icons.home_filled, label: 'Home'),
    NavItemData(icon: Icons.widgets_rounded, label: 'Services'),
    NavItemData(icon: Icons.qr_code_scanner_rounded, label: '', emphasize: true),
    NavItemData(icon: Icons.chat_rounded, label: 'Chat'),
    NavItemData(icon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeFcm();
      }
    });
  }

  Future<void> _initializeFcm() async {

    await _sendTokenToServer();

    FirebaseMessaging.instance.onTokenRefresh.listen(_sendTokenToServer);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground! (from AppShell)');
      if (!mounted) {
        print('FCM message received, but AppShell is disposed. Ignoring.');
        return;
      }

      final notification = _parseFcmMessage(message);

      if (notification != null) {
        ref.read(activityNotificationsProvider.notifier).upsertFromPush(notification);

        final String? title = message.notification?.title;
        final String? body = message.notification?.body;

        if (title != null && body != null) {
          final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            autoCancel: true,
          );
          final NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

          flutterLocalNotificationsPlugin.show(
            0,
            title,
            body,
            platformChannelSpecifics,
          );
        }
      }
    });
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state by message: ${message.data}');
        // TODO: Điều hướng đến trang thông báo
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background state by message: ${message.data}');
      // TODO: Điều hướng đến trang thông báo
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
    try {
      final data = message.data;
      final notification = message.notification;
      if (notification == null || data['notificationId'] == null || data['subtype'] == null) {
        return null;
      }
      final String typeString = data['subtype'] == 'IN' ? 'TRANSFER_IN' : 'TRANSFER_OUT';
      final DateTime createdAt = DateTime.parse(data['createdAt'] as String).toLocal();

      return AppNotification(
        id: data['notificationId'] as String,
        title: notification.title ?? 'Thông báo',
        body: notification.body ?? '',
        type: _mapType(typeString),
        createdAt: createdAt,
        read: false,
        data: data,
      );
    } catch (e) {
      print('Failed to parse FCM message: $e');
      return null;
    }
  }

  NotificationType _mapType(String s) {
    switch (s) {
      case 'TRANSFER_OUT': return NotificationType.transferOut;
      case 'TRANSFER_IN':  return NotificationType.transferIn;
      default:             return NotificationType.systemAlert;
    }
  }

  // ===== LOGIC UI (Giữ nguyên) =====
  int _navToPage(int i) => i > 2 ? i - 1 : i;
  int get _pageToNav => _currentPageIndex >= 2 ? _currentPageIndex + 1 : _currentPageIndex;

  void _onNavTap(int i) {
    final item = _navItems[i];
    if (item.emphasize) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (pageContext) => QrScannerPage(
            onScanSuccess: (scannedPhone) {
              Navigator.of(pageContext).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => TransferPage(
                    prefilledPhoneNumber: scannedPhone,
                  ),
                ),
              );
            },
          ),
          fullscreenDialog: true,
        ),
      );
      return;
    }
    final to = _navToPage(i);
    if (to != _currentPageIndex) setState(() => _currentPageIndex = to);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentPageIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: BottomNavBar(
          items: _navItems,
          currentIndexNav: _pageToNav,
          onTap: _onNavTap,
          brandColor: _brand,
        ),
      ),
      backgroundColor: Colors.white.withOpacity(1.0),
    );
  }
}
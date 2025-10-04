import 'package:flutter/material.dart';
import 'widgets/notification_item.dart';
import 'widgets/notification_header.dart';
import 'widgets/transaction_notification_card.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _tabIndex = 0;

  void _switchTab(int i) {
    if (_tabIndex != i) setState(() => _tabIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final top = media.padding.top;
    return Scaffold(
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
                  ? _buildActivityNotifications()
                  : _buildGeneralNotifications(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActivityNotifications() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TransactionNotificationCard(
            date: '22/09/2025',
            account: 'TK 00787xxx667',
            change: '-01H:00M',
            balance: '30M',
            note: 'Nam an cut cho',
            time: '18:20',
          ),
        );
      },
    );
  }

  Widget _buildGeneralNotifications() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: NotificationItem(
          title: 'Thông báo chung',
          message: 'Tin nhắn hệ thống mẫu số ${index + 1}.',
          time: '18:2${index}',
          leading: const Icon(Icons.notifications, color: Colors.orangeAccent),
          unread: index.isEven,
        ),
      ),
    );
  }
}



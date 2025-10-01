import 'package:flutter/material.dart';
import 'widgets/hero_section.dart';
import 'widgets/quick_actions.dart';
import 'widgets/activity_card.dart';
import '../../notification/ui/notification_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isHidden = false;
  final String _timeBalance = '20:45:30';
  final double _rating = 4.9;

  void _toggleHidden() => setState(() => _isHidden = !_isHidden);
  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(
              rating: _rating,
              timeBalance: _timeBalance,
              isHidden: _isHidden,
              onToggleHidden: _toggleHidden,
              onNotificationsTap: _openNotifications,
            ),
            const QuickActions(),
            _buildActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivities() {
    return Column(
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text('Hoạt Động', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Spacer(),
              Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.menu_rounded, size: 22, color: Colors.black87),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        ActivityCard(
          user: 'nam',
          time: '5 phút trước',
          title: 'Rửa bát nấu cơm',
          taskTime: '11:30 06/09/2025',
          duration: '01:30:00',
          location: 'Yên nghĩa - Hà Đông - Hà Nội',
          tag1: 'Nội trợ',
          tag2: 'Việc nhà',
          status: 'Đã nhận',
        ),
        ActivityCard(
          user: 'nam',
          time: '15 phút trước',
          title: 'Rửa bát nấu cơm',
          taskTime: '11:30 06/09/2025',
          duration: '01:30:00',
          location: 'Yên nghĩa - Hà Đông - Hà Nội',
          tag1: 'Nội trợ',
          tag2: 'Việc nhà',
          status: 'Đã nhận',
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'widgets/hero_section.dart';
import 'widgets/quick_actions.dart';
import 'widgets/activity_card.dart';
import 'home_typography.dart';
import 'widgets/shadow_separator.dart';
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
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero background remains separate so its color/gradient shows behind curved corners
          HeroSection(
            rating: _rating,
            timeBalance: _timeBalance,
            isHidden: _isHidden,
            onToggleHidden: _toggleHidden,
            onNotificationsTap: _openNotifications,
          ),
          // Overlapping container with rounded top corners
          Transform.translate(
            offset: const Offset(0, -26), // pull up to overlap hero slightly
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  const QuickActions(),
                  const ShadowSeparator(),
                  _buildActivities(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivities() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text('Hoạt Động', style: HomeTypography.activitiesTitle),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.menu_rounded, size: 22, color: Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const ActivityCard(
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
        const ActivityCard(
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

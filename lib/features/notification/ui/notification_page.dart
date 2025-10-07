import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_providers.dart';
import 'widgets/notification_header.dart';
import 'widgets/activity_list.dart';
import 'widgets/general_list.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});
  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  int _tabIndex = 0;
  void _switchTab(int i) => setState(() => _tabIndex = i);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final activity = ref.watch(activityNotificationsProvider);
    final general  = ref.watch(generalNotificationsProvider);

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
                  ? ActivityList(
                state: activity,
                onRefresh: () => ref.refresh(activityNotificationsProvider.future),
              )
                  : GeneralList(
                state: general,
                onRefresh: () => ref.refresh(generalNotificationsProvider.future),
              ),
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'widgets/community_service_detail_page.dart';
import 'widgets/my_service_detail_page.dart';

class ServiceDetailPage extends StatelessWidget {
  final int serviceId;
  final bool isMyService;

  const ServiceDetailPage({
    super.key,
    required this.serviceId,
    this.isMyService = false,
  });

  @override
  Widget build(BuildContext context) {
    // Router logic để chọn widget phù hợp
    if (isMyService) {
      return MyServiceDetailPage(serviceId: serviceId);
    } else {
      return CommunityServiceDetailPage(serviceId: serviceId);
    }
  }
}

import 'package:flutter/material.dart';
import '../../data/mock_service_repository.dart';
import 'pending_applicant_card.dart';

/// A simplified version of PendingApplicantsWidget that:
/// - hides the search bar and filter icon
/// - shows pending applicants (optionally across all jobs)
/// - uses the reusable PendingApplicantCard for each entry
class PendingApplicantsNoSearchWidget extends StatefulWidget {
  final String serviceId;
  final bool showAllJobs;

  const PendingApplicantsNoSearchWidget({
    super.key,
    required this.serviceId,
    this.showAllJobs = true,
  });

  @override
  State<PendingApplicantsNoSearchWidget> createState() =>
      _PendingApplicantsNoSearchWidgetState();
}

class _PendingApplicantsNoSearchWidgetState
    extends State<PendingApplicantsNoSearchWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    MockServiceRepository.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    MockServiceRepository.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicePendingApplicants = widget.showAllJobs
        ? MockServiceRepository.mockApplicants
            .where((a) => a['status'] == 'pending')
            .toList()
        : MockServiceRepository.mockApplicants
            .where((a) =>
                a['status'] == 'pending' &&
                a['serviceId'].toString() == widget.serviceId)
            .toList();

    if (servicePendingApplicants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/thong_bao.png'
                , width: 150, height: 150),
            SizedBox(height: 16),
            Text('Không có ứng viên nào đang chờ phê duyệt',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return Container(
      color: Colors.grey[200],
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: servicePendingApplicants.length,
        itemBuilder: (context, index) {
          final applicant = servicePendingApplicants[index];
          return PendingApplicantCard(applicant: applicant);
        },
      ),
    );
  }
}

// end of file

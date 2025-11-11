import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/buttom_icon/open_applicants.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/buttom_icon/pending_applicants_no_search_widget.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/buttom_icon/received_applicants.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/buttom_icon/service_cancelled.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/buttom_icon/service_completed.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/buttom_icon/service_in_progress.dart';
import '../../data/mock_service_repository.dart';

class FourServiceApplicantsPage extends StatefulWidget {
  final String serviceId;
  final String serviceTitle;
  final int initialTabIndex;

  const FourServiceApplicantsPage({
    super.key,
    required this.serviceId,
    required this.serviceTitle,
    this.initialTabIndex = 0,
  });

  @override
  State<FourServiceApplicantsPage> createState() =>
      _FourServiceApplicantsPageState();
}

class _FourServiceApplicantsPageState extends State<FourServiceApplicantsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'Chờ xác nhận',
    'Đã nhận',
    'Đã mở',
    'Đang thực hiện',
    'Hoàn thành',
    'Đã hủy',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Each tab will occupy 1/3 of the screen width so only 3 tabs are visible
    // at a time; the TabBar is scrollable to see the remaining tabs.
    final double tabWidth = MediaQuery.of(context).size.width / 3;
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔹 Tiêu đề cố định
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF003E77),
        elevation: 0,
        automaticallyImplyLeading: true,
        titleSpacing: 0, // 🔹 Giúp title sát lề trái hơn
        title: const Padding(
          padding: EdgeInsets.only(left: 8), // 🔹 Tiêu đề đang padding left 8
          child: Text(
            'Chi tiết yêu cầu',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),

        // 🔹 TabBar scrollable
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            // Align the tab bar with other page content (left padding 16)
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
            child: TabBar(
              isScrollable: true,
              controller: _tabController,
              dividerColor: Colors.transparent,

              // Use same visual style as ServiceApplicantsPage
              labelColor: const Color(0xFFE30000),
              unselectedLabelColor: const Color(0xFF003E77),
              indicator: UnderlineTabIndicator(
                borderSide:
                    const BorderSide(width: 5, color: Color(0xFFE30000)),
                borderRadius: BorderRadius.circular(4),
                insets: const EdgeInsets.only(bottom: 2),
              ),
              labelStyle: const TextStyle(
                fontSize: 16,
              ),
              labelPadding: const EdgeInsets.symmetric(
                vertical: 3,
              ),
              // Keep scrollable but keep each tab to fixed width so 3 visible
              tabs: _tabs
                  .map((t) => SizedBox(width: tabWidth, child: Tab(text: t)))
                  .toList(),
            ),
          ),
        ),
      ),

      // 🔹 Tab content (vuốt qua lại được)
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          if (tab == 'Chờ xác nhận') {
            return Padding(
              padding: const EdgeInsets.all(0),
              child: PendingApplicantsNoSearchWidget(
                serviceId: widget.serviceId,
                // Only show pending for this job (my job)
                //showAllJobs: false,
                // Only show applicants who applied to my jobs (not the
                // requests I sent to other jobs)
                showOnlyMyJobs: true,
              ),
            );
          }
          if (tab == 'Đã mở') {
            return Padding(
              padding: const EdgeInsets.all(0),
              child: OpenApplicantsWidget(showOnlyMyServices: true),
            );
          }
          if (tab == 'Đã nhận') {
            return Padding(
              padding: const EdgeInsets.all(0),
              child: ReceivedApplicants(
                showOnlyForCurrentUser: true,
                // onRefresh: () => setState(() {}), // <-- XÓA DÒNG NÀY
              ),
            );
          }
          ;
          if (tab == 'Đang thực hiện') {
            return Padding(
                padding: const EdgeInsets.all(0),
                child: ServiceInProgressWidget(showOnlyMyServices: true));
          }
          ;
          if (tab == 'Hoàn thành') {
            return Padding(
                padding: const EdgeInsets.all(0),
                child: ServiceCompletedWidget());
          }
          ;
          if (tab == 'Đã hủy') {
            return Padding(
                padding: const EdgeInsets.all(0),
                child: ServiceCancelledWidget(showOnlyMyServices: true));
          }
          ;
          // Default placeholder for other tabs
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Nội dung: $tab',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ApplicantDetailPage extends StatelessWidget {
  final Map<String, dynamic> applicant;

  const ApplicantDetailPage({super.key, required this.applicant});

  @override
  Widget build(BuildContext context) {
    final service =
        MockServiceRepository.getServiceById(applicant['serviceId']);
    final serviceName = service?.title ?? 'Chưa có thông tin';
    final duration = service != null
        ? MockServiceRepository.formatDuration(service.minSlotMinutes)
        : '00:00:00';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003E77),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Chi tiết ứng viên'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: const Color(0xFF003E77),
                  backgroundImage: applicant['avatar'] != null
                      ? NetworkImage(applicant['avatar'])
                      : null,
                  child: applicant['avatar'] == null
                      ? const Icon(Icons.person, color: Colors.white, size: 35)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF003E77),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Chuyên môn: ${applicant['specialization'] ?? ''}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < applicant['rating'].floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: const Color(0xFFE6E609),
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '${applicant['rating']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF003E77),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('Tên dịch vụ:', serviceName),
                    const SizedBox(height: 8),
                    _infoRow('Thời lượng dịch vụ:', duration),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      MockServiceRepository.approveApplicant(
                          applicant['serviceId'], applicant);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.person_add_alt_outlined,
                        size: 20, color: Colors.white),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    label: const Text('Duyệt yêu cầu'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      MockServiceRepository.resetApplication(
                          applicant['serviceId']);
                      Navigator.of(context).pop();
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Từ chối'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 145,
          child: Text(label,
              style: const TextStyle(fontSize: 16, color: Color(0xFF003E77))),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF003E77),
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

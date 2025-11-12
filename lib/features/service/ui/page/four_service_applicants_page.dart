import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/buttom_icon/open_applicants.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/buttom_icon/pending_applicants_no_search_widget.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/buttom_icon/received_applicants.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/buttom_icon/service_cancelled.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/buttom_icon/service_completed.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/buttom_icon/service_in_progress.dart';

class FourServiceApplicantsPage extends StatefulWidget {
  final String? serviceId;
  final String serviceTitle;
  final int initialTabIndex;

  const FourServiceApplicantsPage({
    super.key,
     this.serviceId,
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
    final double tabWidth = MediaQuery.of(context).size.width / 3;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF003E77),
        elevation: 0,
        automaticallyImplyLeading: true,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'Chi tiết yêu cầu',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
            child: TabBar(
              isScrollable: true,
              controller: _tabController,
              dividerColor: Colors.transparent,
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
              tabs: _tabs
                  .map((t) => SizedBox(width: tabWidth, child: Tab(text: t)))
                  .toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          if (tab == 'Chờ xác nhận') {
            return const Padding(
              padding: EdgeInsets.all(0),
              child: PendingApplicantsNoSearchWidget(),
            );
          }
          if (tab == 'Đã mở') {
            return const Padding(
              padding: EdgeInsets.all(0),
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
            return const Padding(
                padding: EdgeInsets.all(0),
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
            return const Padding(
                padding: EdgeInsets.all(0),
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
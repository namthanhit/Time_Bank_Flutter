import 'package:flutter/material.dart';
import 'widgets/service_list_container.dart';
import 'widgets/community_header.dart';
import 'search_page.dart';
import 'widgets/service_create_page.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  String _query = '';
  String? _communityFilter;
  String? _myFilter;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF003E77),
          elevation: 0,
          title: const Text(
            'Dịch vụ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.search,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ServiceCreatePage(),
              ),
            );
          },
          backgroundColor: const Color(0xFF003E77),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
        body: Column(
          children: [
            // Tab Bar
            Container(
              height: 40,
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: const Color(0xFF003E77),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(
                    child: Text(
                      'Cộng đồng',
                      style: TextStyle(
                        fontSize: 18,
                        //fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Của tôi',
                      style: TextStyle(
                        fontSize: 18,
                        //fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  // Tab Cộng đồng
                  Column(
                    children: [
                      CommunityHeader(
                        isMyTab: false,
                        onFilterChanged: (f) =>
                            setState(() => _communityFilter = f),
                        onSearchChanged: (searchText) =>
                            setState(() => _query = searchText),
                      ),
                      Expanded(
                        child: ServiceListContainer(
                          query: _query,
                          filter: null,
                          socialFilter: _communityFilter,
                        ),
                      ),
                    ],
                  ),
                  // Tab Của tôi
                  Column(
                    children: [
                      CommunityHeader(
                        isMyTab: true,
                        onFilterChanged: (f) => setState(() => _myFilter = f),
                        onSearchChanged: (searchText) =>
                            setState(() => _query = searchText),
                      ),
                      Expanded(
                        child: ServiceListContainer(
                          query: _query,
                          filter: null,
                          socialFilter: _myFilter,
                          userId: '11', // ID của user hiện tại (string)
                          isMyServiceTab: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

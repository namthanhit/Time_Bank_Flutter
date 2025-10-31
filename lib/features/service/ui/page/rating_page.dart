import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/buttom_icon/already_rated.dart';
import 'package:time_bank_flutter/features/service/ui/widgets/rating/not_rated_yet.dart';

// 🔹 Trang quản lý đánh giá với 2 tab
class ServiceRatingPage extends StatefulWidget {
  final int initialTabIndex;

  const ServiceRatingPage({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<ServiceRatingPage> createState() => _ServiceRatingPageState();
}

class _ServiceRatingPageState extends State<ServiceRatingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // In-memory list of submitted reviews. Each review is a Map with keys
  // 'applicant', 'rating', 'comment', 'imagePaths', 'reviewTime'.
  final List<Map<String, dynamic>> _reviews = [];

  void _handleNewReview(Map<String, dynamic> review) {
    setState(() {
      _reviews.insert(0, review);
      // After submission, only insert the review. Do not change tabs
      // automatically — the user requested to stay on the rating page.
    });
  }

  final List<String> _tabs = [
    'Chưa đánh giá',
    'Đã đánh giá',
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
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔹 Tiêu đề cố định
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF003E77),
        elevation: 0,
        automaticallyImplyLeading: true,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'Chi tiết đánh giá',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),

        // 🔹 TabBar 2 tab
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
            child: TabBar(
              isScrollable: false, // 🔹 Không cần cuộn
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
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
        ),
      ),

      // 🔹 Tab content (Nơi bạn gọi widget của mình)
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Chưa đánh giá — pass callback so submitted reviews are
          // registered here.
          NotRatedYetWidget(onReviewSubmitted: _handleNewReview),

          // 2. Đã đánh giá — show the list of submitted reviews.
          _buildRatedList(),
        ],
      ),
    );
  }

  Widget _buildRatedList() {
    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.reviews, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text('Chưa có đánh giá nào', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    // Lightweight list: tapping an item opens the full `AlreadyRatedPage`.
    return Container(
      color: Colors.grey[100],
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _reviews.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final r = _reviews[index];
          final applicant = r['applicant'] as Map<String, dynamic>;
          final rating = (r['rating'] as num).toDouble();
          final comment = r['comment'] as String? ?? '';
          final images =
              (r['imagePaths'] as List<dynamic>?)?.cast<String>() ?? [];
          final reviewTime = r['reviewTime'] as DateTime? ?? DateTime.now();

          // Render the full card inline using the reusable widget so we
          // don't need to push a separate page.
          return AlreadyRatedWidget(
            applicant: applicant,
            rating: rating,
            comment: comment,
            imagePaths: images,
            reviewerId: r['reviewerId'] as String?,
            reviewTime: reviewTime,
            onEdit: (updated) {
              // Replace the review in-place if edited via RatingServicePage.
              setState(() {
                _reviews[index] = updated;
              });
            },
            onDelete: () {
              setState(() {
                _reviews.removeAt(index);
              });
            },
          );
        },
      ),
    );
  }
}

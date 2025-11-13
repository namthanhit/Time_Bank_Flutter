import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/review.dart';
import '../../providers/providers.dart';

class ReviewsList extends ConsumerStatefulWidget {
  /// userId: which user's reviews to show (default 'me')
  final String userId;
  const ReviewsList({Key? key, this.userId = 'me'}) : super(key: key);

  @override
  ConsumerState<ReviewsList> createState() => _ReviewsListState();
}

class _ReviewsListState extends ConsumerState<ReviewsList> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Review> _filteredForTab(List<Review> all, int tabIndex) {
    if (tabIndex == 0) {
      final copy = List<Review>.from(all);
      copy.sort((a, b) {
        final r = b.rating.compareTo(a.rating);
        if (r != 0) return r;
        return b.date.compareTo(a.date);
      });
      return copy;
    }
    final rating = 6 - tabIndex; // 1->5 mapping
    final items = all.where((r) => r.rating == rating).toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  int _countForRating(List<Review> all, int rating) => all.where((r) => r.rating == rating).length;

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(reviewsProvider(widget.userId));
    return reviewsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Center(child: Text('Lỗi khi tải đánh giá')),
      data: (all) {
        final total = all.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Đánh giá', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.black54,
              tabs: [
                Tab(text: 'Tất cả ($total)'),
                Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text('5 (${_countForRating(all, 5)})'),
                  ]),
                ),
                Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text('4 (${_countForRating(all, 4)})'),
                  ]),
                ),
                Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text('3 (${_countForRating(all, 3)})'),
                  ]),
                ),
                Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text('2 (${_countForRating(all, 2)})'),
                  ]),
                ),
                Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text('1 (${_countForRating(all, 1)})'),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: TabBarView(
                controller: _tabController,
                children: List.generate(6, (index) {
                  final items = _filteredForTab(all, index);
                  if (items.isEmpty) return const Center(child: Text('Chưa có đánh giá'));
                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final r = items[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(r.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Row(children: List.generate(5, (idx) => Icon(idx < r.rating ? Icons.star : Icons.star_border, size: 14, color: Colors.amber))),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(r.text, style: const TextStyle(color: Colors.black87)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${r.date.day}/${r.date.month}/${r.date.year}', style: const TextStyle(color: Colors.black45, fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

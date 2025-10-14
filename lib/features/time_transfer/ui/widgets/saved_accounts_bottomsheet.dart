import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transaction_providers.dart';
import '../../domain/models/saved_account.dart';

class SavedAccountsBottomSheet extends ConsumerStatefulWidget {
  const SavedAccountsBottomSheet({super.key});

  @override
  ConsumerState<SavedAccountsBottomSheet> createState() => _SavedAccountsBottomSheetState();
}

class _SavedAccountsBottomSheetState extends ConsumerState<SavedAccountsBottomSheet> {
  final TextEditingController searchController = TextEditingController();
  List<SavedAccount> filteredAccounts = [];

  @override
  void initState() {
    super.initState();
    // initial empty; will be filled when data loads
    filteredAccounts = [];
  }

  void _onSearchChanged(String query, List<SavedAccount> list) {
    final lower = query.toLowerCase();
    setState(() {
      filteredAccounts = list.where((acc) {
        final name = acc.name.toLowerCase();
        final number = acc.number.toLowerCase();
        return name.contains(lower) || number.contains(lower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xFF003E77);

    final accountsAsync = ref.watch(savedAccountsProvider);

    return accountsAsync.when(
      data: (list) {
        // ensure filtered list has initial value
        if (filteredAccounts.isEmpty) filteredAccounts = List.from(list);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.25 * 255).toInt()),
                blurRadius: 20,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Danh sách đã lưu',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.2 * 255).toInt()),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: colorPrimary, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onChanged: (q) => _onSearchChanged(q, list),
                            decoration: const InputDecoration(
                              hintText: 'Tìm kiếm tên hoặc số tài khoản...',
                              hintStyle: TextStyle(color: Colors.black38),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Flexible(
                    child: filteredAccounts.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Không tìm thấy tài khoản nào',
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filteredAccounts.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final acc = filteredAccounts[i];
                                return InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => Navigator.pop(context, acc),
                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha((0.2 * 255).toInt()),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        acc.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        acc.number,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
      error: (_, __) => const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Lỗi tải danh bạ'))),
    );
  }
}

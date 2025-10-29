import 'package:flutter/material.dart';
import '../../data/mock_service_repository.dart';

class PendingApplicantsWidget extends StatefulWidget {
  final String serviceId;
  // Callback when an applicant is tapped. Parent can show details in a tab/page.
  final ValueChanged<Map<String, dynamic>>? onApplicantTap;
  // When false, hide the search bar and filter icon and don't filter the list.
  final bool showSearchAndFilter;
  // When true, show pending applicants across all jobs instead of filtering
  // by a specific serviceId.
  final bool showAllJobs;

  const PendingApplicantsWidget({
    super.key,
    required this.serviceId,
    this.onApplicantTap,
    this.showSearchAndFilter = true,
    this.showAllJobs = false,
  });

  @override
  State<PendingApplicantsWidget> createState() =>
      _PendingApplicantsWidgetState();
}

// LỚP STATE (Lớp con quản lý trạng thái)
class _PendingApplicantsWidgetState extends State<PendingApplicantsWidget>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Đăng ký listener để nhận thông báo khi có thay đổi
    MockServiceRepository.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    MockServiceRepository.removeListener(_onDataChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    debugPrint('📢 PendingApplicantsWidget received data change notification');
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh UI khi app resumed hoặc có thay đổi
      setState(() {});
    }
  }

  // Method để refresh từ bên ngoài (hiện tại chưa được gọi)
  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug logging
    // access applicants via MockServiceRepository.mockApplicants when needed
    // print(
    //     '🔍 PendingApplicantsWidget build for serviceId: ${widget.serviceId}');
    // print('📊 Total applicants: ${allApplicants.length}');
    // print('📊 Applicants for this service: ${serviceApplicants.length}');

  // Lọc ứng viên pending. Nếu showAllJobs == true thì show tất cả các
  // applicants có status 'pending' trên toàn bộ hệ thống; ngược lại chỉ
  // hiển thị applicants của serviceId được truyền vào.
  final servicePendingApplicants = widget.showAllJobs
    ? MockServiceRepository.mockApplicants
      .where((a) => a['status'] == 'pending')
      .toList()
    : MockServiceRepository.mockApplicants
      .where((a) =>
        a['status'] == 'pending' &&
        a['serviceId'].toString() == widget.serviceId)
      .toList();
    // print(
    //     '📊 Pending applicants for this service: ${servicePendingApplicants.length}');

    // Debug: In ra chi tiết từng applicant
    for (var applicant in servicePendingApplicants) {
      debugPrint(
          '👤 Applicant: ${applicant['name']}, Status: ${applicant['status']}, ServiceId: ${applicant['serviceId']}');
    }

    // Lọc theo tìm kiếm (nếu showSearchAndFilter==true), ngược lại show tất cả
    final filteredApplicants = widget.showSearchAndFilter
        ? servicePendingApplicants.where((applicant) {
            final name = applicant['name'].toString().toLowerCase();
            final specialization =
                applicant['specialization'].toString().toLowerCase();
            return name.contains(_searchQuery.toLowerCase()) ||
                specialization.contains(_searchQuery.toLowerCase());
          }).toList()
        : servicePendingApplicants.toList();

    debugPrint('🔍 Filtered applicants: ${filteredApplicants.length}');

    return Column(
      children: [
        // Thanh tìm kiếm và icon lọc (ẩn khi showSearchAndFilter == false)
        if (widget.showSearchAndFilter)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Tìm kiếm ứng viên đã duyệt...',
                        hintStyle: TextStyle(
                          fontSize: 14, // 👈 chữ nhỏ lại
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    _showFilterDialog(context);
                  },
                  icon: const Icon(Icons.filter_alt_outlined,
                      color: Color(0xFF003E77), size: 28),
                  tooltip: 'Lọc ứng viên',
                ),
              ],
            ),
          ),

        // Danh sách ứng viên
        Expanded(
          child: Builder(
            builder: (context) {
              debugPrint(
                  '🎯 UI Decision: filteredApplicants.isEmpty = ${filteredApplicants.isEmpty}');
              debugPrint('🎯 Search query: "$_searchQuery"');

              if (filteredApplicants.isEmpty) {
                debugPrint('📺 Showing empty state');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty
                            ? Icons.search_off
                            : Icons.hourglass_empty,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Không tìm thấy ứng viên nào'
                            : 'Không có ứng viên nào đang chờ phê duyệt',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                debugPrint(
                    '📺 Showing ListView with ${filteredApplicants.length} items');
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredApplicants.length,
                  itemBuilder: (context, index) {
                    debugPrint(
                        '🏗️ Building card for applicant ${index}: ${filteredApplicants[index]['name']}');
                    return _buildApplicantCard(
                        context, filteredApplicants[index]);
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecializationTags(
      BuildContext context, String? specializations) {
    // Hiển thị tag chuyên môn dạng Wrap; mỗi tag có nền vàng nhạt
    if (specializations == null || specializations.isEmpty) {
      return const Text('Chưa có thông tin',
          style: TextStyle(color: Colors.grey));
    }

    final List<String> tags =
        specializations.split(',').map((e) => e.trim()).toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: tags
            .map((tag) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFE0DC06),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                        fontSize: 9,
                        color: (Color(0xFF000000)) // Sắc 900 là sắc đậm nhất,
                        // fontWeight: FontWeight.w500,
                        ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildApplicantCard(
      BuildContext context, Map<String, dynamic> applicant) {
    final String requestTypeText = applicant['requestType'] == 'receive'
        ? 'Yêu cầu chờ xét duyệt nhận dịch vụ'
        : 'Yêu cầu chờ xét duyệt hủy dịch vụ';

    return GestureDetector(
        onTap: () {
          // If parent provided a handler, call it so parent can show details in a tab
          if (widget.onApplicantTap != null) {
            widget.onApplicantTap!(applicant);
            return;
          }

          // Fallback to show modal if parent didn't handle it
          _showApplicantDetailsModal(context, applicant);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 1),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với loại yêu cầu và thời gian
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      requestTypeText,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF003E77),
                      ),
                    ),
                  ),
                  Text(
                    applicant['requestTime'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF003E77),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Thông tin ứng viên: Avatar + Tên + Chuyên môn + Đánh giá
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFF003E77),
                    backgroundImage: applicant['avatar'] != null
                        ? NetworkImage(applicant['avatar'])
                        : null,
                    child: applicant['avatar'] == null
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 35)
                        : null,
                  ),

                  const SizedBox(width: 12),

                  // Thông tin bên phải avatar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên ứng viên
                        Text(
                          applicant['name'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF003E77),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Chuyên môn ngang hàng với tags
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Chuyên môn:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF003E77),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildSpecializationTags(
                                  context, applicant['specialization']),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Đánh giá sao
                        Row(
                          children: [
                            ...List.generate(5, (starIndex) {
                              return Icon(
                                starIndex < applicant['rating'].floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 16,
                                color: Color(0xFFE6E609),
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

                  // Nút hành động
                ],
              ),
            ],
          ),
        )); // Container + GestureDetector
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Bộ lọc ứng viên'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sắp xếp theo:'),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Tên A-Z'),
                leading: const Icon(Icons.sort_by_alpha),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Đánh giá cao nhất'),
                leading: const Icon(Icons.star),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Thời gian nộp mới nhất'),
                leading: const Icon(Icons.access_time),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  void _showApplicantDetailsModal(
      BuildContext context, Map<String, dynamic> applicant) {
    // Lấy thông tin service từ serviceId
    final service =
        MockServiceRepository.getServiceById(applicant['serviceId']);
    final serviceName = service?.title ?? 'Chưa có thông tin';
    final duration = service != null
        ? MockServiceRepository.formatDuration(service.minSlotMinutes)
        : '00:00:00';

    // Format thời gian tạo job (createdAt)
    String jobCreatedTime = 'Chưa có thông tin';
    if (service?.createdAt != null) {
      final createdAt = service!.createdAt;
      jobCreatedTime =
          '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} ${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Thay đổi màu handle bar
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Chi tiết ứng viên',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003E77),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar + Name + Specialization + Rating + Chat Icon
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: const Color(0xFF003E77),
                            backgroundImage: applicant['avatar'] != null
                                ? NetworkImage(applicant['avatar'])
                                : null,
                            child: applicant['avatar'] == null
                                ? const Icon(Icons.person,
                                    color: Colors.white, size: 35)
                                : null,
                          ),
                          const SizedBox(width: 16),
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
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Chuyên môn:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        //fontWeight: FontWeight.w500,
                                        color: Color(0xFF003E77),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: _buildSpecializationTags(
                                          context, applicant['specialization']),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ...List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < applicant['rating'].floor()
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 16,
                                        color: Color(0xFFE6E609),
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
                          IconButton(
                            onPressed: () {
                              // Chat functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Mở chat...')),
                              );
                            },
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              color: Color(0xFF003E77),
                              size: 28,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Thông tin chi tiết
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          //color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          //border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Thời gian:', jobCreatedTime),
                            const SizedBox(height: 12),
                            _buildInfoRow('Tên dịch vụ:', serviceName),
                            const SizedBox(height: 12),
                            _buildInfoRow('Thời lượng dịch vụ:', duration),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ghi chú:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    //fontWeight: FontWeight.w600,
                                    color: Color(0xFF003E77),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    //hintText: 'Nhập ghi chú về ứng viên...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    contentPadding: const EdgeInsets.all(12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showApproveConfirmDialog(context, applicant);
                              },
                              icon: const Icon(Icons.person_add_alt_outlined,
                                  size: 20, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              label: const Text(
                                'Duyệt yêu cầu',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showRejectConfirmDialog(context, applicant);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Từ chối',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 145,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              // fontWeight: FontWeight.w600,
              color: Color(0xFF003E77),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF003E77),
              fontWeight: FontWeight.bold,
            ),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showApproveConfirmDialog(
      BuildContext context, Map<String, dynamic> applicant) {
    final requestType = applicant['requestType'] ?? 'receive';
    final isReceiveRequest = requestType == 'receive';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Xác nhận duyệt',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Color(0xFF003E77),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          isReceiveRequest
              ? 'Bạn có chắc muốn duyệt ứng viên ${applicant['name']}?'
              : 'Bạn có chắc muốn duyệt yêu cầu hủy của ${applicant['name']}?',
          style: TextStyle(
            color: Color(0xFF003E77),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: Color(0xFFCC0404),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              if (isReceiveRequest) {
                // Approve receive request → chuyển thành approved
                MockServiceRepository.approveApplicant(
                    applicant['serviceId'], applicant);
              } else {
                // Approve cancel request → reset về trạng thái ban đầu
                MockServiceRepository.approveCancelRequest(
                    applicant['serviceId']);
              }

              // Refresh UI
              setState(() {});

              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text(isReceiveRequest
              //         ? 'Đã duyệt ứng viên ${applicant['name']}'
              //         : 'Đã duyệt yêu cầu hủy của ${applicant['name']}'),
              //     backgroundColor: Colors.green,
              //   ),
              // );
            },
            //style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Đồng ý',
                style: TextStyle(
                  color: Color(0xFF003E77),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }

  void _showRejectConfirmDialog(
      BuildContext context, Map<String, dynamic> applicant) {
    final requestType = applicant['requestType'] ?? 'receive';
    final isReceiveRequest = requestType == 'receive';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Xác nhận từ chối',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Color(0xFF003E77),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          isReceiveRequest
              ? 'Bạn có chắc muốn từ chối ứng viên ${applicant['name']}?'
              : 'Bạn có chắc muốn từ chối yêu cầu hủy của ${applicant['name']}?',
          style: TextStyle(
            color: Color(0xFF003E77),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: Color(0xFFCC0404),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              if (isReceiveRequest) {
                // Reject receive request → Xóa applicant, reset về 'none'
                MockServiceRepository.resetApplication(applicant['serviceId']);
              } else {
                // Reject cancel request → Chỉ xóa applicant, giữ nguyên trạng thái trước đó
                MockServiceRepository.rejectCancelRequest(
                    applicant['serviceId']);
              }

              // Refresh UI
              setState(() {});
            },
            child: const Text(
              'Từ chối',
              style: TextStyle(
                color: Color(0xFF003E77),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

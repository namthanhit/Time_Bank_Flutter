import 'package:flutter/material.dart';
import '../../../data/mock_service_repository.dart';

class ApprovedApplicantsWidget extends StatefulWidget {
  final String serviceId;

  const ApprovedApplicantsWidget({
    super.key,
    required this.serviceId,
  });

  @override
  State<ApprovedApplicantsWidget> createState() =>
      _ApprovedApplicantsWidgetState();
}

class _ApprovedApplicantsWidgetState extends State<ApprovedApplicantsWidget>
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh UI khi app resumed hoặc có thay đổi
      setState(() {});
    }
  }

  void _onDataChanged() {
    //print('📢 ApprovedApplicantsWidget received data change notification');
    if (mounted) {
      setState(() {});
    }
  }

  // Method để refresh từ bên ngoài
  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug logging
    // Use MockServiceRepository.mockApplicants directly when needed
    //print(
    //  '🔍 ApprovedApplicantsWidget build for serviceId: ${widget.serviceId}');
    // print('📊 Total applicants: ${allApplicants.length}');
    //print('📊 Applicants for this service: ${serviceApplicants.length}');

    // Debug: applicants available via MockServiceRepository.mockApplicants

    // Lọc ứng viên approved của service cụ thể
    final serviceApprovedApplicants = MockServiceRepository.mockApplicants
        .where((a) =>
            a['status'] == 'approved' &&
            a['serviceId'].toString() == widget.serviceId)
        .toList();

    // print(
    //     '📊 Approved applicants for this service: ${serviceApprovedApplicants.length}');

    // Lọc theo tìm kiếm
    final filteredApplicants = serviceApprovedApplicants.where((applicant) {
      final name = applicant['name'].toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Thanh tìm kiếm và icon lọc
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
                        // color: Colors.grey,    // màu nhẹ hơn cho hint
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
                  // Simplified filter - just show a message for now
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bộ lọc đang phát triển')),
                  );
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
              // print(
              //     '🎯 UI Decision for ApprovedApplicants: filteredApplicants.isEmpty = ${filteredApplicants.isEmpty}');
              // print('🎯 Search query: "$_searchQuery"');
              // print(
              //     '🎯 Filtered applicants count: ${filteredApplicants.length}');

              if (filteredApplicants.isEmpty) {
                //print('📺 Showing empty state for approved applicants');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty
                            ? Icons.search_off
                            : Icons.check_circle_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Không tìm thấy ứng viên nào'
                            : 'Chưa có ứng viên nào được duyệt',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // print(
                //     '📺 Showing ListView with ${filteredApplicants.length} approved applicants');
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredApplicants.length,
                  itemBuilder: (context, index) {
                    //print(
                    //'🏗️ Building approved card for applicant ${index}: ${filteredApplicants[index]['name']}');
                    try {
                      return _buildApplicantCard(
                          context, filteredApplicants[index]);
                    } catch (e) {
                      return Container(
                        height: 80,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text('Error loading applicant: $e',
                              style: const TextStyle(color: Colors.red)),
                        ),
                      );
                    }
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildApplicantCard(
      BuildContext context, Map<String, dynamic> applicant) {
    // print('🎨 Building card for approved applicant: ${applicant['name']}');
    // print('🔍 Applicant data: ${applicant.toString()}');

    final String requestTypeText = 'Yêu cầu đã được phê duyệt nhận dịch vụ';

    return GestureDetector(
      onTap: () => _showApplicantDetailsModal(context, applicant),
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
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF003E77),
                    ),
                  ),
                ),
                Text(
                  applicant['requestTime']?.toString() ?? 'Không có thời gian',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF003E77),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Thông tin ứng viên: Avatar + Tên + Chuyên môn + Đánh giá + Chat Icon
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 35,
                  backgroundColor: const Color(0xFF003E77),
                  backgroundImage: (applicant['avatar'] != null &&
                          applicant['avatar'].toString().isNotEmpty)
                      ? NetworkImage(applicant['avatar'].toString())
                      : null,
                  child: (applicant['avatar'] == null ||
                          applicant['avatar'].toString().isEmpty)
                      ? const Icon(Icons.person, color: Colors.white, size: 35)
                      : null,
                ),

                const SizedBox(width: 16),

                // Thông tin bên phải avatar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên ứng viên
                      Text(
                        applicant['name']?.toString() ?? 'Unknown User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF003E77),
                        ),
                      ),
                      // Liên hệ với 2 icon
                      const SizedBox(height: 8),

                      // Chuyên môn ngang hàng với tags
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Chuyên môn:',
                            style: TextStyle(
                              fontSize: 12,
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
                            final rating = applicant['rating'] ?? 0;
                            return Icon(
                              starIndex < (rating is num ? rating.toInt() : 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: const Color(0xFFE6E609),
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '${applicant['rating'] ?? 0}',
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

                // Không còn icon Chat ở đây
              ],
            ),
          ],
        ),
      ),
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

  void _showApplicantDetailsModal(
      BuildContext context, Map<String, dynamic> applicant) {
    // Get service information
    final service = MockServiceRepository.getServiceById(widget.serviceId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Chi tiết ứng viên đã duyệt',
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
                            backgroundImage: (applicant['avatar'] != null &&
                                    applicant['avatar'].toString().isNotEmpty)
                                ? NetworkImage(applicant['avatar'].toString())
                                : null,
                            child: (applicant['avatar'] == null ||
                                    applicant['avatar'].toString().isEmpty)
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
                                  applicant['name']?.toString() ??
                                      'Unknown User',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF003E77),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Text(
                                      'Liên hệ:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF003E77),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Icon điện thoại
                                    GestureDetector(
                                      onTap: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Đang gọi điện thoại...')),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.phone,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Icon chat
                                    GestureDetector(
                                      onTap: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('Mở chat...')),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.chat_bubble_outline,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Chuyên môn:',
                                      style: TextStyle(
                                        fontSize: 12,
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
                                      final rating = applicant['rating'] ?? 0;
                                      return Icon(
                                        starIndex <
                                                (rating is num
                                                    ? rating.toInt()
                                                    : 0)
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 16,
                                        color: const Color(0xFFE6E609),
                                      );
                                    }),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${applicant['rating'] ?? 0}',
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

                      const SizedBox(height: 14),

                      // Thông tin chi tiết công việc
                      Container(
                        padding: const EdgeInsets.all(10),
                        // decoration: BoxDecoration(
                        //   color: Colors.grey[50],
                        //   borderRadius: BorderRadius.circular(12),
                        //   border: Border.all(color: Colors.grey[200]!),
                        // ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tên công việc
                            _buildInfoSectionBold(
                                'Tên công việc:', service?.title ?? 'N/A'),
                            const SizedBox(height: 12),

                            // Thời gian
                            _buildInfoSectionBold(
                                'Thời gian:',
                                service?.createdAt != null
                                    ? _formatDateTime(service!.createdAt)
                                    : 'N/A'),
                            const SizedBox(height: 12),

                            // Thời lượng
                            _buildInfoSectionBold(
                                'Thời lượng:',
                                service != null
                                    ? _formatDuration(service.minSlotMinutes)
                                    : '00:00:00'),
                            const SizedBox(height: 12),

                            // Ngày tạo yêu cầu
                            _buildInfoSection(
                                'Ngày tạo yêu cầu:',
                                applicant['requestTime']?.toString() ??
                                    'Không có thông tin'),
                            const SizedBox(height: 12),

                            // Trạng thái
                            _buildInfoSectionBold(
                                'Trạng thái:', 'Đã được duyệt'),
                            const SizedBox(height: 12),

                            // Mô tả công việc
                            _buildInfoSection('Mô tả công việc:',
                                service?.description ?? 'Không có mô tả'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Close button
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Đóng',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                // fontWeight: FontWeight.w600,
                color: Color(0xFF003E77),
              ),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF003E77),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSectionBold(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                //fontWeight: FontWeight.w600,
                color: Color(0xFF003E77),
              ),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600, // In đậm nội dung
                color: Color(0xFF003E77),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  String _formatDuration(int minutes) {
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}:00';
  }
}

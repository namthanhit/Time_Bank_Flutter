import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/service_providers.dart';
import '../../../domain/models/service.dart';
import '../../../data/mock_service_repository.dart';
import '../../page/service_applicants_page.dart';
import '../../page/four_service_applicants_page.dart';
import 'edit_service.dart';

class MyServiceDetailPage extends ConsumerStatefulWidget {
  final String serviceId;
  const MyServiceDetailPage({
    super.key,
    required this.serviceId,
  });

  @override
  ConsumerState<MyServiceDetailPage> createState() =>
      _MyServiceDetailPageState();
}

class _MyServiceDetailPageState extends ConsumerState<MyServiceDetailPage> {
  PageController? _pageController;
  int _currentImageIndex = 0;
  int _currentStep =
      0; // 0: Đã tạo, 1: Đang mở (mặc định), 2: Đang thực hiện, 3: Đã hoàn thành
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceAsync = ref.watch(serviceByIdProvider(widget.serviceId));

    return Scaffold(
      backgroundColor: const Color(0xFF003E77),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003E77),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Chi tiết yêu cầu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          //borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: serviceAsync.when(
          data: (service) {
            if (service == null) {
              return const Center(child: Text('Không tìm thấy dịch vụ'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(serviceByIdProvider(widget.serviceId));
                await Future.delayed(const Duration(milliseconds: 300));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: _buildServiceContent(service),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Lỗi: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.refresh(serviceByIdProvider(widget.serviceId)),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildServiceContent(Service service) {
    // Khởi tạo trạng thái dựa trên service status
    _initializeStatus(service);
    // Nội dung chính: cuộn dọc
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMyServiceHeader(service),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Details box: description + images
          _buildDetailsBox(service),
          const SizedBox(height: 20),
          _buildActionRow(service),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMyServiceHeader(Service service) {
    // Header riêng cho My Services: title + icon người, thông tin thời gian/thời lượng/địa điểm/chuyên môn
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row with icon di chuyển sang gần title
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      service.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF003E77),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Icon người được di chuyển sang gần title
                  Icon(
                    service.isPublic ? Icons.people : Icons.group,
                    size: 25,
                    color: const Color(0xFF003E77),
                  ),
                ],
              ),
            ),
            // Nút ba chấm (menu)
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Icon(
                  Icons.more_horiz,
                  size: 25,
                  color: Color(0xFF003E77),
                ),
              ),
              color: Colors.white,
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Chỉnh sửa'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xóa'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    // Open the edit page with the current service prefilled
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => EditServicePage(service: service),
                      ),
                    );
                    break;
                  case 'delete':
                    _showDeleteConfirmDialog(context, service);
                    break;
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Thông tin chi tiết: time, duration, location, specialization
        _buildServiceDetails(service),
      ],
    );
  }

  Widget _buildServiceDetails(Service service) {
    return Column(
      children: [
        // Hàng 1: Thời gian
        _buildDetailItem(
          Icons.access_time,
          'Thời gian',
          _formatDateTime(service.createdAt),
        ),

        const SizedBox(height: 12),

        // Hàng 2: Thời lượng
        _buildDetailItem(
          Icons.timer,
          'Thời lượng',
          _formatDuration(service.minSlotMinutes),
        ),

        const SizedBox(height: 12),

        // Hàng 3: Địa điểm
        _buildDetailItem(
          Icons.location_on,
          'Địa điểm',
          service.place ?? 'Chưa xác định',
        ),

        const SizedBox(height: 12),

        // Hàng 4: Chuyên môn - cùng một dòng
        _buildSpecializationInline(service),

        const SizedBox(height: 12),
        // Số lượng nhân sự: booked / capacity
        _buildPersonnelCount(service),

        const SizedBox(height: 16),

        // Thanh tiến trình trạng thái
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildPersonnelCount(Service service) {
    final booked = service.bookedSlots ?? 0;
    final cap = service.slot;
    final bookedStr = booked.toString().padLeft(2, '0');
    final capStr = cap.toString().padLeft(2, '0');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          child: Icon(
            Icons.group,
            size: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Số lượng nhân sự: ',
          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
        Text(
          '$bookedStr/$capStr',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF003E77),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    // Màu sắc đặc biệt cho từng loại theo community tab style
    Color valueColor;
    double valueSize;
    FontWeight valueWeight;

    switch (label) {
      case 'Thời gian':
        valueColor = const Color(0xFF419C23); // Xanh lá
        valueSize = 18;
        valueWeight = FontWeight.normal;
        break;
      case 'Thời lượng':
        valueColor = Colors.red[600]!; // Đỏ
        valueSize = 22;
        valueWeight = FontWeight.bold;
        break;
      default:
        valueColor = Colors.grey[800]!; // Mặc định
        valueSize = 16;
        valueWeight = FontWeight.normal;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          child: Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              color: valueColor,
              fontWeight: valueWeight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecializationInline(Service service) {
    // Debug: xem nội dung skillNames/providerSpecialization nếu cần
    debugPrint('service.skillNames: ${service.skillNames}');
    debugPrint(
        'service.providerSpecialization: ${service.providerSpecialization}');

    // Sử dụng trực tiếp skillNames nếu có, không map từ skillId
    final List<String> fromSkillNames = (service.skillNames ?? <String>[])
        .map((e) => e.toString().trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Nếu không có skillNames, fallback tách chuỗi providerSpecialization (nếu backend gộp)
    final List<String> fromProviderSpecialization =
        (service.providerSpecialization ?? '')
            .split(',')
            .map((e) => e.trim())
            .where((s) => s.isNotEmpty)
            .toList();

    final List<String> specializationsList =
        fromSkillNames.isNotEmpty ? fromSkillNames : fromProviderSpecialization;

    final specializations = specializationsList.isNotEmpty
        ? specializationsList.toSet().toList()
        : ['Chưa có'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          child: Icon(
            Icons.work,
            size: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Chuyên môn: ',
          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            final double maxChipWidth = 72;
            final double chipWidth =
                (constraints.maxWidth / 3).clamp(40, maxChipWidth);

            return Wrap(
              spacing: 8,
              runSpacing: 6,
              children: specializations
                  .map((spec) => ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: chipWidth),
                        child: SizedBox(
                          height: 20,
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0DC06),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              spec,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF000000),
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            );
          }),
        ),
      ],
    );
  }

  void _initializeStatus(Service service) {
    if (_isCancelled) return;

    final s = service.status.toString().toLowerCase();
    debugPrint('service.status: ${s}');
    if (s == 'open' || s == 'đang mở' || s == 'dang mo' || s == 'mở') {
      _currentStep = 1;
      _isCancelled = false;
    } else if (s == 'in_progress' ||
        s == 'doing' ||
        s == 'đang thực hiện' ||
        s == 'dang thuc hien' ||
        s == 'matched') {
      _currentStep = 2;
      _isCancelled = false;
    } else if (s == 'completed' ||
        s == 'đã hoàn thành' ||
        s == 'da hoan thanh') {
      _currentStep = 3;
      _isCancelled = false;
    } else if (s == 'cancelled' ||
        s == 'đã hủy' ||
        s == 'da huy' ||
        s == 'hủy' ||
        s == 'huy') {
      // When cancelled we display it at the 'Đang mở' slot but mark as cancelled
      _currentStep = 1;
      _isCancelled = true;
    } else {
      // Fallback: treat unknown/empty as 'Đang mở'
      _currentStep = 1;
      _isCancelled = false;
    }
  }

  Widget _buildProgressIndicator() {
    // Các bước cố định
    final steps = [
      'Đã thanh toán',
      'Đang mở',
      'Đang thực hiện',
      'Đã hoàn thành'
    ];

    // Xử lý logic khi dịch vụ bị hủy
    final List<String> displaySteps = List<String>.from(steps);
    if (_isCancelled &&
        _currentStep >= 0 &&
        _currentStep < displaySteps.length) {
      displaySteps[_currentStep] = 'Đã hủy';
    }

    // Xác định màu sắc dựa trên trạng thái (bị hủy hay không)
    final Color completedColor = _isCancelled ? Colors.red : Colors.green;
    final Color activeColor = _isCancelled ? Colors.red : Colors.orange;

    return Container(
      // Padding 16px này sẽ là cơ sở cho chiều rộng của các Row bên trong
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          const Text(
            'Trạng thái dịch vụ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF003E77),
            ),
          ),
          const SizedBox(height: 12),

          // Thanh tiến trình
          Container(
            child: Stack(
              alignment: Alignment.center,
              children: [
                FractionallySizedBox(
                  widthFactor: (displaySteps.length - 1) / displaySteps.length,
                  child: Row(
                    children: List.generate(displaySteps.length - 1, (index) {
                      final isCompleted = (index + 1) <= _currentStep;

                      return Expanded(
                        child: Container(
                          height: 6,
                          color:
                              isCompleted ? completedColor : Colors.grey[300]!,
                        ),
                      );
                    }),
                  ),
                ),

                // Các mốc tròn
                Row(
                  children: List.generate(displaySteps.length, (index) {
                    // Bước đã hoàn thành
                    final isCompleted = index < _currentStep;
                    // Bước hiện tại
                    final isActive = index == _currentStep;

                    // Tính toán màu cho mốc tròn
                    Color circleColor;
                    if (isActive) {
                      circleColor = activeColor; // Màu cam/đỏ (nếu hủy)
                    } else if (isCompleted) {
                      circleColor = completedColor; // Màu xanh/đỏ (nếu hủy)
                    } else {
                      // **ĐÃ SỬA LỖI NULL SAFETY:** Thêm `!`
                      circleColor = Colors.grey[300]!; // Màu xám
                    }

                    return Expanded(
                      child: Center(
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: circleColor,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          // **SỬA THEO YÊU CẦU:** // Hiển thị Icon khi (isCompleted) HOẶC (isActive)
                          child: (isCompleted || isActive)
                              ? const Icon(Icons.check,
                                  size: 10, color: Colors.white)
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Label nằm đúng dưới mốc
          Row(
            children: List.generate(displaySteps.length, (index) {
              return Expanded(
                child: Text(
                  displaySteps[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: index == _currentStep
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: index <= _currentStep
                        ? (_isCancelled ? Colors.red : Colors.black87)
                        // **ĐÃ SỬA LỖI NULL SAFETY:** Thêm `!`
                        : Colors.grey[600]!,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsBox(Service service) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả công việc',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF003E77),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            service.description ?? 'Không có mô tả',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          if (service.serviceImages?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            _buildImageGallery(service.serviceImages!),
          ],
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    // Lọc và xác thực URL trước khi hiển thị
    final validImages = images
        .map((s) => s.trim())
        .where((s) =>
            s.isNotEmpty &&
            (s.startsWith('http://') || s.startsWith('https://')) &&
            Uri.tryParse(s) != null)
        .toList();

    // Đảm bảo _currentImageIndex nằm trong khoảng hợp lệ
    if (_currentImageIndex >= validImages.length) {
      _currentImageIndex = validImages.isEmpty ? 0 : validImages.length - 1;
    }

    if (validImages.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[100],
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Không có hình ảnh hợp lệ'),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hình ảnh minh họa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF003E77),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: validImages.length,
            itemBuilder: (context, index) {
              final url = validImages[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Image.network error for $url: $error');
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        if (validImages.length > 1) ...[
          const SizedBox(height: 12),
          _buildImageIndicator(validImages.length),
        ],
      ],
    );
  }

  Widget _buildImageIndicator(int imageCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        imageCount,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentImageIndex
                ? const Color(0xFF003E77)
                : Colors.grey[300],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(Service service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Nút xem chi tiết ứng viên
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFBADBEF).withOpacity(0.82),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceApplicantsPage(
                        serviceId: widget.serviceId,
                        serviceTitle: service.title,
                      ),
                    ),
                  );
                },
                // icon: const Icon(Icons.people, size: 20, color: Colors.white),
                label: const Text(
                  'Xem chi tiết ứng viên',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF003E77),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: () {
                _showDeleteConfirmDialog(context, service);
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Xác nhận hủy yêu cầu',
              style: TextStyle(
                  color: Color(0xFF003E77),
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          content: const Text(
            'Bạn có chắc chắn muốn chắc chắn hủy yêu cầu không?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Cập nhật trạng thái thành "Đã hủy"
                setState(() {
                  _isCancelled = true;
                  _currentStep = 1; // Hủy ở bước "Đang mở"
                });
                // Also update the mock repository so the cancelled tab shows this
                MockServiceRepository.setServiceStatus(
                    widget.serviceId, 'cancelled');

                // Open the FourServiceApplicantsPage on the 'Đã hủy' tab
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FourServiceApplicantsPage(
                      serviceId: widget.serviceId,
                      serviceTitle: service.title,
                      initialTabIndex: 5, // index of 'Đã hủy'
                    ),
                  ),
                );
              },
              child: const Text('Đồng ý',
                  style: TextStyle(
                      color: Color(0xFF003E77),
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String _formatDuration(int seconds) {
    print('Input seconds to _formatDurationHMS: $seconds');
    final hours = seconds ~/ 3600;
    final remainingSeconds = seconds % 3600;
    final mins = remainingSeconds ~/ 60;
    final secs = remainingSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

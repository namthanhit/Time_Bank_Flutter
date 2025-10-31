import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/service/ui/page/four_service_applicants_page.dart';
import 'package:time_bank_flutter/features/service/ui/page/rating_page.dart';
import '../create_page/service_create_page.dart';

class CommunityHeader extends StatefulWidget {
  final bool isMyTab;
  final Function(String?)? onFilterChanged;
  final Function(String)? onSearchChanged;

  const CommunityHeader({
    super.key,
    this.isMyTab = false,
    this.onFilterChanged,
    this.onSearchChanged,
  });

  @override
  State<CommunityHeader> createState() => _CommunityHeaderState();
}

class _CommunityHeaderState extends State<CommunityHeader> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.isMyTab ? 'Yêu cầu của tôi' : 'Tất cả mọi người';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với Avatar + Greeting (make the framed container expand)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ServiceCreatePage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // ensure inner Row can take the available width
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              AssetImage('assets/images/avatar.png'),
                          onBackgroundImageError: (_, __) {},
                          child: Icon(
                            Icons.person,
                            color: Color(0xFF003E77),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            'Hãy tạo điều bạn muốn',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                              //fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 4 Icons Row
          Row(
            children: [
              _buildStatusIcon('assets/icons/File_Check.png', 'Chờ xác nhận',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FourServiceApplicantsPage(
                      serviceId: '1',
                      serviceTitle: 'Chờ xác nhận',
                      initialTabIndex: 0, // tab 1
                    ),
                  ),
                );
              }),
              _buildStatusIcon('assets/icons/Folder_Open.png', 'Đã mở', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FourServiceApplicantsPage(
                      serviceId: '3',
                      serviceTitle: 'Đã mở',
                      initialTabIndex: 2, // tab 2
                    ),
                  ),
                );
              }),
              _buildStatusIcon('assets/icons/pending.png', 'Đang thực hiện',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FourServiceApplicantsPage(
                      serviceId: '4',
                      serviceTitle: 'Đang thực hiện',
                      initialTabIndex: 3, // tab 3
                    ),
                  ),
                );
              }),
              _buildStatusIcon('assets/icons/Wavy_Check.png', 'Đánh giá', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ServiceRatingPage()),
                );
              }),
            ],
          ),
          const SizedBox(height: 18),

          // Section Title (icon + label reflect selected filter)
          Row(
            children: [
              Icon(
                _iconForFilter(_selectedFilter),
                color: Color(0xFF003E77),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _displayLabelForFilter(_selectedFilter),
                style: TextStyle(
                  color: Color(0xFF003E77),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Bar với Filter Icon
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    onChanged: widget.onSearchChanged,
                    //textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm dịch vụ, người dùng...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _showFilterDialog(context),
                icon: Icon(
                  Icons.filter_alt_outlined,
                  color: Color(0xFF003E77),
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String imagePath, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                imagePath,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  IconData fallbackIcon;
                  switch (imagePath) {
                    case 'assets/icons/pending.png':
                      fallbackIcon = Icons.hourglass_empty;
                      break;
                    case 'assets/icons/Folder_Open.png':
                      fallbackIcon = Icons.check_circle_outline;
                      break;
                    case 'assets/icons/File_Check.png':
                      fallbackIcon = Icons.play_circle_outline;
                      break;
                    case 'assets/icons/Wavy_Check.png':
                      fallbackIcon = Icons.star_outline;
                      break;
                    default:
                      fallbackIcon = Icons.help_outline;
                  }
                  return Icon(
                    fallbackIcon,
                    color: const Color(0xFF003E77),
                    size: 20,
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Bộ lọc'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption(Icons.public, 'Mọi người'),
              _buildFilterOption(Icons.group, 'Bạn bè'),
              _buildFilterOption(Icons.person, 'Của tôi'),
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

  Widget _buildFilterOption(IconData icon, String label,
      [String? filterValue]) {
    return Builder(builder: (BuildContext context) {
      return ListTile(
        leading: Icon(icon, color: Color(0xFF003E77)),
        title: Text(label),
        onTap: () {
          Navigator.of(context).pop();
          final value = filterValue ?? label;
          setState(() {
            // update local selected filter
            _selectedFilter = value;
          });
          // propagate to parent if provided
          if (widget.onFilterChanged != null) {
            widget.onFilterChanged!(value);
          }
        },
      );
    });
  }

  IconData _iconForFilter(String filter) {
    switch (filter) {
      case 'Bạn bè':
        return Icons.group; // 👥
      case 'Của tôi':
      case 'Yêu cầu của tôi':
        return Icons.assignment_ind; // 🧾 hoặc Icons.person_outline
      case 'Mọi người':
      case 'Tất cả mọi người':
      default:
        return Icons.public; // 🌐
    }
  }

  String _displayLabelForFilter(String filter) {
    // normalize some labels to match the UI expectation
    if (filter == 'Mọi người') return 'Mọi người';
    return filter;
  }
}

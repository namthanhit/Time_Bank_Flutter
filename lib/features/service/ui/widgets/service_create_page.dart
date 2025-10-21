import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/service.dart';

class ServiceCreatePage extends ConsumerStatefulWidget {
  const ServiceCreatePage({super.key});

  @override
  ConsumerState<ServiceCreatePage> createState() => _ServiceCreatePageState();
}

class _ServiceCreatePageState extends ConsumerState<ServiceCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = 'Giáo dục';
  String _selectedDifficulty = 'Dễ';
  int _estimatedMinutes = 60;

  final List<String> _categories = [
    'Giáo dục',
    'Chăm sóc sức khỏe',
    'Công nghệ',
    'Vận chuyển',
    'Gia đình',
    'Khác'
  ];

  final List<String> _difficulties = ['Dễ', 'Trung bình', 'Khó'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tạo dịch vụ mới',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF003E77),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              _buildSectionTitle('Tiêu đề dịch vụ'),
              TextFormField(
                controller: _titleController,
                decoration:
                    _buildInputDecoration('VD: Dạy tiếng Anh cho trẻ em'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề dịch vụ';
                  }
                  if (value.trim().length < 10) {
                    return 'Tiêu đề phải có ít nhất 10 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Selection
              _buildSectionTitle('Danh mục'),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _buildInputDecoration('Chọn danh mục'),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Description Field
              _buildSectionTitle('Mô tả chi tiết'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _buildInputDecoration(
                  'Mô tả chi tiết về dịch vụ của bạn...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mô tả dịch vụ';
                  }
                  if (value.trim().length < 20) {
                    return 'Mô tả phải có ít nhất 20 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Location Field
              _buildSectionTitle('Địa điểm'),
              TextFormField(
                controller: _locationController,
                decoration: _buildInputDecoration('VD: Quận 1, TP.HCM'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập địa điểm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Difficulty Selection
              _buildSectionTitle('Độ khó'),
              Row(
                children: _difficulties.map((difficulty) {
                  return Expanded(
                    child: RadioListTile<String>(
                      title: Text(
                        difficulty,
                        style: const TextStyle(fontSize: 14),
                      ),
                      value: difficulty,
                      groupValue: _selectedDifficulty,
                      onChanged: (value) {
                        setState(() {
                          _selectedDifficulty = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Duration Slider
              _buildSectionTitle('Thời gian ước tính (phút)'),
              Column(
                children: [
                  Slider(
                    value: _estimatedMinutes.toDouble(),
                    min: 15,
                    max: 480,
                    divisions: 31,
                    label: '${_estimatedMinutes} phút',
                    onChanged: (value) {
                      setState(() {
                        _estimatedMinutes = value.round();
                      });
                    },
                  ),
                  Text(
                    '${_estimatedMinutes} phút (${(_estimatedMinutes / 60).toStringAsFixed(1)} giờ)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Price Field
              _buildSectionTitle('Giá (Time Credits)'),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration('VD: 10'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập giá dịch vụ';
                  }
                  final price = int.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Giá phải là số nguyên dương';
                  }
                  if (price > 100) {
                    return 'Giá không được vượt quá 100 Time Credits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _createService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003E77),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tạo dịch vụ',
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF003E77),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF003E77), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  void _createService() {
    if (_formKey.currentState!.validate()) {
      // Create new service
      final newService = Service(
        id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
        userId: 1, // Current user ID
        skillId: 1, // Default skill ID
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        regionCode: _locationController.text.trim(),
        minSlotMinutes: _estimatedMinutes,
        isPublic: true,
        ratingAvg: 0.0,
        ratingCount: 0,
        createdAt: DateTime.now(),
        status: 'Mới',
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dịch vụ đã được tạo thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.of(context).pop(newService);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_bank_flutter/features/Onboarding/ui/enter_password.dart';
import 'package:time_bank_flutter/features/onboarding/providers/onboarding_providers.dart';
import '../domain/models/models.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;

  String? gender;  // "Nam" | "Nữ"
  String? major;   // ✅ sẽ là skill_id lấy từ API
  String? address;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _cccdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _cccdController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D1B4C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF0D1B4C)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Widget _buildLabel(String text, {bool isRequired = true}) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        if (isRequired)
          const Text(" *", style: TextStyle(color: Colors.red, fontSize: 14)),
      ],
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Map gender UI -> enum backend
    String? genderEnum;
    if (gender == "Nam") genderEnum = "male";
    else if (gender == "Nữ") genderEnum = "female";
    else if (gender == "Khác") genderEnum = "other";
    else genderEnum = "unknown";

    // Bắt buộc phải chọn 1 skill (major là skill_id)
    if (major == null || major!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn chuyên môn')),
      );
      return;
    }

    // Lưu bản nháp vào state; specialization tạm dùng để giữ skill_id
    ref.read(onboardingControllerProvider.notifier).setPersonalDraft(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      cccd: _cccdController.text.trim().isEmpty ? null : _cccdController.text.trim(),
      birthdate: selectedDate,
      gender: genderEnum,
      address: address,
      specialization: major, // ✅ skill_id (sẽ map sang skill_id khi create account)
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PasswordSetupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);

    // Lấy danh sách kỹ năng từ API
    final skillsAsync = ref.watch(skillsProvider);

    ref.listen(onboardingControllerProvider, (prev, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  "Thông tin cá nhân",
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CCCD
                        _buildLabel("Căn cước công dân"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _cccdController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Nhập số CCCD",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Vui lòng nhập CCCD";
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return "CCCD chỉ được chứa số";
                            }
                            if (value.length != 12) {
                              return "CCCD phải đủ 12 số";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Email
                        _buildLabel("Email", isRequired: false),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Nhập email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return "Email không hợp lệ";
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Họ và tên
                        _buildLabel("Họ và tên"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            hintText: "Nhập họ và tên",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Vui lòng nhập họ và tên";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Ngày sinh
                        _buildLabel("Ngày sinh"),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "Chọn ngày sinh",
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: _pickDate,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) =>
                          (value == null || value.isEmpty) ? "Vui lòng chọn ngày sinh" : null,
                        ),
                        const SizedBox(height: 20),

                        // Giới tính
                        _buildLabel("Giới tính"),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: gender,
                          items: const [
                            DropdownMenuItem(value: "Nam", child: Text("Nam")),
                            DropdownMenuItem(value: "Nữ", child: Text("Nữ")),
                            DropdownMenuItem(value: "Khác", child: Text("Khác")),
                          ],
                          onChanged: (value) => setState(() => gender = value),
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            hintText: "Chọn giới tính",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) =>
                          (value == null || value.isEmpty) ? "Vui lòng chọn giới tính" : null,
                        ),
                        const SizedBox(height: 20),

                        // Chuyên môn (dropdown lấy từ API /skills)
                        _buildLabel("Chuyên môn"),
                        const SizedBox(height: 6),
                        skillsAsync.when(
                          data: (skills) {
                            return DropdownButtonFormField<String>(
                              value: major,                       // lưu skill_id
                              isExpanded: true,                   // giãn ngang, tránh bị … sớm
                              menuMaxHeight: 320,                 // hạn chế chiều cao, tự scroll
                              items: skills.map((s) {
                                return DropdownMenuItem<String>(
                                  value: s.id,
                                  child: Text(
                                    s.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis, // tên dài sẽ … gọn
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => major = value),
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                hintText: "Chọn chuyên môn",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) =>
                              (value == null || value.isEmpty) ? "Vui lòng chọn chuyên môn" : null,
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Lỗi tải kỹ năng: $e'),
                        ),
                        const SizedBox(height: 20),

                        // Địa chỉ
                        _buildLabel("Địa chỉ"),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: address,
                          items: const [
                            DropdownMenuItem(value: "Hà Nội", child: Text("Hà Nội")),
                            DropdownMenuItem(value: "Hải Dương", child: Text("Hải Dương")),
                            DropdownMenuItem(value: "Khác", child: Text("Khác")),
                          ],
                          onChanged: (value) => setState(() => address = value),
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            hintText: "Chọn địa chỉ",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) =>
                          (value == null || value.isEmpty) ? "Vui lòng chọn địa chỉ" : null,
                        ),
                        const SizedBox(height: 34),

                        // Nút Tiếp theo
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state.loading ? null : _onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D1B4C),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: state.loading
                                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text("Tiếp theo"),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Nút Hủy
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: state.loading ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0D1B4C),
                              side: const BorderSide(color: Color(0xFF0D1B4C)),
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Hủy"),
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
      ),
    );
  }
}

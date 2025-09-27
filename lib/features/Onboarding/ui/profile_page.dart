import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/Onboarding/ui/enter_password.dart';
import 'package:time_bank_flutter/features/Onboarding/ui/set_security_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;

  String? gender;
  String? major;
  String? address;

  final TextEditingController _dateController = TextEditingController();

  // Future<void> _pickDate() async {
  //   DateTime now = DateTime.now();
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime(2000),
  //     firstDate: DateTime(1950),
  //     lastDate: now,
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       selectedDate = picked;
  //       _dateController.text =
  //       "${picked.day}/${picked.month}/${picked.year}";
  //     });
  //   }
  // }
  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D1B4C), // xanh navy
              onPrimary: Colors.white,    // chữ trên header
              surface: Colors.white,      // nền dialog trắng
              onSurface: Colors.black,    // chữ trong body
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF0D1B4C),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text =
        "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Widget _buildLabel(String text) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const Text(
          " *",
          style: TextStyle(color: Colors.red, fontSize: 14),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                          (value == null || value.isEmpty)
                              ? "Vui lòng chọn ngày sinh"
                              : null,
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
                          (value == null || value.isEmpty)
                              ? "Vui lòng chọn giới tính"
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Chuyên môn
                        _buildLabel("Chuyên môn"),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: major,
                          items: const [
                            DropdownMenuItem(value: "CNTT", child: Text("CNTT")),
                            DropdownMenuItem(value: "Khác", child: Text("Khác")),
                            DropdownMenuItem(
                                value: "Kỹ sư phần mềm",
                                child: Text("Kỹ sư phần mềm")),
                            DropdownMenuItem(
                                value: "Thiết kế đồ họa",
                                child: Text("Thiết kế đồ họa")),
                            DropdownMenuItem(
                                value: "Giáo viên", child: Text("Giáo viên")),
                            DropdownMenuItem(value: "Bác sĩ", child: Text("Bác sĩ")),
                            DropdownMenuItem(value: "Kế toán", child: Text("Kế toán")),
                          ],
                          onChanged: (value) => setState(() => major = value),
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            hintText: "Chọn chuyên môn",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) =>
                          (value == null || value.isEmpty)
                              ? "Vui lòng chọn chuyên môn"
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Địa chỉ
                        _buildLabel("Địa chỉ"),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: address,
                          items: const [
                            DropdownMenuItem(value: "Hà Nội", child: Text("Hà Nội")),
                            DropdownMenuItem(
                                value: "Hải Dương", child: Text("Hải Dương")),
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
                          (value == null || value.isEmpty)
                              ? "Vui lòng chọn địa chỉ"
                              : null,
                        ),
                        const SizedBox(height: 34),

                        // Nút Tiếp theo
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const PasswordSetupScreen()),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D1B4C),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Tiếp theo"),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Nút Hủy
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
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

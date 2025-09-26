import 'package:flutter/material.dart';
import 'package:time_bank_flutter/features/Onboarding/ui/set_security_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DateTime? selectedDate;

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  "Thông tin cá nhân",
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Box trắng chứa form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ngày sinh
                      const Text(
                        "Ngày sinh",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54, // chữ mờ nhẹ
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "Chọn ngày sinh",
                          hintStyle: const TextStyle(color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _pickDate,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        controller: TextEditingController(
                          text: selectedDate == null
                              ? ""
                              : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Giới tính
                      const Text(
                        "Giới tính",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        items: const [
                          DropdownMenuItem(value: "Nam", child: Text("Nam")),
                          DropdownMenuItem(value: "Nữ", child: Text("Nữ")),
                        ],
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          hintText: "Chọn giới tính",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Chuyên môn
                      const Text(
                        "Chuyên môn",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        items: const [
                          DropdownMenuItem(value: "CNTT", child: Text("CNTT")),
                          DropdownMenuItem(value: "Khác", child: Text("Khác")),
                          DropdownMenuItem(value: "Kỹ sư phần mềm", child: Text("Kỹ sư phần mềm")),
                          DropdownMenuItem(value: "Thiết kế đồ họa", child: Text("Thiết kế đồ họa")),
                          DropdownMenuItem(value: "Giáo viên", child: Text("Giáo viên")),
                          DropdownMenuItem(value: "Bác sĩ", child: Text("Bác sĩ")),
                          DropdownMenuItem(value: "Kế toán", child: Text("Kế toán")),
                        ],
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          hintText: "Chọn chuyên môn",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Địa chỉ
                      const Text(
                        "Địa chỉ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        items: const [
                          DropdownMenuItem(value: "Hà Nội", child: Text("Hà Nội")),
                          DropdownMenuItem(value: "Hải Dương", child: Text("Hải Dương")),
                          DropdownMenuItem(value: "Khác", child: Text("Khác")),
                        ],
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          hintText: "Chọn địa chỉ",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 34),

                      // Nút Tiếp theo
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PinSetupScreen()),
                          ),
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
                            minimumSize: const Size(double.infinity, 48),
                            side: const BorderSide(color: Color(0xFF0D1B4C)),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

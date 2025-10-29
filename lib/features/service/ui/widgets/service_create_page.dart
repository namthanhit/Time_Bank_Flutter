import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:time_bank_flutter/features/service/data/mock_service_repository.dart';
import 'package:time_bank_flutter/features/service/domain/models/service.dart';
// Note: The 'Service' model and 'MockServiceRepository' are no longer used
// as the UI is for a "Request", not a "Service".

class ServiceCreatePage extends ConsumerStatefulWidget {
  const ServiceCreatePage({super.key});

  @override
  ConsumerState<ServiceCreatePage> createState() => _ServiceCreatePageState();
}

class _ServiceCreatePageState extends ConsumerState<ServiceCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _timeController = TextEditingController();
  final _dateController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _participantsCount = 3;
  // selected skills (store skill ids)
  List<String> _selectedSkillIds = [];
  // selected image urls (placeholder implementation)
  List<String> _selectedImages = [];

  // single-field inputs kept: _timeController and _durationController
  // guards to avoid re-entrant formatting during onChanged
  bool _isFormattingTime = false;
  bool _isFormattingDuration = false;
  bool _isFormattingDate = false;
  String? _dateError;

  // skills will be selected from MockServiceRepository.skillNames via selector

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _timeController.dispose();
    _dateController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    // participants handled as int
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF003E77),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: const Text('Tạo yêu cầu'),
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header inside the card
                    _buildCardHeader(),
                    const SizedBox(height: 24),

                    // Tên yêu cầu
                    _buildSectionTitle('Tên yêu cầu:'),
                    TextFormField(
                      controller: _titleController,
                      decoration: _buildInputDecoration('Tên yêu cầu của bạn'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên yêu cầu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Địa chỉ
                    _buildSectionTitle('Địa chỉ:'),
                    TextFormField(
                      controller: _addressController,
                      decoration:
                          _buildInputDecoration('Số nhà, địa chỉ, khu vực'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập địa chỉ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Thời gian (single input, auto-format hh:mm and auto-jump)
                    _buildSectionTitle('Thời gian:'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _timeController,
                            decoration: _buildInputDecoration('hh:mm'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập thời gian';
                              }
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9:]')),
                              LengthLimitingTextInputFormatter(5),
                            ],
                            onChanged: (v) {
                              if (_isFormattingTime) return;
                              _isFormattingTime = true;
                              final digits =
                                  v.replaceAll(RegExp(r'[^0-9]'), '');
                              String newText;
                              if (digits.length <= 2) {
                                newText = digits;
                              } else if (digits.length == 3) {
                                final h = digits.substring(0, 2);
                                final m = digits.substring(2);
                                newText = '$h:$m';
                              } else {
                                final four = (digits + '0000').substring(0, 4);
                                newText = _normalizeTime(four);
                              }

                              if (newText != v) {
                                _timeController.value = TextEditingValue(
                                  text: newText,
                                  selection: TextSelection.collapsed(
                                      offset: newText.length),
                                );
                              }

                              if (digits.length >= 4)
                                FocusScope.of(context).nextFocus();
                              _isFormattingTime = false;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _dateController,
                            decoration:
                                _buildInputDecoration('dd/mm/yyyy').copyWith(
                              errorText: _dateError,
                            ),
                            keyboardType: TextInputType.datetime,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9/]')),
                              LengthLimitingTextInputFormatter(10),
                            ],
                            onChanged: (v) {
                              if (_isFormattingDate) return;
                              _isFormattingDate = true;
                              final digits =
                                  v.replaceAll(RegExp(r'[^0-9]'), '');
                              String newText;
                              if (digits.length <= 2) {
                                newText = digits;
                              } else if (digits.length <= 4) {
                                newText =
                                    '${digits.substring(0, 2)}/${digits.substring(2)}';
                              } else {
                                final y = digits.substring(4);
                                newText =
                                    '${digits.substring(0, 2)}/${digits.substring(2, 4)}/$y';
                              }

                              if (newText != v) {
                                _dateController.value = TextEditingValue(
                                  text: newText,
                                  selection: TextSelection.collapsed(
                                      offset: newText.length),
                                );
                              }

                              if (newText.length == 10) {
                                final dt = parseDdMmYyyy(newText);
                                setState(() {
                                  _dateError =
                                      dt == null ? 'Ngày không hợp lệ' : null;
                                });
                              } else {
                                if (_dateError != null)
                                  setState(() => _dateError = null);
                              }

                              _isFormattingDate = false;
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'Vui lòng nhập ngày';
                              if (parseDdMmYyyy(value) == null)
                                return 'Ngày không hợp lệ';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Thời lượng (single input, auto-format hh:mm:ss and auto-jump)
                    _buildSectionTitle('Thời lượng:'),
                    TextFormField(
                      controller: _durationController,
                      decoration: _buildInputDecoration('hh:mm:ss'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập thời lượng';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                        LengthLimitingTextInputFormatter(8),
                      ],
                      onChanged: (v) {
                        if (_isFormattingDuration) return;
                        _isFormattingDuration = true;
                        final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                        String newText;
                        if (digits.length <= 2) {
                          newText = digits;
                        } else if (digits.length <= 4) {
                          final h = digits.substring(0, 2);
                          final m = digits.substring(2);
                          newText = '$h:$m';
                        } else if (digits.length <= 6) {
                          final h = digits.substring(0, 2);
                          final m = digits.substring(2, 4);
                          final s = digits.substring(4);
                          newText = '$h:$m:$s';
                        } else {
                          newText = _normalizeDuration(digits.substring(0, 6));
                        }

                        if (newText != v) {
                          _durationController.value = TextEditingValue(
                            text: newText,
                            selection:
                                TextSelection.collapsed(offset: newText.length),
                          );
                        }

                        if (digits.length >= 6) {
                          final normalized =
                              _normalizeDuration(digits.substring(0, 6));
                          if (normalized != _durationController.text) {
                            _durationController.value = TextEditingValue(
                              text: normalized,
                              selection: TextSelection.collapsed(
                                  offset: normalized.length),
                            );
                          }
                          FocusScope.of(context).nextFocus();
                        }

                        _isFormattingDuration = false;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Mô tả
                    _buildSectionTitle('Mô tả:'),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: _buildInputDecoration(
                        'Mô tả ngắn về công việc',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập mô tả công việc';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Chuyên môn
                    _buildSectionTitle('Chuyên môn:'),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: [
                        ...MockServiceRepository.getSkillNamesFromIds(
                                _selectedSkillIds)
                            .asMap()
                            .entries
                            .map((e) => InputChip(
                                  label: Text(e.value),
                                  labelStyle: TextStyle(
                                      color: Color(0xFF000000), fontSize: 16),
                                  backgroundColor: Color(0xFFE0DC06),
                                  //side: BorderSide(color: Colors.orange.shade200),
                                  //deleteIconColor: Colors.orange.shade700,
                                  onDeleted: () {
                                    setState(() {
                                      _selectedSkillIds.removeAt(e.key);
                                    });
                                  },
                                ))
                            .toList(),
                        ActionChip(
                          onPressed: () => _showSkillSelector(context),
                          label: const Icon(Icons.add, size: 18),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Participants under specialization with aligned label
                    Row(
                      children: [
                        const Text('Số lượng',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003E77),
                                fontSize: 16)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (_participantsCount > 1)
                                      _participantsCount--;
                                  });
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('$_participantsCount',
                                    style: const TextStyle(fontSize: 16)),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _participantsCount++;
                                  });
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Ảnh
                    _buildSectionTitle('Ảnh:'),
                    _buildImagePicker(),
                    const SizedBox(height: 32),

                    // Create Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _createRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          // foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Tạo yêu cầu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Header widget inside the card
  Widget _buildCardHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Placeholder Avatar
            const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/images/avatar_1.png'),
            ),
            const SizedBox(width: 12),
            Text(
              'Tạo yêu cầu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        Icon(Icons.people_alt_outlined, color: Colors.blue.shade800, size: 28),
      ],
    );
  }

  // Placeholder widget for the image picker
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._selectedImages.map((url) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(url),
                      fit: BoxFit.cover,
                    ),
                  ),
                )),
            GestureDetector(
              onTap: () => _showImageSourceOptions(context),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(child: Icon(Icons.add_a_photo)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
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
      // White background for fields
      fillColor: Colors.white,
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

  // Skill selector dialog - uses MockServiceRepository.skillNames
  Future<void> _showSkillSelector(BuildContext context) async {
    final allSkills = MockServiceRepository.skillNames;
    final Map<String, bool> selected = {
      for (final id in allSkills.keys) id: _selectedSkillIds.contains(id)
    };

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Chọn chuyên môn'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: allSkills.entries.map((e) {
                return CheckboxListTile(
                  value: selected[e.key] ?? false,
                  title: Text(e.value),
                  onChanged: (val) {
                    selected[e.key] = val ?? false;
                    // update dialog state
                    (ctx as Element).markNeedsBuild();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Hủy',
                  style: TextStyle(color: Colors.red),
                )),
            TextButton(
                onPressed: () {
                  setState(() {
                    _selectedSkillIds = selected.entries
                        .where((e) => e.value)
                        .map((e) => e.key)
                        .toList();
                  });
                  Navigator.of(ctx).pop();
                },
                child: const Text(
                  'Xong',
                  style: TextStyle(color: Color(0xFF003E77)),
                )),
          ],
        );
      },
    );
  }

  void _createRequest() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, process the data
      // (The old 'Service' model no longer applies)
      final title = _titleController.text;
      final address = _addressController.text;
      final time = _timeController.text;
      final date = _dateController.text;
      final duration = _durationController.text;
      // Parse time (hh:mm) into minutes
      int parseTimeToMinutes(String s) {
        final parts = s.split(':');
        if (parts.length < 2) return 0;
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        return h * 60 + m;
      }

      // Parse duration hh:mm:ss into total minutes (rounded)
      int parseDurationToMinutes(String s) {
        final parts = s.split(':');
        if (parts.isEmpty) return 0;
        final h = int.tryParse(parts[0]) ?? 0;
        final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
        final sec = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
        final totalSeconds = h * 3600 + m * 60 + sec;
        return (totalSeconds / 60).round();
      }

      final timeMinutes = parseTimeToMinutes(time);
      final durationMinutes = parseDurationToMinutes(duration);

      // Build a mock Service and add it to the MockServiceRepository so it appears in "My" tab
      final newService = Service(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: MockServiceRepository.currentUserId,
        skillIds: _selectedSkillIds.isEmpty ? null : _selectedSkillIds,
        title: title,
        description: _descriptionController.text,
        regionCode: address,
        place: '',
        preferredStart: parseDdMmYyyy(date),
        time: timeMinutes > 0 ? timeMinutes : durationMinutes,
        // `slot` represents personnel capacity (count). Creation UI currently
        // doesn't collect capacity, so default to 1.
        slot: 1,
        visibility: 'public',
        status: 'open',
        createdAt: DateTime.now(),
        providerName: null,
      );

      MockServiceRepository.addService(newService);

      // Use collected values (debug/log)
      debugPrint(
          'Create request: title=$title, address=$address, time=$time, date=$date, duration=$duration');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yêu cầu đã được tạo thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back; listeners should refresh My tab from mock repository
      Navigator.of(context).pop();
    }
  }

  // (format helpers removed — logic inlined where needed)

  String _normalizeTime(String fourDigits) {
    // fourDigits must be 4 chars long: HHMM
    final h = int.tryParse(fourDigits.substring(0, 2)) ?? 0;
    final mRaw = int.tryParse(fourDigits.substring(2, 4)) ?? 0;
    final carryH = mRaw ~/ 60;
    final m = mRaw % 60;
    final hh = h + carryH;
    return '${hh.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  // Normalize hhmmss digits (6 chars) into carried hh:mm:ss
  String _normalizeDuration(String sixDigits) {
    // assume sixDigits length == 6
    final h = int.tryParse(sixDigits.substring(0, 2)) ?? 0;
    var m = int.tryParse(sixDigits.substring(2, 4)) ?? 0;
    var s = int.tryParse(sixDigits.substring(4, 6)) ?? 0;

    // carry seconds into minutes
    final carryM = s ~/ 60;
    s = s % 60;
    m += carryM;

    // carry minutes into hours
    final carryH = m ~/ 60;
    m = m % 60;
    final hh = h + carryH;

    return '${hh.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  //năm nhuận
  bool isLeapYear(int y) {
    if (y % 400 == 0) return true;
    if (y % 100 == 0) return false;
    return y % 4 == 0;
  }

  //số ngày trong tháng
  int daysInMonth(int year, int month) {
    List<int> daysPerMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2) {
      return isLeapYear(year) ? 29 : 28;
    }
    return daysPerMonth[month - 1];
  }

  DateTime? parseDdMmYyyy(String input) {
    if (input.trim().isEmpty) return null;
    final s = input.trim().replaceAll('-', '/');
    final parts = s.split('/');
    if (parts.length != 3) return null;

    // loại bỏ khoảng trắng
    final dStr = parts[0].trim();
    final mStr = parts[1].trim();
    final yStr = parts[2].trim();

    if (dStr.isEmpty || mStr.isEmpty || yStr.isEmpty) return null;

    final d = int.tryParse(dStr);
    final m = int.tryParse(mStr);
    final y = int.tryParse(yStr);
    if (d == null || m == null || y == null) return null;

    if (m < 1 || m > 12) return null;
    final maxD = daysInMonth(y, m);
    if (d < 1 || d > maxD) return null;

    try {
      return DateTime(y, m, d);
    } catch (_) {
      return null;
    }
  }

  // Show a bottom sheet to choose image source (camera or gallery).
  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(ctx).pop();
                // TODO: integrate camera picker; for mock we push a placeholder URL
                setState(() {
                  _selectedImages.add('https://via.placeholder.com/200');
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Thư viện'),
              onTap: () {
                Navigator.of(ctx).pop();
                // TODO: integrate gallery picker; for mock add placeholder image
                setState(() {
                  _selectedImages.add('https://via.placeholder.com/200/cccccc');
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

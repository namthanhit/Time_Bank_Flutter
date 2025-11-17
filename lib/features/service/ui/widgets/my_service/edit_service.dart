import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../onboarding/providers/onboarding_providers.dart';
import '../../../domain/models/service.dart';
import '../../../providers/service_providers.dart';
class EditServicePage extends ConsumerStatefulWidget {
  final Service service;
  const EditServicePage({
    super.key,
    required this.service,
  });

  @override
  ConsumerState<EditServicePage> createState() => _EditServicePageState();
}

class _EditServicePageState extends ConsumerState<EditServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _timeController = TextEditingController();
  final _dateController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _participantsCount = 1;
  String _visibilityOption = 'Mọi người';
  List<String> _selectedSkillIds = [];
  Map<String, String> _selectedSkillsMap = {};
  List<String> _selectedImages = []; // Danh sách (cả URL cũ và file local mới)
  bool _isFormattingTime = false;
  bool _isFormattingDuration = false;
  bool _isFormattingDate = false;
  String? _dateError;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _hydrateFormFromService(widget.service);
  }
  void _confirmAndUpdate() async {
    if (_isLoading) return;
    final bool? didConfirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Xác nhận cập nhật',
              style: TextStyle(
                  color: Color(0xFF003E77),
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          content: const Text(
            'Bạn có chắc chắn muốn cập nhật yêu cầu này không?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Trả về false
              child: const Text(
                'Hủy',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Trả về true
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
  void _hydrateFormFromService(Service service) {
    _titleController.text = service.title;
    _addressController.text = service.place;
    _descriptionController.text = service.description ?? '';
    _participantsCount = service.slot;
    _visibilityOption = _mapVisibilityFromModel(service.visibility);
    if (service.skillIds != null && service.skillNames != null) {
      _selectedSkillIds = List<String>.from(service.skillIds!);
      _selectedSkillsMap = Map.fromIterables(
        service.skillIds!,
        service.skillNames!,
      );
    }
    _selectedImages = List<String>.from(service.serviceImages ?? []);
    if (service.preferredStart != null) {
      final dt = service.preferredStart!;
      _timeController.text =
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      _dateController.text =
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }
    _durationController.text = _formatDurationFromSeconds(service.time);
  }
  String _formatDurationFromSeconds(int seconds) {
    final duration = Duration(seconds: seconds);
    final hh = duration.inHours.toString().padLeft(2, '0');
    final mm = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }
  String _mapVisibilityFromModel(String visibility) {
    switch (visibility) {
      case 'private':
        return 'Cá nhân';
      case 'friends':
        return 'Bạn bè';
      case 'public':
      default:
        return 'Mọi người';
    }
  }
  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _timeController.dispose();
    _dateController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  IconData _getIconForOption(String option) {
    switch (option) {
      case 'Mọi người':
        return Icons.groups;
      case 'Bạn bè':
        return Icons.people_alt;
      case 'Cá nhân':
      default:
        return Icons.person;
    }
  }
  @override
  Widget build(BuildContext context) {
    debugPrint('Selected Skills Map: $_selectedSkillsMap');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF003E77),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: const Text('Chỉnh sửa yêu cầu'),
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
                    _buildCardHeader(title: 'Chỉnh sửa yêu cầu'),
                    const SizedBox(height: 24),
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
                    _buildSectionTitle('Thời lượng:'),
                    TextFormField(
                      controller: _durationController,
                      decoration: _buildInputDecoration('hh:mm:ss'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập thời lượng';
                        }
                        final parts = value.split(':');
                        if (parts.length != 3) return 'Định dạng hh:mm:ss';
                        if (int.tryParse(parts[0]) == null ||
                            int.tryParse(parts[1]) == null ||
                            int.tryParse(parts[2]) == null) {
                          return 'Giờ, phút, giây phải là số';
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
                    _buildSectionTitle('Chuyên môn:'),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: [
                        ..._selectedSkillsMap.entries
                            .map((entry) => InputChip(
                          label: Text(entry.value),
                          labelStyle: TextStyle(
                              color: Color(0xFF000000), fontSize: 16),
                          backgroundColor: Color(0xFFE0DC06),
                          onDeleted: () {
                            setState(() {
                              _selectedSkillIds.remove(entry.key);
                              _selectedSkillsMap.remove(entry.key);
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
                    _buildSectionTitle('Ảnh:'),
                    _buildImagePicker(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _confirmAndUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                            : const Text(
                          'Cập nhật',
                          style: TextStyle(
                            fontSize: 20,
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
  Widget _buildCardHeader({required String title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/images/avatar_1.png'),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(_getIconForOption(_visibilityOption),
                color: Colors.blue.shade800, size: 26),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              color: Colors.white,
              initialValue: _visibilityOption,
              onSelected: (val) {
                setState(() {
                  _visibilityOption = val;
                });
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'Cá nhân',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.grey.shade700, size: 22),
                      const SizedBox(width: 10),
                      const Text('Cá nhân'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Mọi người',
                  child: Row(
                    children: [
                      Icon(Icons.groups, color: Colors.grey.shade700, size: 22),
                      const SizedBox(width: 10),
                      const Text('Mọi người'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Bạn bè',
                  child: Row(
                    children: [
                      Icon(Icons.people_alt,
                          color: Colors.grey.shade700, size: 22),
                      const SizedBox(width: 10),
                      const Text('Bạn bè'),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Text(
                      _visibilityOption,
                      style:
                      TextStyle(color: Colors.grey.shade800, fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ..._selectedImages.map((url) => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 110,
                height: 110,
                color: Colors.grey.shade200,
                child: url.startsWith('http')
                    ? Image.network(
                  url,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey.shade600,
                        ),
                      ),
                )
                    : Image.file(
                  File(url),
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),
            )),
            GestureDetector(
              onTap: () => _showImageSourceOptions(context),
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(child: Icon(Icons.add_a_photo, size: 30)),
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

  Future<void> _showSkillSelector(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    Map<String, String> allSkills;
    try {
      final skillsList = await ref.read(skillsProvider.future);
      allSkills = {for (var skill in skillsList) skill.id: skill.name};
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải danh sách kỹ năng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
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
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: allSkills.entries.map((e) {
                    return CheckboxListTile(
                      value: selected[e.key] ?? false,
                      title: Text(e.value),
                      onChanged: (val) {
                        setDialogState(() {
                          selected[e.key] = val ?? false;
                        });
                      },
                    );
                  }).toList(),
                );
              },
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
                    _selectedSkillsMap = {
                      for (var id in _selectedSkillIds) id: allSkills[id]!
                    };
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

  int _parseDurationToSeconds(String hhmmss) {
    final parts = hhmmss.split(':');
    if (parts.length != 3) {
      return 0;
    }
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final s = int.tryParse(parts[2]) ?? 0;
    return (h * 3600) + (m * 60) + s;
  }
  Future<List<String>> _uploadImages(List<String> localPaths) async {
    final List<String> downloadUrls = [];
    if (localPaths.isEmpty) {
      return downloadUrls;
    }
    final storageRef = FirebaseStorage.instance.ref();
    await Future.wait(
      localPaths.map((localPath) async {
        try {
          final file = File(localPath);
          final fileName =
              'service_images/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

          final uploadRef = storageRef.child(fileName);

          final uploadTask = uploadRef.putFile(file);
          final snapshot = await uploadTask.whenComplete(() {});

          final downloadUrl = await snapshot.ref.getDownloadURL();
          downloadUrls.add(downloadUrl);
        } catch (e) {
          debugPrint('Lỗi upload file: $localPath - Lỗi: $e');
        }
      }),
    );

    return downloadUrls;
  }
  void _updateRequest() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      try {
        final title = _titleController.text;
        final address = _addressController.text;
        final durationString = _durationController.text;
        final slot = _participantsCount;
        final skills = _selectedSkillIds;
        final visibility = _visibilityOption == 'Cá nhân'
            ? 'private'
            : (_visibilityOption == 'Bạn bè' ? 'friends' : 'public');
        final timeParam = _parseDurationToSeconds(durationString);
        final regionCode = "NULL"; // Giữ như cũ
        final place = address;
        String preferredStartTime;
        final DateTime? dateObj = parseDdMmYyyy(_dateController.text);
        if (dateObj != null) {
          final timeParts = _timeController.text.split(':');
          final h = int.tryParse(timeParts[0]) ?? 0;
          final m = int.tryParse(timeParts[1]) ?? 0;
          final combinedDateTime =
          DateTime(dateObj.year, dateObj.month, dateObj.day, h, m);
          preferredStartTime = combinedDateTime.toUtc().toIso8601String();
        } else {
          preferredStartTime = DateTime.now().toUtc().toIso8601String();
        }
        final List<String> existingUrls =
        _selectedImages.where((img) => img.startsWith('http')).toList();
        final List<String> newLocalPaths =
        _selectedImages.where((img) => !img.startsWith('http')).toList();
        final List<String> newUploadedUrls = await _uploadImages(newLocalPaths);
        final List<String> finalImageUrls = existingUrls + newUploadedUrls;
        final repo = ref.read(serviceRepositoryProvider);
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        ref.invalidate(serviceByIdProvider(widget.service.id));
        Navigator.of(context).pop();
      } catch (e, st) {
        debugPrint('Lỗi cập nhật job: $e\n$st');
        if (!mounted) return;
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  String _normalizeTime(String fourDigits) {
    final h = int.tryParse(fourDigits.substring(0, 2)) ?? 0;
    final mRaw = int.tryParse(fourDigits.substring(2, 4)) ?? 0;
    final carryH = mRaw ~/ 60;
    final m = mRaw % 60;
    final hh = h + carryH;
    return '${hh.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
  String _normalizeDuration(String sixDigits) {
    final h = int.tryParse(sixDigits.substring(0, 2)) ?? 0;
    var m = int.tryParse(sixDigits.substring(2, 4)) ?? 0;
    var s = int.tryParse(sixDigits.substring(4, 6)) ?? 0;
    final carryM = s ~/ 60;
    s = s % 60;
    m += carryM;
    final carryH = m ~/ 60;
    m = m % 60;
    final hh = h + carryH;
    return '${hh.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  bool isLeapYear(int y) {
    if (y % 400 == 0) return true;
    if (y % 100 == 0) return false;
    return y % 4 == 0;
  }
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
  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.of(ctx).pop();
                final status = await Permission.camera.request();
                if (!status.isGranted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Quyền camera bị từ chối'),
                  ));
                  return;
                }
                try {
                  final XFile? picked = await ImagePicker()
                      .pickImage(source: ImageSource.camera, imageQuality: 85);
                  if (picked != null) {
                    setState(() => _selectedImages.add(picked.path));
                  }
                } catch (e) {
                  debugPrint('Camera pick error: $e');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Thư viện'),
              onTap: () async {
                Navigator.of(ctx).pop();
                PermissionStatus status = PermissionStatus.denied;
                if (Platform.isAndroid) {
                  status = await Permission.storage.request();
                  if (!status.isGranted) {
                    status = await Permission.photos.request();
                  }
                } else if (Platform.isIOS) {
                  status = await Permission.photos.request();
                } else {
                  status = await Permission.storage.request();
                }
                final allowed = status.isGranted || status.isLimited;
                if (!allowed) {
                  final open = await showDialog<bool>(
                    context: context,
                    builder: (dctx) => AlertDialog(
                      title: const Text('Quyền bị từ chối'),
                      content: const Text(
                          'Ứng dụng cần quyền truy cập thư viện ảnh để chọn ảnh. Bạn có muốn mở Cài đặt để cấp quyền?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(dctx).pop(false),
                            child: const Text('Hủy')),
                        TextButton(
                            onPressed: () => Navigator.of(dctx).pop(true),
                            child: const Text('Mở Cài đặt')),
                      ],
                    ),
                  );
                  if (open == true) openAppSettings();
                  return;
                }
                try {
                  final XFile? picked = await ImagePicker()
                      .pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (picked != null) {
                    setState(() => _selectedImages.add(picked.path));
                  }
                } catch (e) {
                  debugPrint('Gallery pick error: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/domain/profile.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final Profile profile;
  const EditProfilePage({Key? key, required this.profile}) : super(key: key);

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _facebookCtrl;
  late final TextEditingController _instaCtrl;
  late final TextEditingController _tiktokCtrl;
  late final TextEditingController _regionCtrl;
  late final TextEditingController _workCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _studyCtrl;
  DateTime? _birthDate;
  late final TextEditingController _birthCtrl;
  // visibility toggles for each field
  bool _showRegion = true;
  bool _showWork = true;
  bool _showStreet = true;
  bool _showBirthDate = true;
  bool _showStudy = true;
  bool _showFacebook = true;
  bool _showInstagram = true;
  bool _showTiktok = true;
  // editing mode flags (fields are read-only until the edit button is pressed)
  bool _editingStreet = false;
  bool _editingBirthDate = false;
  // backups used for per-field cancel
  final Map<String, String> _backupText = {};
  final Map<String, DateTime?> _backupDate = {};

  // focus nodes to support per-field "edit" button focusing
  late final FocusNode _nameFocus;
  late final FocusNode _descFocus;
  late final FocusNode _regionFocus;
  late final FocusNode _workFocus;
  late final FocusNode _streetFocus;
  late final FocusNode _studyFocus;
  late final FocusNode _facebookFocus;
  late final FocusNode _instaFocus;
  late final FocusNode _tiktokFocus;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _descCtrl = TextEditingController(text: widget.profile.description ?? '');
    _facebookCtrl = TextEditingController(text: widget.profile.socialNetwork?['facebook'] ?? '');
    _instaCtrl = TextEditingController(text: widget.profile.socialNetwork?['instagram'] ?? '');
    _tiktokCtrl = TextEditingController(text: widget.profile.socialNetwork?['tiktok'] ?? '');
    _regionCtrl = TextEditingController(text: widget.profile.regionId ?? '');
    _workCtrl = TextEditingController(text: widget.profile.workAddress ?? '');
    _streetCtrl = TextEditingController(text: widget.profile.street ?? '');
    _studyCtrl = TextEditingController(text: widget.profile.studyAddress ?? '');
    _birthDate = widget.profile.birthDate;
  _birthCtrl = TextEditingController(text: _birthDate == null ? '' : '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}');
    // init focus nodes
    _nameFocus = FocusNode();
    _descFocus = FocusNode();
    _regionFocus = FocusNode();
    _workFocus = FocusNode();
    _streetFocus = FocusNode();
    _studyFocus = FocusNode();
    _facebookFocus = FocusNode();
    _instaFocus = FocusNode();
    _tiktokFocus = FocusNode();
  // when a field gains/loses focus we rebuild so UI can show the inline
  // editor (we treat focus as entering edit mode)
  _nameFocus.addListener(() => setState(() {}));
  _descFocus.addListener(() => setState(() {}));
  _regionFocus.addListener(() => setState(() {}));
  _workFocus.addListener(() => setState(() {}));
  _streetFocus.addListener(() => setState(() {}));
  _studyFocus.addListener(() => setState(() {}));
  _facebookFocus.addListener(() => setState(() {}));
  _instaFocus.addListener(() => setState(() {}));
  _tiktokFocus.addListener(() => setState(() {}));
  _descFocus.addListener(() => setState(() {}));
    // initial visibility from profile if desired (default true)
    _showRegion = true;
    _showWork = true;
    _showStreet = true;
    _showBirthDate = true;
    _showStudy = true;
    _showFacebook = _facebookCtrl.text.trim().isNotEmpty;
    _showInstagram = _instaCtrl.text.trim().isNotEmpty;
    _showTiktok = _tiktokCtrl.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _facebookCtrl.dispose();
    _instaCtrl.dispose();
    _tiktokCtrl.dispose();
    _regionCtrl.dispose();
    _workCtrl.dispose();
    _streetCtrl.dispose();
    _studyCtrl.dispose();
    // dispose focus nodes
    _nameFocus.dispose();
    _descFocus.dispose();
    _regionFocus.dispose();
    _workFocus.dispose();
    _streetFocus.dispose();
    _studyFocus.dispose();
    _facebookFocus.dispose();
    _instaFocus.dispose();
    _tiktokFocus.dispose();
    _birthCtrl.dispose();
    super.dispose();
  }

  void _save() {
    // Return a map of changed fields to the caller. Persistence can be handled
    // by the caller or by a provider in a follow-up change.
    final changes = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'regionId': _regionCtrl.text.trim(),
      'workAddress': _workCtrl.text.trim(),
      'street': _streetCtrl.text.trim(),
      'studyAddress': _studyCtrl.text.trim(),
      'birthDate': _birthDate?.toIso8601String(),
      'social': {
        if (_facebookCtrl.text.trim().isNotEmpty) 'facebook': _facebookCtrl.text.trim(),
        if (_instaCtrl.text.trim().isNotEmpty) 'instagram': _instaCtrl.text.trim(),
        if (_tiktokCtrl.text.trim().isNotEmpty) 'tiktok': _tiktokCtrl.text.trim(),
      },
      'visibility': {
        'region': _showRegion,
        'work': _showWork,
        'street': _showStreet,
        'birthDate': _showBirthDate,
        'study': _showStudy,
        'facebook': _showFacebook,
        'instagram': _showInstagram,
        'tiktok': _showTiktok,
      }
    };
    Navigator.of(context).pop(changes);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 25);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() {
      _birthDate = picked;
      _birthCtrl.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFieldWithToggle(
                fieldKey: 'name',
                label: 'Họ và tên',
                controller: _nameCtrl,
                focusNode: _nameFocus,
                isVisible: true,
                isEditing: false,
                onToggle: (_) {},
                onEdit: () {
                  _backupText['name'] = _nameCtrl.text;
                  Future.delayed(const Duration(milliseconds: 80), () => FocusScope.of(context).requestFocus(_nameFocus));
                },
              ),
              const SizedBox(height: 12),
              // description area - show plain text until user taps edit
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(child: Text('Mô tả ngắn', style: TextStyle(fontWeight: FontWeight.w500))),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () {
                              _backupText['description'] = _descCtrl.text;
                              Future.delayed(const Duration(milliseconds: 80), () => FocusScope.of(context).requestFocus(_descFocus));
                            },
                            splashRadius: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_descFocus.hasFocus) ...[
                        TextFormField(
                          controller: _descCtrl,
                          focusNode: _descFocus,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _descCtrl.text = _backupText['description'] ?? _descCtrl.text;
                                  FocusScope.of(context).unfocus();
                                  _backupText.remove('description');
                                });
                              },
                              child: const Text('Hủy'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  FocusScope.of(context).unfocus();
                                  _backupText.remove('description');
                                });
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D4C7B)),
                              child: const Text('Lưu'),
                            ),
                          ],
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                          child: Text(
                            _descCtrl.text.trim().isEmpty ? 'Chưa có' : _descCtrl.text.trim(),
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // region with toggle + edit
              _buildFieldWithToggle(
                fieldKey: 'region',
                label: 'Đến từ',
                controller: _regionCtrl,
                focusNode: _regionFocus,
                isVisible: _showRegion,
                isEditing: false,
                onToggle: (v) => setState(() => _showRegion = v),
                onEdit: () {
                  _backupText['region'] = _regionCtrl.text;
                  setState(() => _showRegion = true);
                  Future.delayed(const Duration(milliseconds: 80), () => FocusScope.of(context).requestFocus(_regionFocus));
                },
              ),
              const SizedBox(height: 8),
              // work with toggle + edit
              _buildFieldWithToggle(
                fieldKey: 'work',
                label: 'Làm việc tại',
                controller: _workCtrl,
                focusNode: _workFocus,
                isVisible: _showWork,
                isEditing: false,
                onToggle: (v) => setState(() => _showWork = v),
                onEdit: () {
                  _backupText['work'] = _workCtrl.text;
                  setState(() => _showWork = true);
                  Future.delayed(const Duration(milliseconds: 80), () => FocusScope.of(context).requestFocus(_workFocus));
                },
              ),
              const SizedBox(height: 8),
              // Địa chỉ (full-width) with toggle + edit — initially read-only until edit pressed
              _buildFieldWithToggle(
                fieldKey: 'street',
                label: 'Địa chỉ',
                controller: _streetCtrl,
                focusNode: _streetFocus,
                isVisible: _showStreet,
                isEditing: _editingStreet,
                onToggle: (v) => setState(() => _showStreet = v),
                onEdit: () {
                  _backupText['street'] = _streetCtrl.text;
                  setState(() {
                    _showStreet = true;
                    _editingStreet = true;
                  });
                  Future.delayed(const Duration(milliseconds: 80), () => FocusScope.of(context).requestFocus(_streetFocus));
                },
              ),
              const SizedBox(height: 8),
              // Ngày sinh (full-width) with toggle + edit — tapping edit enables date editing
              _buildDateFieldWithToggle(
                fieldKey: 'birthDate',
                label: 'Ngày sinh',
                date: _birthDate,
                isVisible: _showBirthDate,
                isEditing: _editingBirthDate,
                onToggle: (v) => setState(() => _showBirthDate = v),
                onTap: () {
                  if (_editingBirthDate) _pickBirthDate();
                },
                onEdit: () {
                  _backupDate['birthDate'] = _birthDate;
                  setState(() {
                    _showBirthDate = true;
                    _editingBirthDate = true;
                  });
                  // open picker when entering edit mode
                  Future.delayed(const Duration(milliseconds: 60), () => _pickBirthDate());
                },
              ),
              const SizedBox(height: 8),
              _buildFieldWithToggle(
                fieldKey: 'study',
                label: 'Học tại',
                controller: _studyCtrl,
                focusNode: _studyFocus,
                isVisible: _showStudy,
                isEditing: false,
                onToggle: (v) => setState(() => _showStudy = v),
                onEdit: () {
                  _backupText['study'] = _studyCtrl.text;
                  setState(() => _showStudy = true);
                  Future.delayed(const Duration(milliseconds: 80), () => FocusScope.of(context).requestFocus(_studyFocus));
                },
              ),
              const SizedBox(height: 16),
              const Text('Mạng xã hội', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildFieldWithToggle(
                fieldKey: 'facebook',
                label: 'Facebook',
                controller: _facebookCtrl,
                focusNode: _facebookFocus,
                prefix: 'facebook: ',
                isVisible: _showFacebook,
                isEditing: false,
                onToggle: (v) => setState(() => _showFacebook = v),
                onEdit: () {
                  _backupText['facebook'] = _facebookCtrl.text;
                  setState(() => _showFacebook = true);
                  Future.delayed(const Duration(milliseconds: 80), () => FocusScope.of(context).requestFocus(_facebookFocus));
                },
              ),
              const SizedBox(height: 8),
              _buildFieldWithToggle(
                fieldKey: 'instagram',
                label: 'Instagram',
                controller: _instaCtrl,
                focusNode: _instaFocus,
                prefix: 'insta: ',
                isVisible: _showInstagram,
                isEditing: false,
                onToggle: (v) => setState(() => _showInstagram = v),
                onEdit: () {
                  _backupText['instagram'] = _instaCtrl.text;
                  setState(() => _showInstagram = true);
                  Future.delayed(const Duration(milliseconds: 80), () => FocusScope.of(context).requestFocus(_instaFocus));
                },
              ),
              const SizedBox(height: 8),
              _buildFieldWithToggle(
                fieldKey: 'tiktok',
                label: 'TikTok',
                controller: _tiktokCtrl,
                focusNode: _tiktokFocus,
                prefix: 'tiktok: ',
                isVisible: _showTiktok,
                isEditing: false,
                onToggle: (v) => setState(() => _showTiktok = v),
                onEdit: () {
                  _backupText['tiktok'] = _tiktokCtrl.text;
                  setState(() => _showTiktok = true);
                  Future.delayed(const Duration(milliseconds: 80), () => FocusScope.of(context).requestFocus(_tiktokFocus));
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Lưu thay đổi'),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D4C7B), foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldWithToggle({
    required String fieldKey,
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isVisible,
    required bool isEditing,
    required ValueChanged<bool> onToggle,
    required VoidCallback onEdit,
    String? prefix,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Hiển thị', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    Switch(
                      value: isVisible,
                      onChanged: onToggle,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    // when in edit mode (or focused) show Save/Cancel, otherwise show edit
                    if (isEditing || focusNode.hasFocus) ...[
                      IconButton(
                        icon: const Icon(Icons.check, size: 18),
                        onPressed: () {
                          setState(() {
                            // commit: simply exit edit mode; controller already contains value
                            if (fieldKey == 'street') _editingStreet = false;
                            FocusScope.of(context).unfocus();
                            _backupText.remove(fieldKey);
                          });
                        },
                        splashRadius: 18,
                      ),
                    ] else ...[
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: onEdit,
                        splashRadius: 18,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (isVisible) ...[
              const SizedBox(height: 8),
              // show editor when explicit editing flag is set OR when the
              // corresponding focus node has focus (user pressed the edit icon)
              if (isEditing || focusNode.hasFocus) ...[
                TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(labelText: label, prefixText: prefix, border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          // cancel
                          controller.text = _backupText[fieldKey] ?? controller.text;
                          if (fieldKey == 'street') _editingStreet = false;
                          FocusScope.of(context).unfocus();
                          _backupText.remove(fieldKey);
                        });
                      },
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // save per-field
                          if (fieldKey == 'street') _editingStreet = false;
                          FocusScope.of(context).unfocus();
                          _backupText.remove(fieldKey);
                        });
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D4C7B), foregroundColor: Colors.white),
                      child: const Text('Lưu'),
                    ),
                  ],
                ),
              ] else ...[
                // show plain text when not in edit mode
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  child: Text(
                    controller.text.trim().isEmpty ? 'Chưa có' : controller.text.trim(),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateFieldWithToggle({
    required String fieldKey,
    required String label,
    required DateTime? date,
    required bool isVisible,
    required bool isEditing,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTap,
    required VoidCallback onEdit,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Hiển thị', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    Switch(
                      value: isVisible,
                      onChanged: onToggle,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    if (isEditing) ...[
                      IconButton(
                        icon: const Icon(Icons.check, size: 18),
                        onPressed: () {
                          setState(() {
                            _editingBirthDate = false;
                            FocusScope.of(context).unfocus();
                            _backupDate.remove(fieldKey);
                          });
                        },
                        splashRadius: 18,
                      ),
                    ] else ...[
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: onEdit,
                        splashRadius: 18,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (isVisible) ...[
              const SizedBox(height: 8),
              if (isEditing) ...[
                // read-only text field that shows the selected date and opens picker on tap
                TextFormField(
                  controller: _birthCtrl,
                  readOnly: true,
                  onTap: onTap,
                  decoration: InputDecoration(
                    labelText: label,
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today, size: 18),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          // cancel: restore original
                          _birthDate = _backupDate[fieldKey];
                          _birthCtrl.text = _birthDate == null ? '' : '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}';
                          _editingBirthDate = false;
                          _backupDate.remove(fieldKey);
                        });
                      },
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // save
                          _editingBirthDate = false;
                          _backupDate.remove(fieldKey);
                        });
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D4C7B), foregroundColor: Colors.white),
                      child: const Text('Lưu'),
                    ),
                  ],
                ),
              ] else
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  child: Text(
                    date == null ? 'Chưa có' : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:intl/intl.dart'; // <--- THÊM IMPORT NÀY

enum NotificationType { transferOut, transferIn, systemAlert }

NotificationType _mapType(String s) {
  switch (s) {
    case 'TRANSFER_OUT':
      return NotificationType.transferOut;
    case 'TRANSFER_IN':
      return NotificationType.transferIn;
    default:
      return NotificationType.systemAlert;
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool read;
  final Map<String, dynamic> data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    required this.read,
    required this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) {
    final d = (j['data'] as Map?)?.map((k, v) => MapEntry('$k', v)) ?? <String, dynamic>{};
    return AppNotification(
      id: j['id'] as String,
      title: j['title'] as String,
      body: j['body'] as String,
      type: _mapType(j['type'] as String),
      createdAt: DateTime.parse(j['created_at'] as String),
      read: (j['read'] as bool?) ?? false,
      data: d,
    );
  }

  // ===== BẮT ĐẦU PHẦN THÊM VÀO =====

  /// 'message' trong widget NotificationItem sẽ dùng 'body'
  String get message => body;

  /// 'note' trong widget TransactionCard sẽ lấy từ data (nếu backend có gửi)
  String? get note {
    return data['note'] as String?;
  }

  /// 'change' trong TransactionCard sẽ dùng 'body'
  String get change => body;

  /// 'account' và 'balance' API không trả về, nên ta trả về rỗng
  String get account => '';
  String get balance => '';

  // --- Format ngày giờ ---
  static final _dateFormatter = DateFormat('dd/MM/yyyy');
  static final _timeFormatter = DateFormat('HH:mm');

  String get dateText {
    return _dateFormatter.format(createdAt);
  }

  String get timeText {
    return _timeFormatter.format(createdAt);
  }

  // ===== HÀM COPYWITH ĐỂ DÙNG TRONG PROVIDER =====
  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? createdAt,
    bool? read,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
      data: data ?? this.data,
    );
  }
// ===== KẾT THÚC PHẦN THÊM VÀO =====
}
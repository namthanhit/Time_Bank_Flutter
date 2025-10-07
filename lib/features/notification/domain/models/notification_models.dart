import 'package:equatable/equatable.dart';

enum AppNotificationType { activity, general }

class AppNotification extends Equatable {
  final String id;
  final AppNotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;

  // activity-only
  final String? account;
  final String? change;
  final String? balance;
  final String? note;
  final String? timeText;
  final String? dateText;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.account,
    this.change,
    this.balance,
    this.note,
    this.timeText,
    this.dateText,
  });

  @override
  List<Object?> get props =>
      [id, type, title, message, createdAt, account, change, balance, note, timeText, dateText];
}

import '../../notification/domain/models/notification_models.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> fetch(AppNotificationType type);
}

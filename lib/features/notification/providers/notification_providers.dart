import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_notification_repository.dart';
import '../data/notification_repository.dart';
import '../domain/models/notification_models.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
      (ref) => MockNotificationRepository(),
);

// Hai FutureProvider tách theo tab
final activityNotificationsProvider = FutureProvider<List<AppNotification>>(
      (ref) => ref.watch(notificationRepositoryProvider).fetch(AppNotificationType.activity),
);

final generalNotificationsProvider = FutureProvider<List<AppNotification>>(
      (ref) => ref.watch(notificationRepositoryProvider).fetch(AppNotificationType.general),
);

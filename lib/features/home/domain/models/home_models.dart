import 'package:flutter/foundation.dart';

@immutable
class HomeSummary {
  final double rating;
  final String timeBalance;
  const HomeSummary({required this.rating, required this.timeBalance});

  factory HomeSummary.fromJson(Map<String, dynamic> j) => HomeSummary(
    rating: (j['rating'] as num).toDouble(),
    timeBalance: j['time_balance'] as String,
  );
}

@immutable
class Activity {
  final String user;
  final String timeAgo;
  final String title;
  final String taskTime;   // "HH:mm dd/MM/yyyy"
  final String duration;   // "HH:mm:ss"
  final String location;
  final List<String> tags; // <-- thay cho tag1/tag2
  final String status;

  const Activity({
    required this.user,
    required this.timeAgo,
    required this.title,
    required this.taskTime,
    required this.duration,
    required this.location,
    required this.tags,
    required this.status,
  });

  factory Activity.fromJson(Map<String, dynamic> j) {
    // Chấp nhận nhiều format thô khác nhau từ API:
    // - ["Nội trợ", "Việc nhà"]
    // - "Nội trợ, Việc nhà"
    // - [{"name":"Nội trợ"}, {"name":"Việc nhà"}]
    List<String> parseTags(dynamic raw) {
      if (raw == null) return const [];
      if (raw is List) {
        if (raw.isEmpty) return const [];
        if (raw.first is String) return raw.cast<String>();
        if (raw.first is Map) {
          return raw
              .map((e) => (e as Map)['name'] ?? (e['label'] ?? ''))
              .where((s) => (s is String) && s.trim().isNotEmpty)
              .cast<String>()
              .toList();
        }
      }
      if (raw is String) {
        return raw
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return const [];
    }

    return Activity(
      user: j['user'] as String,
      timeAgo: j['time_ago'] as String,
      title: j['title'] as String,
      taskTime: j['task_time'] as String,
      duration: j['duration'] as String,
      location: j['location'] as String,
      tags: parseTags(j['tags'] ?? j['tag_list'] ?? [j['tag1'], j['tag2']]),
      status: j['status'] as String,
    );
  }
}

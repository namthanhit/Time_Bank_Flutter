import 'package:flutter/foundation.dart';

@immutable
class HomeSummary {
  final double rating;
  /// Ví dụ: "20:45:30"
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
  final String tag1;
  final String tag2;
  final String status;

  const Activity({
    required this.user,
    required this.timeAgo,
    required this.title,
    required this.taskTime,
    required this.duration,
    required this.location,
    required this.tag1,
    required this.tag2,
    required this.status,
  });

  factory Activity.fromJson(Map<String, dynamic> j) => Activity(
    user: j['user'] as String,
    timeAgo: j['time_ago'] as String,
    title: j['title'] as String,
    taskTime: j['task_time'] as String,
    duration: j['duration'] as String,
    location: j['location'] as String,
    tag1: j['tag1'] as String,
    tag2: j['tag2'] as String,
    status: j['status'] as String,
  );
}

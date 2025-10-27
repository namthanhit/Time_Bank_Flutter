// lib/features/service/domain/models/service.dart
// Updated to align with the new database schema: string IDs and new fields
class Service {
  final String id;
  final String userId;
  final String? skillId; // optional: some APIs may still return skill relation
  final List<String>? skillIds; // support multiple skills per service
  final String title;
  final String? description;
  final String? regionCode;
  final String place;
  final DateTime? preferredStart;
  final int time; // total time in minutes
  final int slot; // slot length in minutes (default 60)
  final String visibility; // e.g. 'public', 'friends', 'hidden'
  final String status; // e.g. 'open', 'matched', 'completed'
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Optional UI-friendly fields (computed or joined from other endpoints)
  final double? ratingAvg;
  final int? ratingCount;
  final String? providerName;
  final String? providerAvatar;
  final String? providerSpecialization; // backward-compatible
  final List<String>? serviceImages;

  // Backwards-compatible constructor: accept old names (minSlotMinutes, isPublic)
  Service({
    required this.id,
    required this.userId,
    this.skillId,
    this.skillIds,
    required this.title,
    this.description,
    this.regionCode,
    this.place = '',
    this.preferredStart,
    int? time,
    int? slot,
    String? visibility,
    String? status,
    required this.createdAt,
    this.updatedAt,
    this.ratingAvg,
    this.ratingCount,
    this.providerName,
    this.providerAvatar,
    this.providerSpecialization,
    this.serviceImages,
    // legacy fields
    int? minSlotMinutes,
    bool? isPublic,
  })  : time = time ?? minSlotMinutes ?? 0,
        slot = slot ?? minSlotMinutes ?? 60,
        visibility = visibility ?? (isPublic == true ? 'public' : 'hidden'),
        status = status ?? 'open';

  factory Service.fromJson(Map<String, dynamic> json) {
    // Support both numeric and string IDs from different backends
    String parseId(dynamic v) => v == null ? '' : v.toString();

    // Some APIs return slot/time under different keys; be defensive
    int parseInt(dynamic v, [int fallback = 0]) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? fallback;
      if (v is double) return v.toInt();
      return fallback;
    }

    DateTime? parseDateTime(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    // service images may be provided as nested objects or list of strings
    List<String>? images;
    if (json['service_images'] is List) {
      images = (json['service_images'] as List)
          .map((e) => e == null ? '' : e.toString())
          .where((s) => s.isNotEmpty)
          .toList();
      if (images.isEmpty) images = null;
    }

    return Service(
      id: parseId(json['id'] ?? json['service_id']),
      userId:
          parseId(json['user_id'] ?? json['provider_id'] ?? json['owner_id']),
      // parse skill ids: accept 'skill_id' as single value or 'skill_ids' as list
      skillId: json['skill_id'] != null ? json['skill_id'].toString() : null,
      skillIds: (() {
        final v = json['skill_ids'] ?? json['skill_id'];
        if (v == null) return null;
        if (v is List) return v.map((e) => e.toString()).toList();
        if (v is String) return [v];
        return [v.toString()];
      })(),
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      regionCode: json['region_code'] as String?,
      place: json['place'] as String? ?? '',
      preferredStart: parseDateTime(json['preferred_start']),
      time: parseInt(
          json['time'], parseInt(json['secs'] ?? json['secs_booked'] ?? 0)),
      slot: parseInt(json['slot'], 60),
      visibility: (json['visibility'] ?? 'public').toString(),
      status: (json['status'] ?? 'open').toString(),
      createdAt: parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDateTime(json['updated_at']),
      ratingAvg: json['rating_avg'] != null
          ? (json['rating_avg'] as num).toDouble()
          : null,
      ratingCount: json['rating_count'] is int
          ? json['rating_count'] as int
          : (json['rating_count'] is String
              ? int.tryParse(json['rating_count'])
              : null),
      providerName: json['provider_name'] as String?,
      providerAvatar: json['provider_avatar'] as String?,
      providerSpecialization: json['provider_specialization'] as String?,
      serviceImages: images,
      // support legacy keys
      minSlotMinutes: json['min_slot_minutes'] is int
          ? json['min_slot_minutes'] as int
          : (json['min_slot_minutes'] is String
              ? int.tryParse(json['min_slot_minutes'])
              : null),
      isPublic: json['isPublic'] is bool
          ? json['isPublic'] as bool
          : (json['is_public'] == true ||
              (json['visibility'] ?? '') == 'public'),
    );
  }

  // Backwards-compatible getters used by older UI code
  int get minSlotMinutes => slot;
  bool get isPublic => visibility == 'public';

  // Backward-compatible accessor: return comma-joined providerSpecialization
  // or the raw skill IDs joined. UI layer should map IDs -> names using a
  // repository or a dedicated lookup. Keeping domain model free of mock data.
  String? get providerSpecializationValue {
    final ids = skillIds ?? (skillId != null ? [skillId!] : null);
    if (ids != null && ids.isNotEmpty) {
      return ids.join(', ');
    }
    return providerSpecialization;
  }
}

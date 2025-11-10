class Offer {
  final String id;
  final String note;
  final String status;
  final DateTime createdAt;

  final String jobId;
  final String jobTitle;
  final String jobDescription;
  final String regionCode;
  final String place;
  final DateTime preferredStart;
  final int time;
  final int slot;
  final String visibility;
  final String jobStatus;
  final DateTime jobCreatedAt;

  final String jobOwnerId;
  final String jobOwnerName;
  final String? jobOwnerAvatar;

  final List<Map<String, dynamic>> skills;
  final List<Map<String, dynamic>> offers;

  final String offerUserId;
  final String offerUserName;
  final String? offerUserAvatar;

  Offer({
    required this.id,
    required this.note,
    required this.status,
    required this.createdAt,
    required this.jobId,
    required this.jobTitle,
    required this.jobDescription,
    required this.regionCode,
    required this.place,
    required this.preferredStart,
    required this.time,
    required this.slot,
    required this.visibility,
    required this.jobStatus,
    required this.jobCreatedAt,
    required this.jobOwnerId,
    required this.jobOwnerName,
    required this.jobOwnerAvatar,
    required this.skills,
    required this.offers,
    required this.offerUserId,
    required this.offerUserName,
    required this.offerUserAvatar,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    final job = json;
    final offers = job['offers'] as List;

    throw UnimplementedError('Use Offer.fromJobJsonList() instead.');
  }

  static List<Offer> fromJobJsonList(Map<String, dynamic> jobJson) {
    final job = jobJson;
    final offers = (job['offers'] as List?) ?? [];

    return offers.map((offerJson) {
      final user = offerJson['user'] ?? {};
      final jobOwner = job['user'] ?? {};
      return Offer(
        id: offerJson['id'],
        note: offerJson['note'],
        status: offerJson['status'],
        createdAt: DateTime.parse(offerJson['created_at']),
        jobId: job['id'],
        jobTitle: job['title'],
        jobDescription: job['description'],
        regionCode: job['region_code'],
        place: job['place'],
        preferredStart: DateTime.parse(job['preferred_start']),
        time: job['time'],
        slot: job['slot'],
        visibility: job['visibility'],
        jobStatus: job['status'],
        jobCreatedAt: DateTime.parse(job['created_at']),
        jobOwnerId: jobOwner['id'],
        jobOwnerName: jobOwner['full_name'],
        jobOwnerAvatar: jobOwner['avatar_url'],
        skills: List<Map<String, dynamic>>.from(job['skills']),
        offers: List<Map<String, dynamic>>.from(offers),
        offerUserId: user['id'],
        offerUserName: user['full_name'],
        offerUserAvatar: user['avatar_url'],
      );
    }).toList();
  }

  factory Offer.fromPendingOfferJson(Map<String, dynamic> json) {
    final offerData = json;
    final offerUser = json['user'] ?? {};
    final job = json['service'] ?? {};
    final jobOwner = job['user'] ?? {};

    // 🔽 SỬA LỖI Ở ĐÂY: Đổi 'DateTime?' thành 'DateTime'
    DateTime tryParseTime(dynamic d) {
      if (d == null) return DateTime.now();
      try {
        return DateTime.parse(d.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    int tryParseInt(dynamic i) {
      if (i == null) return 0;
      if (i is int) return i;
      return int.tryParse(i.toString()) ?? 0;
    }

    final List<Map<String, dynamic>> skillsList;
    if (job['serviceSkills'] is List) {
      skillsList = (job['serviceSkills'] as List)
          .map((serviceSkill) {
        final skill = serviceSkill['skill'];
        if (skill is Map) {
          return Map<String, dynamic>.from(skill);
        }
        return <String, dynamic>{};
      })
          .where((skillMap) => skillMap.isNotEmpty)
          .toList();
    } else {
      skillsList = [];
    }

    return Offer(
      id: offerData['id'] ?? '',
      note: offerData['note'] ?? '',
      status: offerData['status'] ?? '',
      createdAt: tryParseTime(offerData['created_at']),
      jobId: job['id'] ?? '',
      jobTitle: job['title'] ?? '',
      jobDescription: job['description'] ?? '',
      regionCode: job['region_code'] ?? '',
      place: job['place'] ?? '',
      preferredStart: tryParseTime(job['preferred_start']),
      time: tryParseInt(job['time']),
      slot: tryParseInt(job['slot']),
      visibility: job['visibility'] ?? '',
      jobStatus: job['status'] ?? '',
      jobCreatedAt: tryParseTime(job['created_at']),
      skills: skillsList,
      jobOwnerId: jobOwner['id'] ?? '',
      jobOwnerName: jobOwner['full_name'] ?? '',
      jobOwnerAvatar: jobOwner['avatar_url'],
      offerUserId: offerUser['id'] ?? '',
      offerUserName: offerUser['full_name'] ?? '',
      offerUserAvatar: offerUser['avatar_url'],
      offers: [],
    );
  }
}
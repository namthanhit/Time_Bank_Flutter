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

  final List<Map<String, dynamic>> skills; // giữ nguyên dạng list đơn giản
  final List<Map<String, dynamic>> offers; // nếu cần load thêm danh sách offer khác

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
    // parse data từ API gốc (job chứa offers[])
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
}

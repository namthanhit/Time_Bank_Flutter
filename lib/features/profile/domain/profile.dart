enum Gender { male, female, unknown }

class Profile {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime? birthDate;
  final Gender gender;
  final String? description;
  final String? regionId;
  final String? street;
  final String? workAddress;
  final String? studyAddress;
  final Map<String, String>? socialNetwork; // JSON-like map: {"facebook": "linkfb", "insta": "linkinsta"}
  final DateTime updatedAt;
  final int followers;
  final int following;
  final int points;

  Profile({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.birthDate,
    this.gender = Gender.unknown,
    this.description,
    this.regionId,
    this.street,
    this.workAddress,
    this.studyAddress,
    this.socialNetwork,
    DateTime? updatedAt,
    this.followers = 0,
    this.following = 0,
    this.points = 0,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Profile copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    DateTime? birthDate,
    Gender? gender,
    String? description,
    String? regionId,
    String? street,
    String? workAddress,
    String? studyAddress,
    Map<String, String>? socialNetwork,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      description: description ?? this.description,
      regionId: regionId ?? this.regionId,
      street: street ?? this.street,
      workAddress: workAddress ?? this.workAddress,
      studyAddress: studyAddress ?? this.studyAddress,
      socialNetwork: socialNetwork ?? this.socialNetwork,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    Map<String, String>? sn;
    if (json['socialNetwork'] != null) {
      final raw = json['socialNetwork'] as Map<String, dynamic>;
      sn = raw.map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate'] as String) : null,
      gender: _genderFromString(json['gender'] as String?),
      description: json['description'] as String?,
      regionId: json['regionId'] as String?,
      street: json['street'] as String?,
      workAddress: json['workAddress'] as String?,
      studyAddress: json['studyAddress'] as String?,
      socialNetwork: sn,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
      followers: (json['followers'] as int?) ?? 0,
      following: (json['following'] as int?) ?? 0,
      points: (json['points'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'birthDate': birthDate?.toIso8601String(),
        'gender': gender.name,
        'description': description,
        'regionId': regionId,
        'street': street,
        'workAddress': workAddress,
        'studyAddress': studyAddress,
    'socialNetwork': socialNetwork,
    'updatedAt': updatedAt.toIso8601String(),
    'followers': followers,
    'following': following,
    'points': points,
      };
}

Gender _genderFromString(String? s) {
  if (s == null) return Gender.unknown;
  switch (s.toLowerCase()) {
    case 'male':
    case 'm':
      return Gender.male;
    case 'female':
    case 'f':
      return Gender.female;
    default:
      return Gender.unknown;
  }
}

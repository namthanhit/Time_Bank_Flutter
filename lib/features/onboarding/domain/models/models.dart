
class SignupPayload {
  final String cccd;
  final String phone;
  final String email;
  final String fullName;
  final DateTime? birthdate;
  final String? gender; // "male" | "female" | "other" | "unknown"
  final String specialization;
  final String address;

  const SignupPayload({
    required this.cccd,
    required this.phone,
    required this.email,
    required this.fullName,
    this.birthdate,
    this.gender,
    required this.specialization,
    required this.address,
  });
}

class VerifyOtpPayload {
  final String phone;
  final String code; // 6 digits
  const VerifyOtpPayload({required this.phone, required this.code});
}

class SetPasswordPayload {
  final String phone;
  final String password;
  const SetPasswordPayload({required this.phone, required this.password});
}

class CompleteProfilePayload {
  final String phone;
  final String fullName;
  final DateTime? birthdate;
  final String? gender;
  final String specialization;
  final String address;

  const CompleteProfilePayload({
    required this.phone,
    required this.fullName,
    this.birthdate,
    this.gender,
    required this.specialization,
    required this.address,
  });
}

class SetPinPayload {
  final String phone;
  final String pin; // 4–6 digits
  const SetPinPayload({required this.phone, required this.pin});
}

class SkillDto {
  final String id;
  final String? parentId;
  final String name;
  final String slug;

  SkillDto({required this.id, this.parentId, required this.name, required this.slug});

  factory SkillDto.fromJson(Map<String, dynamic> j) => SkillDto(
    id: j['id'] as String,
    parentId: j['parent_id'] as String?,
    name: j['name'] as String,
    slug: j['slug'] as String,
  );
}


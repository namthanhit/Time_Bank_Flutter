import 'package:equatable/equatable.dart';

/// Thông tin người dùng nhập ở bước đăng ký ban đầu.
class SignUpPayload extends Equatable {
  const SignUpPayload({
    required this.citizenId,
    required this.phoneNumber,
    this.email,
    required this.fullName,
  });

  final String citizenId;
  final String phoneNumber;
  final String? email;
  final String fullName;

  SignUpPayload copyWith({
    String? citizenId,
    String? phoneNumber,
    String? email,
    String? fullName,
  }) {
    return SignUpPayload(
      citizenId: citizenId ?? this.citizenId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'citizen_id': citizenId,
      'phone_number': phoneNumber,
      'email': email,
      'full_name': fullName,
    }..removeWhere((key, value) => value == null);
  }

  @override
  List<Object?> get props => [citizenId, phoneNumber, email, fullName];
}

/// Thông tin hồ sơ cá nhân thu thập ở bước tiếp theo.
class ProfileInfo extends Equatable {
  const ProfileInfo({
    required this.birthDate,
    required this.gender,
    required this.major,
    required this.address,
  });

  final DateTime birthDate;
  final String gender;
  final String major;
  final String address;

  ProfileInfo copyWith({
    DateTime? birthDate,
    String? gender,
    String? major,
    String? address,
  }) {
    return ProfileInfo(
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      major: major ?? this.major,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'birth_date': birthDate.toIso8601String(),
      'gender': gender,
      'major': major,
      'address': address,
    };
  }

  @override
  List<Object?> get props => [birthDate, gender, major, address];
}

/// Tổng hợp dữ liệu của toàn bộ quy trình onboarding.
class OnboardingFormData extends Equatable {
  const OnboardingFormData({
    this.signUp,
    this.otpCode,
    this.profile,
    this.password,
    this.pin,
  });

  final SignUpPayload? signUp;
  final String? otpCode;
  final ProfileInfo? profile;
  final String? password;
  final String? pin;

  OnboardingFormData copyWith({
    SignUpPayload? signUp,
    String? otpCode,
    ProfileInfo? profile,
    String? password,
    String? pin,
  }) {
    return OnboardingFormData(
      signUp: signUp ?? this.signUp,
      otpCode: otpCode ?? this.otpCode,
      profile: profile ?? this.profile,
      password: password ?? this.password,
      pin: pin ?? this.pin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...?signUp?.toJson(),
      if (otpCode != null) 'otp_code': otpCode,
      ...?profile?.toJson(),
      if (password != null) 'password': password,
      if (pin != null) 'pin': pin,
    };
  }

  @override
  List<Object?> get props => [signUp, otpCode, profile, password, pin];
}

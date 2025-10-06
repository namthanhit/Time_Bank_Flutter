import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/onboarding_repository.dart';
import '../domain/onboarding_models.dart';

final onboardingRepositoryProvider =
    Provider<OnboardingRepository>((_) => MockOnboardingRepository());

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController(ref.watch(onboardingRepositoryProvider));
});

class OnboardingState extends Equatable {
  const OnboardingState({
    required this.data,
    required this.status,
  });

  factory OnboardingState.initial() =>
      const OnboardingState(data: OnboardingFormData(), status: AsyncData(null));

  final OnboardingFormData data;
  final AsyncValue<void> status;

  OnboardingState copyWith({
    OnboardingFormData? data,
    AsyncValue<void>? status,
  }) {
    return OnboardingState(
      data: data ?? this.data,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [data, status];
}

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController(this._repository) : super(OnboardingState.initial());

  final OnboardingRepository _repository;

  Future<bool> requestOtp(SignUpPayload payload) async {
    state = state.copyWith(status: const AsyncLoading());
    try {
      await _repository.requestOtp(payload);
      state = state.copyWith(
        data: state.data.copyWith(signUp: payload),
        status: const AsyncData(null),
      );
      return true;
    } catch (error, stack) {
      state = state.copyWith(status: AsyncError(error, stack));
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    final signUp = state.data.signUp;
    if (signUp == null) {
      state = state.copyWith(
        status: AsyncError(
          StateError('Thiếu thông tin đăng ký ban đầu'),
          StackTrace.current,
        ),
      );
      return false;
    }

    state = state.copyWith(status: const AsyncLoading());
    try {
      await _repository.verifyOtp(phone: signUp.phoneNumber, otp: otp);
      state = state.copyWith(
        data: state.data.copyWith(otpCode: otp),
        status: const AsyncData(null),
      );
      return true;
    } catch (error, stack) {
      state = state.copyWith(status: AsyncError(error, stack));
      return false;
    }
  }

  Future<bool> submitProfile(ProfileInfo info) async {
    final signUp = state.data.signUp;
    if (signUp == null) {
      state = state.copyWith(
        status: AsyncError(
          StateError('Thiếu thông tin đăng ký ban đầu'),
          StackTrace.current,
        ),
      );
      return false;
    }

    state = state.copyWith(status: const AsyncLoading());
    try {
      await _repository.submitProfile(phone: signUp.phoneNumber, profile: info);
      state = state.copyWith(
        data: state.data.copyWith(profile: info),
        status: const AsyncData(null),
      );
      return true;
    } catch (error, stack) {
      state = state.copyWith(status: AsyncError(error, stack));
      return false;
    }
  }

  Future<bool> setPassword(String password) async {
    final signUp = state.data.signUp;
    if (signUp == null) {
      state = state.copyWith(
        status: AsyncError(
          StateError('Thiếu thông tin đăng ký ban đầu'),
          StackTrace.current,
        ),
      );
      return false;
    }

    state = state.copyWith(status: const AsyncLoading());
    try {
      await _repository.setPassword(phone: signUp.phoneNumber, password: password);
      state = state.copyWith(
        data: state.data.copyWith(password: password),
        status: const AsyncData(null),
      );
      return true;
    } catch (error, stack) {
      state = state.copyWith(status: AsyncError(error, stack));
      return false;
    }
  }

  Future<bool> completeRegistration(String pin) async {
    final currentData = state.data.copyWith(pin: pin);
    final signUp = currentData.signUp;
    if (signUp == null) {
      state = state.copyWith(
        status: AsyncError(
          StateError('Thiếu thông tin đăng ký ban đầu'),
          StackTrace.current,
        ),
      );
      return false;
    }

    state = state.copyWith(status: const AsyncLoading());
    try {
      await _repository.finalize(currentData);
      state = OnboardingState.initial();
      return true;
    } catch (error, stack) {
      state = state.copyWith(status: AsyncError(error, stack));
      return false;
    }
  }

  void clearStatus() {
    if (!state.status.isLoading) {
      state = state.copyWith(status: const AsyncData(null));
    }
  }
}

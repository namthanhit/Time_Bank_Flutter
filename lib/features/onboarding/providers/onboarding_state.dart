import 'package:freezed_annotation/freezed_annotation.dart';
part 'onboarding_state.freezed.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(false) bool loading,
    String? phone,   // giữ luồng phone xuyên suốt
    String? error,   // hiển thị SnackBar/Toast
  }) = _OnboardingState;
}

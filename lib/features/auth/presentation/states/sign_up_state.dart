import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_management_flutter/core/error/failures.dart';

part 'sign_up_state.freezed.dart';

@freezed
class SignUpState with _$SignUpState {
  const factory SignUpState.initial() = _Initial;
  const factory SignUpState.loading() = _Loading;
  const factory SignUpState.success() = _Success;
  const factory SignUpState.error(String message, Failure failure) = _Error;
  const factory SignUpState.validating() = _Validating;
}
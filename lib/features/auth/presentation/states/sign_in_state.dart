import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_management_flutter/core/error/failures.dart';

part 'sign_in_state.freezed.dart';

@freezed
class SignInState with _$SignInState {
  const factory SignInState.initial() = _Initial;
  const factory SignInState.loading() = _Loading;
  const factory SignInState.success() = _Success;
  const factory SignInState.error(String message, Failure failure) = _Error;
}
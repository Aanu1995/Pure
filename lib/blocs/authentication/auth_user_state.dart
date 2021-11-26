import 'package:equatable/equatable.dart';

import '../../model/pure_user_model.dart';

abstract class AuthUserState extends Equatable {
  const AuthUserState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthUserState {}

class AuthInProgress extends AuthUserState {}

class LoginSuccess extends AuthUserState {
  const LoginSuccess({required this.pureUser});

  final PureUser pureUser;

  @override
  List<Object?> get props => [pureUser];
}

class SignUpSuccess extends AuthUserState {
  const SignUpSuccess({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

class ResetPasswordSuccess extends AuthUserState {
  const ResetPasswordSuccess();
}

class AuthUserFailure extends AuthUserState {
  const AuthUserFailure({required this.message});
  final String message;
}

// Update Password State

class UpdatePasswordSuccess extends AuthUserState {
  const UpdatePasswordSuccess();
}

class UpdatePasswordFailed extends AuthUserState {
  const UpdatePasswordFailed({required this.message});
  final String message;
}

class UpdateEmailSuccess extends AuthUserState {
  const UpdateEmailSuccess();
}

class UpdateEmailFailed extends AuthUserState {
  const UpdateEmailFailed({required this.message});
  final String message;
}

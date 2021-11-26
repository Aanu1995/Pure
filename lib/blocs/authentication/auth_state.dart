import 'package:equatable/equatable.dart';

import '../../model/pure_user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class Authenticating extends AuthState {}

class UnAuthenticated extends AuthState {}

class Authenticated extends AuthState {
  const Authenticated(this.user);
  final PureUser user;

  @override
  List<Object?> get props => [user];
}

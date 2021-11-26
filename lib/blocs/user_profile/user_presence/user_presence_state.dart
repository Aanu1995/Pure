import 'package:equatable/equatable.dart';

import '../../../model/user_presence_model.dart';

class UserPresenceState extends Equatable {
  const UserPresenceState();

  @override
  List<Object?> get props => [];
}

class UserPresenceInitial extends UserPresenceState {}

class UserPresenceSuccess extends UserPresenceState {
  final UserPresenceModel presence;

  const UserPresenceSuccess(this.presence);

  @override
  List<Object?> get props => [presence];
}

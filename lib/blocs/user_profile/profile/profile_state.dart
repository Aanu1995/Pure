import 'package:equatable/equatable.dart';

import '../../../model/pure_user_model.dart';

class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final PureUser user;

  const ProfileSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

import 'package:equatable/equatable.dart';
import 'package:pure/model/pure_user_extra.dart';

abstract class UserExtraState extends Equatable {
  const UserExtraState();

  @override
  List<Object?> get props => [];
}

class UserExtraInitial extends UserExtraState {}

class UserExtraLoading extends UserExtraState {}

class UserExtraSuccess extends UserExtraState {
  final PureUserExtraModel extraData;

  const UserExtraSuccess({required this.extraData});

  @override
  List<Object?> get props => [extraData];
}

class UserExtraFailure extends UserExtraState {
  const UserExtraFailure(this.message);

  final String message;
}

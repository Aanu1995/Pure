import 'package:equatable/equatable.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class Loading extends UserProfileState {}

class ImageUploading extends UserProfileState {}

class UserProfileUpdateSuccess extends UserProfileState {}

class ProfileImageUpdateSuccess extends UserProfileState {}

class UserProfileUpdateFailure extends UserProfileState {
  const UserProfileUpdateFailure(this.message);

  final String message;
}

class ProfileImageUpdateFailure extends UserProfileState {
  const ProfileImageUpdateFailure(this.message);

  final String message;
}

import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/user_service.dart';
import '../../utils/exception.dart';
import '../../utils/request_messages.dart';
import 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit(this.userService) : super(UserProfileInitial());

  final UserService userService;

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    emit(Loading());
    try {
      await userService.updateUser(userId, data);
      emit(UserProfileUpdateSuccess());
    } on NetworkException catch (e) {
      emit(UserProfileUpdateFailure(e.message!));
    } on ServerException catch (e) {
      emit(UserProfileUpdateFailure(e.message!));
    } on Exception catch (_) {
      emit(UserProfileUpdateFailure(ErrorMessages.generalMessage2));
    }
  }

  Future<void> updateProfileImage(String userId, File file) async {
    emit(ImageUploading());
    try {
      await userService.updateUserProfileImage(userId, file);
      emit(ProfileImageUpdateSuccess());
    } on NetworkException catch (e) {
      emit(ProfileImageUpdateFailure(e.message!));
    } on ServerException catch (e) {
      emit(ProfileImageUpdateFailure(e.message!));
    } on Exception catch (_) {
      emit(ProfileImageUpdateFailure(ErrorMessages.generalMessage2));
    }
  }

  Future<void> deleteProfileImage(String userId) async {
    emit(ImageUploading());
    try {
      await userService.deleteProfileImage(userId);
      emit(ProfileImageUpdateSuccess());
    } on NetworkException catch (e) {
      emit(ProfileImageUpdateFailure(e.message!));
    } on ServerException catch (e) {
      emit(ProfileImageUpdateFailure(e.message!));
    } on Exception catch (_) {
      emit(ProfileImageUpdateFailure(ErrorMessages.generalMessage2));
    }
  }
}

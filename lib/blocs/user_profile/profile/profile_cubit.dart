import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/pure_user_model.dart';
import '../../../services/user_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserService userService;
  ProfileCubit(this.userService) : super(ProfileInitial());

  StreamSubscription<PureUser?>? _subscription;

  Future<void> getProfile(String userId) async {
    try {
      _subscription?.cancel();
      _subscription = userService.getUserData(userId).listen((user) {
        if (user != null) {
          emit(ProfileSuccess(user));
        }
      });
    } catch (e) {
      // No need to show message, it is a stream and will continue to listen
      log(e.toString());
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _subscription = null;
    return super.close();
  }
}

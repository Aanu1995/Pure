import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/user_presence_model.dart';
import '../../../services/user_service.dart';
import 'user_presence_state.dart';

class UserPresenceCubit extends Cubit<UserPresenceState> {
  final UserService userService;
  UserPresenceCubit(this.userService) : super(UserPresenceInitial());

  StreamSubscription<UserPresenceModel?>? _subscription;

  Future<void> getUserPresence(String userId) async {
    try {
      _subscription?.cancel();
      _subscription = userService.getUserPresence(userId).listen((presence) {
        if (presence != null) {
          emit(UserPresenceSuccess(presence));
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

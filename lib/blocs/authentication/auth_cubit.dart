import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/pure_user_model.dart';
import '../../repositories/local_storage.dart';
import '../../services/user_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this.firebaseAuth,
    this.localStorage,
    this.userService,
  ) : super(Authenticating());

  final LocalStorage localStorage;
  final FirebaseAuth firebaseAuth;
  final UserService userService;

  Future<void> authenticateUser() async {
    try {
      if (firebaseAuth.currentUser != null) {
        // if user data exists in the local storage is not null,
        // then the user is logged in
        final data = await localStorage.getUserData();
        if (data != null) {
          final user = PureUser.fromMap(data);
          emit(Authenticated(user));
          return _syncUserLocalDataWithRemoteData(user.id);
        }
      }
      emit(UnAuthenticated());
    } catch (_) {
      emit(UnAuthenticated());
    }
  }

  StreamSubscription<PureUser?>? _subscription;

  // This sync the user data in remote database with the local database in
  // order to have same data
  Future<void> _syncUserLocalDataWithRemoteData(final String userId) async {
    try {
      if (_subscription != null) {
        _subscription?.cancel();
      }
      _subscription = userService.getCurrentUserData(userId).listen((user) {
        emit(Authenticated(user));
      });
    } catch (_) {}
  }

  Future<void> setUserOnline(final String userId) async {
    await userService.setUserPresence(userId);
  }

  Future<void> signOut(final String userId) async {
    try {
      await userService.setUserOfflineOnSignOut(userId);
      dispose();
      await firebaseAuth.signOut();
      await localStorage.clear();
      emit(UnAuthenticated());
    } catch (_) {}
  }

  void update(PureUser user) {
    emit(Authenticated(user));
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  Future<void> close() {
    dispose();
    return super.close();
  }
}

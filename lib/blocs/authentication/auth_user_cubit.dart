import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/pure_user_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../utils/exception.dart';
import '../../utils/request_messages.dart';
import 'auth_user_state.dart';

class AuthUserCubit extends Cubit<AuthUserState> {
  AuthUserCubit(this.authService, this.userService) : super(AuthInitial());

  final AuthService authService;
  final UserService userService;

// this method is required in order to update user data locally
  Future<void> getUser(String userId) async {
    try {
      final pureUser = await userService.getUser(userId);
      emit(LoginSuccess(pureUser: pureUser));
    } on NetworkException catch (e) {
      // Failure due to poor internet connection
      emit(AuthUserFailure(message: e.message!));
    } on ServerException catch (e) {
      // Failure due to error from the server
      emit(AuthUserFailure(message: e.message!));
    } catch (e) {
      // Failure due to unseen circumstances
      emit(AuthUserFailure(message: ErrorMessages.generalMessage));
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(AuthInProgress());

    try {
      final user = await authService.createAccount(email, password);
      // upload user data to the remote database
      await userService.createUser(user.uid, PureUser.toMap(user));
      emit(SignUpSuccess(message: SuccessMessages.signUpMessage));
    } on NetworkException catch (e) {
      // Failure due to poor internet connection
      emit(AuthUserFailure(message: e.message!));
    } on ServerException catch (e) {
      // Failure due to error from the server
      emit(AuthUserFailure(message: e.message!));
    } catch (e) {
      // Failure due to unseen circumstances
      emit(AuthUserFailure(message: ErrorMessages.generalMessage));
    }
  }

  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    emit(AuthInProgress());

    try {
      final data =
          await authService.signInWithEmailAndPassword(email, password);
      // fetch user data in the remote database
      final pureUser = await userService.getUser(data.uid);
      emit(LoginSuccess(pureUser: pureUser));
    } on NetworkException catch (e) {
      // Failure due to poor internet connection
      emit(AuthUserFailure(message: e.message!));
    } on ServerException catch (e) {
      // Failure due to error from the server
      emit(AuthUserFailure(message: e.message!));
    } catch (e) {
      // Failure due to unseen circumstances
      emit(AuthUserFailure(message: ErrorMessages.generalMessage));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthInProgress());

    try {
      final data = await authService.signInWithGoogle();
      // fetch user data in the remote database
      final pureUser = await userService.getUserIfExistOrCreate(
          data.uid, PureUser.toMap(data));
      emit(LoginSuccess(pureUser: pureUser));
    } on NetworkException catch (e) {
      // Failure due to poor internet connection
      emit(AuthUserFailure(message: e.message!));
    } on ServerException catch (e) {
      // Failure due to error from the server
      emit(AuthUserFailure(message: e.message!));
    } catch (e) {
      // Failure due to unseen circumstances
      emit(AuthUserFailure(message: ErrorMessages.generalMessage));
    }
  }

  Future<void> signInWithApple() async {
    emit(AuthInProgress());

    try {
      final data = await authService.signInWithApple();
      // fetch user data in the remote database
      final pureUser = await userService.getUserIfExistOrCreate(
          data.uid, PureUser.toMap(data));
      emit(LoginSuccess(pureUser: pureUser));
    } on NetworkException catch (e) {
      // Failure due to poor internet connection
      emit(AuthUserFailure(message: e.message!));
    } on ServerException catch (e) {
      // Failure due to error from the server
      emit(AuthUserFailure(message: e.message!));
    } catch (e) {
      // Failure due to unseen circumstances
      emit(AuthUserFailure(message: ErrorMessages.generalMessage));
    }
  }

  Future<void> updateEmailAddress(
      String id, String currentPass, String email) async {
    emit(AuthInProgress());

    try {
      await authService.changeUserEmailAddress(currentPass, email);

      final data = <String, String>{"email": email};
      await userService.updateUser(id, data);
      emit(const UpdateEmailSuccess());
    } on NetworkException catch (e) {
      // Failure due to poor internet connection
      emit(UpdateEmailFailed(message: e.message!));
    } on ServerException catch (e) {
      // Failure due to error from the server
      emit(UpdateEmailFailed(message: e.message!));
    } catch (e) {
      // Failure due to unseen circumstances
      emit(UpdateEmailFailed(message: ErrorMessages.generalMessage));
    }
  }

  Future<void> updatePassword(String currentPass, String newPass) async {
    emit(AuthInProgress());

    try {
      await authService.changeUserPassword(currentPass, newPass);
      emit(const UpdatePasswordSuccess());
    } on NetworkException catch (e) {
      // Failure due to poor internet connection
      emit(UpdatePasswordFailed(message: e.message!));
    } on ServerException catch (e) {
      // Failure due to error from the server
      emit(UpdatePasswordFailed(message: e.message!));
    } catch (e) {
      // Failure due to unseen circumstances
      emit(UpdatePasswordFailed(message: ErrorMessages.generalMessage));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(AuthInProgress());

    try {
      await authService.resetPassword(email);
      emit(const ResetPasswordSuccess());
    } on NetworkException catch (e) {
      // Failure due to poor internet connection
      emit(AuthUserFailure(message: e.message!));
    } on ServerException catch (e) {
      // Failure due to error from the server
      emit(AuthUserFailure(message: e.message!));
    } catch (e) {
      // Failure due to unseen circumstances
      emit(AuthUserFailure(message: ErrorMessages.generalMessage));
    }
  }
}

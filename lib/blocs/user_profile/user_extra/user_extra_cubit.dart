import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/user_service.dart';
import '../../../utils/exception.dart';
import '../../../utils/request_messages.dart';
import 'user_extra_state.dart';

class UserExtraCubit extends Cubit<UserExtraState> {
  UserExtraCubit(this.userService) : super(UserExtraInitial());

  final UserService userService;

  Future<void> getExtraData(String userId) async {
    emit(UserExtraLoading());

    try {
      final result = await userService.getUserExtraData(userId);
      return emit(UserExtraSuccess(extraData: result));
    } on NetworkException catch (e) {
      emit(UserExtraFailure(e.message!));
    } on ServerException catch (e) {
      emit(UserExtraFailure(e.message!));
    } on Exception catch (_) {
      emit(UserExtraFailure(ErrorMessages.generalMessage2));
    }
  }
}

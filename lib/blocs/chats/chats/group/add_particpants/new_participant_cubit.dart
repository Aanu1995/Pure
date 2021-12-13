import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../model/pure_user_model.dart';
import '../../../../../services/chat/chat_service.dart';
import '../../../../../utils/exception.dart';
import '../../../../../utils/request_messages.dart';
import 'new_particpant_state.dart';

class ParticipantCubit extends Cubit<ParticipantState> {
  final ChatService chatService;

  ParticipantCubit(this.chatService) : super(ParticipantInitial());

  Future<void> addGroupMembers(String chatId, List<PureUser> newMembers) async {
    emit(AddingParticipant());

    try {
      await chatService.addNewParticipants(
          chatId, newMembers.map((e) => e.id).toList());
      emit(NewParticipant(newMembers: newMembers));
    } on NetworkException catch (e) {
      emit(NewParticipantFailed(e.message!));
    } on ServerException catch (e) {
      emit(NewParticipantFailed(e.message!));
    } catch (_) {
      emit(NewParticipantFailed(ErrorMessages.generalMessage2));
    }
  }

  Future<void> removeMember(String chatId, int index, PureUser member) async {
    emit(RemovingParticipant(member));

    try {
      await chatService.removeParticipant(chatId, member.id);
      emit(ParticipantRemoved(member));
    } on NetworkException catch (_) {
      emit(FailedToRemoveParticipant(index, member));
    } on ServerException catch (_) {
      emit(FailedToRemoveParticipant(index, member));
    } catch (_) {
      emit(FailedToRemoveParticipant(index, member));
    }
  }

  Future<void> exitGroup(String chatId, String userId) async {
    emit(ExitingGroup());

    try {
      await chatService.removeParticipant(chatId, userId);
      emit(GroupExited(chatId));
    } on NetworkException catch (error) {
      emit(FailedToExitGroup(error.message!));
    } on ServerException catch (error) {
      emit(FailedToExitGroup(error.message!));
    } catch (_) {
      emit(FailedToExitGroup(ErrorMessages.generalMessage2));
    }
  }

  Future<void> addAdmin(String chatId, String userId) async {
    emit(AddingAdmin(userId));
    await chatService.addAdmin(chatId, userId);
    emit(OperationCompleted());
  }

  Future<void> removeAdmin(String chatId, String userId) async {
    emit(RemovingAdmin(userId));
    await chatService.removeAdmin(chatId, userId);
    emit(OperationCompleted());
  }
}

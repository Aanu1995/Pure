import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pure/model/pure_user_model.dart';

import '../../../../../services/chat/chat_service.dart';
import '../../../../../utils/exception.dart';
import '../../../../../utils/request_messages.dart';
import 'new_particpant_state.dart';

class NewParticipantCubit extends Cubit<NewParticipantState> {
  final ChatService chatService;
  NewParticipantCubit(this.chatService) : super(ParticipantInitial());

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
}

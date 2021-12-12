import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../model/pure_user_model.dart';
import '../../../../services/chat/chat_service.dart';
import '../../../bloc.dart';

class AddParticipantCubit extends Cubit<GroupState> {
  final ChatService chatService;
  AddParticipantCubit(this.chatService) : super(GroupMembers(members: []));

  void addMember(PureUser user) {
    final currentState = state;

    if (currentState is GroupMembers) {
      final members = currentState.members.toList();
      members.add(user);
      emit(GroupMembers(members: members));
    }
  }

  void removeMember(PureUser user) {
    final currentState = state;

    if (currentState is GroupMembers) {
      final members = currentState.members.toList();
      members.removeWhere((member) => member.id == user.id);
      emit(GroupMembers(members: members));
    }
  }
}

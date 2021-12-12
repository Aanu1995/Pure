import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../model/pure_user_model.dart';
import '../../../../services/chat/chat_service.dart';
import 'group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  final ChatService chatService;
  GroupCubit(this.chatService) : super(GroupMembers(members: []));

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

  StreamSubscription<List<PureUser>?>? _subscription;

  void getGroupMembersProfile(List<String> userIds) {
    _subscription?.cancel();
    _subscription =
        chatService.getGroupMembersProfile(userIds).listen((members) {
      if (members != null) {
        emit(GroupMembers(members: members));
        // cancel subscription once data is available
        _subscription?.cancel();
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
